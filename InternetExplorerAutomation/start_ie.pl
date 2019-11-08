
use strict;
use warnings;
use UriOperations;
use Log::Log4perl 

my $uri_op = UriOperations->new( "logger" => "<log4perl object>" );

$uri_op->open_url_in_bowser("http://www.google.com");
