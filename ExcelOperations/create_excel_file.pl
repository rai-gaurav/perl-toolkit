#!/usr/bin/env perl
use strict;
use warnings;

# https://metacpan.org/pod/Excel::Writer::XLSX
use Excel::Writer::XLSX;
use JSON;
use Cwd qw( abs_path );
use File::Basename qw( dirname basename );
use lib dirname(abs_path($0));
use StringIterator;

sub write_to_excel {
    my ($output_file, $data_to_write) = @_;
    print "\nWriting output to $output_file ";
    my $workbook = Excel::Writer::XLSX->new($output_file);

    # https://metacpan.org/pod/Excel::Writer::XLSX#add_format(-%25properties-)
    # Format for 'heading' (background - light blue)
    my $header_format = $workbook->add_format(
        border    => 1,
        bg_color  => '#99c2ff',
        bold      => 1,
        text_wrap => 1,
        valign    => 'vcenter',
        align     => 'center',
    );
    my %font = (color  => 'black', valign => 'vcenter', align => 'left', font => 'Calibri', border => 1);

    # Format for a normal text (background - white)
    my $normal_format = $workbook->add_format(%font);

    # Format for error text (background - red)
    my $error_format = $workbook->add_format(%font, bg_color => '#ff0000');

    # Format for success text (background - green)
    my $success_format = $workbook->add_format(%font, bg_color => '#00ff00');

    # Format for neutral text (background - yellow)
    my $neutral_format = $workbook->add_format(%font, bg_color => '#ffff00');

    # Excel column start from 1
    my $row = 1;

    foreach my $key (keys %{$data_to_write}) {
        my $iter      = StringIterator->new();
        my $worksheet = $workbook->add_worksheet($key);
        if ($key eq "Financial Info") {
            my $row_size = scalar @{$data_to_write->{$key}->[6]->{'Profit'}};
            # 'Profit' is in 'G' column or '6'.
            # The data start from (1, 6) to (no of elements, 6)
            # If the value is greater than 0, apply the success format
            $worksheet->conditional_formatting(1, 6, $row_size, 6,
                {
                    type     => 'cell',
                    criteria => 'greater than',
                    value    => 0,
                    format   => $success_format
                }
            );
            # If the value is equal to 0, apply the neutral format
            $worksheet->conditional_formatting(1, 6, $row_size, 6,
                {
                    type     => 'cell',
                    criteria => 'equal to',
                    value    => 0,
                    format   => $neutral_format
                }
            );
            # If the value is less than 0, apply the error format
            $worksheet->conditional_formatting(1, 6, $row_size, 6,
                {
                    type => 'cell',
                    criteria => 'less than',
                    value => 0,
                    format => $error_format
                }
            );
            # 'Unit Sold' is in 'E' column or '4'.
            # The data start from (1, 4) to (no of elements, 4)
            # If the value is greater than 1600, apply the success format
            $worksheet->conditional_formatting(1, 4, $row_size, 4,
                {
                    type => 'cell',
                    criteria => '>',
                    value => 1600,
                    format => $success_format
                }
            );

            # Add a column chart
            # https://metacpan.org/pod/Excel::Writer::XLSX#add_chart(-%properties-)
            my $chart = $workbook->add_chart(type => 'column', name => 'chart', embedded => 1);

            # https://metacpan.org/pod/Excel::Writer::XLSX::Chart#add_series()
            # ranges: [ $sheetname, $row_start, $row_end, $col_start, $col_end ]
            $chart->add_series(
                name       => "Unit Sold",
                categories => ["Financial Info", 1, $row_size, 2, 4],
                values     => ["Financial Info", 1, 4, $row_size, 4],
                line       => {color => 'blue'},
            );

            # https://metacpan.org/pod/Excel::Writer::XLSX#insert_chart(-$row,-$col,-$chart,-%7B-%25options-%7D-)
            $worksheet->insert_chart('J2', $chart);
        }

        # Column A width set to 20
        $worksheet->set_column('A:A', 20);

        # Add a table to the worksheet.
        if (@{$data_to_write->{$key}}) {
            foreach my $element (@{$data_to_write->{$key}}) {
                foreach my $header (keys %{$element}) {
                    my $column_initial = $iter->get_next;

                    $worksheet->write($column_initial . $row, $header, $header_format);
                    $worksheet->write_col($column_initial . ($row + 1),
                        $element->{$header}, $normal_format);
                }
            }
        }
    }

    $workbook->close();
    print "\nFinished writing to file : $output_file";
    return 1;
}

sub read_json_file {
    my ($json_file) = @_;
    print "\nReading $json_file";

    open(my $in, '<', $json_file) or die "Unable to open file $json_file : $!";
    my $json_text = do { local $/ = undef; <$in>; };
    close($in) or die "Unable to close file : $!";

    my $config_data = decode_json($json_text);
    return ($config_data);
}

sub main() {
    my $output_file = "out.xlsx";
    my $data        = read_json_file("data.json");

    write_to_excel($output_file, $data);
}

main();
