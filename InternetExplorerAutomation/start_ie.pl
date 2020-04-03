
use strict;
use warnings;

use Log::Log4perl;
use Cwd qw( abs_path );
use File::Basename qw( dirname basename );

BEGIN {
    $ENV{"SCRIPT_DIR"} = dirname(abs_path($0));
}

use lib $ENV{"SCRIPT_DIR"} . "/";
use UriOperations;

sub initialize_logger {

    # initialize logger, you can put this in config file also
    my $conf = qq(
            log4perl.category                  = INFO, Logfile, Screen

            log4perl.appender.Logfile          = Log::Log4perl::Appender::File
            log4perl.appender.Logfile.filename = ie_automation.log
            log4perl.appender.Logfile.mode      = write
            log4perl.appender.Logfile.autoflush = 1
            log4perl.appender.Logfile.buffered  = 0
            log4perl.appender.Logfile.layout   = Log::Log4perl::Layout::PatternLayout
            log4perl.appender.Logfile.layout.ConversionPattern = [%d{ISO8601} %p] [%r] (%F{2} line %L)> %m%n

            log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
            log4perl.appender.Screen.stderr  = 0
            log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
        );
    Log::Log4perl->init(\$conf);
    my $logger = Log::Log4perl->get_logger;
    $Log::Log4perl::DateFormat::GMTIME = 1;
    return $logger;
}

my $uri_op = UriOperations->new("logger" => initialize_logger());

$uri_op->open_url_in_bowser("http://www.google.com");
