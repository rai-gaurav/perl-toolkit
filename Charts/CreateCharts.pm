
package CreateCharts;
use strict;
use warnings;

use Chart::Clicker;
use Chart::Clicker::Context;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::Series;
use Geometry::Primitive::Rectangle;
use Graphics::Color::RGB;
use Geometry::Primitive::Circle;
use Chart::Clicker::Axis::DateTime;
use DateTime;

use Exporter qw(import);
our @EXPORT_OK = qw(generate_chart);

sub _generate_axis {
    my ($summary_info) = @_;
    my (@domain_axis, @range_axis_1, @range_axis_2, @range_axis_3);

    foreach my $block (@$summary_info) {
        push (@domain_axis, $block->{key});
        push (@range_axis_1, $block->{value}->{'Axis1'});
        push (@range_axis_2, $block->{value}->{'Axis2'});
        push (@range_axis_3, $block->{value}->{'Axis3'});
    }
    return (\@domain_axis, \@range_axis_1, \@range_axis_2, \@range_axis_3);
}

sub generate_chart {
    my ($chart_loc, $summary_info) = @_;

    my $cc = Chart::Clicker->new(width => 800, height => 600, format => 'png');

    my($x_axis, $y_axis_1, $y_axis_2, $y_axis_3) = _generate_axis($summary_info);

    my ( @k, @x_tick_values );
    for  my $datetime ( @$x_axis ) {
        #my ( $y, $m, $d ) = unpack("a4 a2 a2", $datetime);
        my ( $y, $m, $d ) = split(/-/, $datetime);
        my $epoch = DateTime->new( year => $y, month => $m, day => $d )->epoch;
        push @k, $epoch;
        push @x_tick_values, $epoch if $d eq '01';
    }

    # build the color allocator
    my $ca = Chart::Clicker::Drawing::ColorAllocator->new;
    my $red = Graphics::Color::RGB->new({
        red => .75, green => 0, blue => 0, alpha => .8
    });
    my $green = Graphics::Color::RGB->new({
        red => 0,green => .75, blue=> 0, alpha=> .8
    });
    my $blue = Graphics::Color::RGB->new({
        red => 0, green => 0, blue => .75, alpha => .8
    });
    my $orange = Graphics::Color::RGB->new(
        red => .88, green => .48, blue => .09, alpha => 1
    );
    my $grey = Graphics::Color::RGB->new(
        red => .36, green => .36, blue => .36, alpha => 1
    );
    my $moregrey = Graphics::Color::RGB->new(
        red => .898, green => .898, blue => .858, alpha => 1
    );

    my $lightolivegreen = Graphics::Color::RGB->new(
        red => .96, green => .96, blue => .93, alpha => 1
    );

    my $ds = Chart::Clicker::Data::DataSet->new;
    $ds->add_to_series(Chart::Clicker::Data::Series->new(
        keys    => \@k,
        values  => $y_axis_1,
        name   => 'Axis1',
    ));
    $ca->add_to_colors($green);
    $cc->color_allocator($ca);

    $ds->add_to_series(Chart::Clicker::Data::Series->new(
        keys    => \@k,
        values  => $y_axis_2,
        name   => 'Axi2',
    ));
    $ca->add_to_colors($red);
    $cc->color_allocator($ca);

    $ds->add_to_series(Chart::Clicker::Data::Series->new(
        keys    => \@k,
        values  => $y_axis_3,
        name   => 'Axis3',
    ));
    $ca->add_to_colors($blue);
    $cc->color_allocator($ca);
    
    $cc->title->font->family('Helvetica');
    $cc->title->text('Title');
    $cc->title->font->size(20); 
    $cc->title->padding->bottom(5);

    $cc->legend->font->size(20);
    $cc->legend->font->family('Helvetica');
    $cc->border->width(0);
    $cc->add_to_datasets($ds);
    #$cc->plot->grid->visible(0);
    $cc->background_color($lightolivegreen);
    $cc->plot->grid->background_color($moregrey);

    my $defctx = $cc->get_context('default');

    $defctx->range_axis->range(Chart::Clicker::Data::Range->new(lower => 0, upper => 1200));

    $defctx->range_axis->label('Number of samples');
    #$defctx->domain_axis->label('Date');

    $defctx->range_axis->format('%d');
    #$defctx->domain_axis->format('%d');

    #$defctx->range_axis->fudge_amount(.01);

    $defctx->range_axis->label_font->family('Helvetica');
    $defctx->range_axis->tick_font->family('Arial');
    $defctx->range_axis->label_font->size(20);

    #$defctx->domain_axis->tick_font->family('Helvetica');
    #$defctx->domain_axis->label_font->family('Arial');
    #$defctx->domain_axis->label_font->size(20);

    $defctx->domain_axis(
        Chart::Clicker::Axis::DateTime->new(
            format           => "%Y-%m-%d",
            ticks            => scalar @$x_axis,
            tick_values      => \@x_tick_values,
            position         => 'bottom',
            tick_label_angle => 0.78539816,         # 45 deg in radians
            orientation      => 'vertical',
            label            => 'Date',
            label_font       =>  Graphics::Primitive::Font->new({
                                    family => 'Helvetica',
                                    size => 20,
                                    slant => 'normal'
                                  }),
            tick_font        =>  Graphics::Primitive::Font->new({
                                    family => 'Arial',
                                    slant => 'normal'
                                  }),
            )
    );

    $defctx->renderer->shape(
        Geometry::Primitive::Circle->new({
            radius => 6,
        })
    );

    $defctx->renderer->shape_brush(
        Graphics::Primitive::Brush->new(
            width => 2,
            color => Graphics::Color::RGB->new(red => 1, green => 1, blue => 1)
        )
    );

    $defctx->renderer->brush->width(2);

    $cc->write_output($chart_loc);

}

1;
