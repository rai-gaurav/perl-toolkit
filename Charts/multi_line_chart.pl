#!/usr/bin/env perl

use strict;
use warnings;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use JSON;

BEGIN {
    $ENV{"SCRIPT_DIR"} = dirname(abs_path($0));
}

use lib $ENV{"SCRIPT_DIR"} . "/lib";
use CreateCharts;

my $chart_out_file = $ENV{"SCRIPT_DIR"} . "/output/lineChart.png";

sub read_json_file {
    my ($json_file) = @_;
    print "\nReading $json_file";

    open(my $in, '<', $json_file) or print "Unable to open file $json_file : $!";
    my $json_text = do { local $/ = undef; <$in>; };
    close($in) or print "\nUnable to close file : $!";

    my $config_data = decode_json($json_text);
    return ($config_data);
}

sub main {
    my $data_in_json = read_json_file($ENV{"SCRIPT_DIR"} . "/input/input_data.json");

    my $chart = CreateCharts->new();
    $chart->generate_chart($chart_out_file, $data_in_json);
}

main;
