use strict;
use warnings;

use MultiCoreEngine;

my $mce = MultiCoreEngine->new( "logger" => <Log4perl object> );

# Pass any data which you want to send and update the .pm accordingly
$mce->start_multicore_engine();
