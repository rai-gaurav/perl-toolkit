use strict;
use warnings;
use Log::Log4perl;

use Win32Operations;

sub initialize_logger {

    # initialize logger, you can put this in config file also
    my $conf = q(
            log4perl.category.Foo.Bar          = INFO, Logfile, Screen

            log4perl.appender.Logfile          = Log::Log4perl::Appender::File
            log4perl.appender.Logfile.filename = win32op.log
            log4perl.appender.Logfile.mode      = write
            log4perl.appender.Logfile.autoflush = 1
            log4perl.appender.Logfile.buffered  = 0
            log4perl.appender.Logfile.layout   = Log::Log4perl::Layout::PatternLayout
            log4perl.appender.Logfile.layout.ConversionPattern = [%r] %F %L %m%n

            log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
            log4perl.appender.Screen.stderr  = 0
            log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
        );
    Log::Log4perl->init(\$conf);
    my $logger = Log::Log4perl->get_logger;
    $Log::Log4perl::DateFormat::GMTIME = 1;
    return $logger;
}

my $logger    = initialize_logger();
my $win32_obj = Win32Operations->new("logger" => $logger);


# This will open the given dir in windows explorer
# Right click on the given filename and open it in Notepad++ and then close it.
my $input_dir          = "C:/Perl64/lib";
my $filename_to_open   = "strict.pm";
my $max_retry_attempts = 5;

$win32_obj->start_explorer_operations($input_dir, $filename_to_open, $max_retry_attempts);

