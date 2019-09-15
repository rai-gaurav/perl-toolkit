use strict;
use warnings;
use CreateCharts qw(generate_chart);


my $chart_out_file = "chart.png";
=for
json data example-
{
	key: [],
	value: {
		Axis1:[],
		Axis2:[],
		Axis3:[]
	}
}
=cut
my $data_in_json;
generate_chart($chart_out_file, $data_in_json);
