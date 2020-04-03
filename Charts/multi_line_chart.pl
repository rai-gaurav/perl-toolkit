use strict;
use warnings;
use Cwd qw( abs_path );
use File::Basename qw( dirname basename );

BEGIN {
    $ENV{"SCRIPT_DIR"} = dirname(abs_path($0));
}

use lib $ENV{"SCRIPT_DIR"} . "/";
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
