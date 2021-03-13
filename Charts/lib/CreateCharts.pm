package CreateCharts;
use strict;
use warnings;

use Chart::Clicker;
use Chart::Clicker::Context;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::Series;
use Chart::Clicker::Axis::DateTime;

use Geometry::Primitive::Rectangle;
use Geometry::Primitive::Circle;

use Graphics::Color::RGB;

use DateTime;

sub new {
    my ($class, @arguments) = @_;
    my $self = {@arguments};
    bless $self, $class;
    return $self;
}

sub _generate_specific_colors {
    my ($self) = @_;

    # build the color allocator
    my $ca = Chart::Clicker::Drawing::ColorAllocator->new;

    my $red    = Graphics::Color::RGB->new({red => .75, green => 0,   blue => 0,   alpha => .8});
    my $green  = Graphics::Color::RGB->new({red => 0,   green => .75, blue => 0,   alpha => .8});
    my $blue   = Graphics::Color::RGB->new({red => 0,   green => 0,   blue => .75, alpha => .8});
    my $orange = Graphics::Color::RGB->new(red => .88, green => .48, blue => .09, alpha => 1);
    my $grey   = Graphics::Color::RGB->new(red => .36, green => .36, blue => .36, alpha => 1);

    $ca->add_to_colors($green);
    $ca->add_to_colors($red);
    $ca->add_to_colors($blue);
    $ca->add_to_colors($orange);
    $ca->add_to_colors($grey);

    return $ca;
}

sub _genrate_random_colors {

    # let Chart::Clicker autmatically pick complementing colors for you
    # https://metacpan.org/pod/Chart::Clicker::Drawing::ColorAllocator#AUTOMATIC-COLOR-ALLOCATION
    my $ca = Chart::Clicker::Drawing::ColorAllocator->new(
        {
            seed_hue => 0,    #red
        }
    );
    return $ca;
}

sub _add_series {
    my ($self, $x_axis, $y_axis) = @_;
    my $ds = Chart::Clicker::Data::DataSet->new;
    foreach my $axis (keys %{$y_axis}) {
        $ds->add_to_series(
            Chart::Clicker::Data::Series->new(
                keys   => $x_axis,
                values => $y_axis->{$axis}->{data},
                name   => $y_axis->{$axis}->{legendName},
            )
        );
    }
    return $ds;
}

sub _add_title {
    my ($self, $cc, $title) = @_;
    $cc->title->font->family('Helvetica');
    $cc->width(500);
    $cc->height(500);

    $cc->title->text($title);
    $cc->title->font->size(20);
    $cc->title->padding->bottom(5);
}

sub _style_legend {
    my ($self, $cc) = @_;
    $cc->legend->font->size(20);
    $cc->legend->font->family('Helvetica');
    $cc->border->width(0);
}

sub _add_background {
    my ($self, $cc) = @_;
    my $moregrey = Graphics::Color::RGB->new(red => .898, green => .898, blue => .858, alpha => 1);
    my $lightolivegreen = Graphics::Color::RGB->new(red => .96, green => .96, blue => .93, alpha => 1);

    $cc->plot->grid->visible(0);
    $cc->background_color($lightolivegreen);
    $cc->plot->grid->background_color($moregrey);
}

sub _add_label {
    my ($self, $def, $x_label, $y_label) = @_;
    $def->range_axis->label($x_label);
    $def->domain_axis->label($y_label);
    $def->range_axis->label_font->family('Helvetica');
    $def->range_axis->label_font->size(20);
}

sub _add_shapes_to_lines {
    my ($self, $defctx) = @_;

    # https://metacpan.org/pod/Chart::Clicker::Renderer::Line#shape
    $defctx->renderer->shape(Geometry::Primitive::Circle->new({radius => 6,}));

    # https://metacpan.org/pod/Chart::Clicker::Renderer::Line#shape_brush
    $defctx->renderer->shape_brush(
        Graphics::Primitive::Brush->new(
            width => 2,
            color => Graphics::Color::RGB->new(red => 1, green => 1, blue => 1)
        )
    );

    $defctx->renderer->brush->width(2);
}

sub generate_chart {
    my ($self, $chart_loc, $summary_info) = @_;

    my $cc = Chart::Clicker->new(width => 800, height => 600, format => 'png');

    my $x_axis = $summary_info->{domainAxis};
    my $y_axis = $summary_info->{rangeAxis};

    my (@epoch_datetime);

    for my $datetime (@{$x_axis->{data}}) {

        # https://github.com/gphat/chart-clicker/blob/master/example/date-axis.pl
        # Need to convert date time string to epoch time
        my ($y, $m, $d) = split(/-/, $datetime);
        my $epoch = DateTime->new(year => $y, month => $m, day => $d)->epoch;
        push @epoch_datetime, $epoch;
    }

    my $ds = $self->_add_series(\@epoch_datetime, $y_axis->{lines});
    $cc->add_to_datasets($ds);

    # To generate random colors and let Chart::Clicker autmatically pick color
    # my $ca = $self->_genrate_random_colors();

    # To generate some specific colors for lines ise this function
    my $ca = $self->_generate_specific_colors();
    $cc->color_allocator($ca);

    $self->_add_title($cc, $summary_info->{title});
    $self->_style_legend($cc);
    $self->_add_background($cc);

    my $defctx = $cc->get_context('default');
    $self->_add_label($defctx, $x_axis->{label}, $y_axis->{label});

    # For range axis
    $defctx->range_axis->range(Chart::Clicker::Data::Range->new(lower => 0));
    $defctx->range_axis->format('%d');

    #$defctx->range_axis->fudge_amount(.01);

    # For domain axis
    #$defctx->domain_axis->format('%d');

    $defctx->domain_axis(
        Chart::Clicker::Axis::DateTime->new(
            format => "%Y-%m-%d",
            ticks  => scalar @{$x_axis->{data}},

            #tick_values      => \@x_tick_values,
            position         => 'bottom',
            tick_label_angle => 0.78539816,                       # 45 deg in radians
            orientation      => 'vertical',
            label            => 'Date',
            label_font       => Graphics::Primitive::Font->new(
                {family => 'Helvetica', size => 20, slant => 'normal'}
            ),
            tick_font => Graphics::Primitive::Font->new({family => 'Helvetica', slant => 'normal'}),
        )
    );

    $self->_add_shapes_to_lines($defctx);
    $cc->write_output($chart_loc);
}

1;
