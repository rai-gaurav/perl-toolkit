
use strict;
use warnings;
use URIOperations;

my $uri_op = URIOperations->new( "logger" => "<log4perl object>" );

$uri_op->open_url_in_bowser("http://www.google.com");
