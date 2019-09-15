use strict;
use warnings;

use Excel::Writer::XLSX;
use StringIterator;

sub write_to_excel {
    my ($self, $output_file, $data_to_write) = @_;
    print "Writing output to $output_file ";
    my $workbook = Excel::Writer::XLSX->new( "$output_file" );

    my $error_format = $workbook->add_format(
                            color => 'black',
                            valign  => 'vcenter',
                            align   => 'left',
                            font    => 'Calibri',
                            border  => 1,
                            bg_color  => '#ff0000',
                        );
    my $format = $workbook->add_format(
                    color   => 'black',
                    valign  => 'vcenter',
                    align   => 'left',
                    font    => 'Calibri',
                    border  => 1,
                );
    my $header_format = $workbook->add_format(
                            border    => 1,
                            bg_color  => '#C6EFCE',
                            bold      => 1,
                            text_wrap => 1,
                            valign    => 'vcenter',
                            align     => 'center',
                        );
    my $row = 3;
    foreach my $key (keys %{$data_to_write}) {
        my $iter = StringIterator->new;
        $iter->next;
        my $worksheet = $workbook->add_worksheet($key);
        my $caption = "$key";

        # Column B width set to 60
        $worksheet->set_column( 'B:B', 60 );
        my $coloum_initial = $iter->next;
        # Add a table to the worksheet.
        $worksheet->write( $coloum_initial.($row-1), $key, $header_format);
        $worksheet->write_col( $coloum_initial.$row, $data_to_write->{$key}, $format);
    }
    $workbook->close();
    print "Finished writing to file : $output_file";
    return 1;
}

# Pass your param here
write_to_excel();
