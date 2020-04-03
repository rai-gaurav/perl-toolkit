use strict;
use warnings;
use Log::Log4perl;
use Cwd qw( abs_path );
use File::Basename qw( dirname basename );
use JSON;

BEGIN {
    $ENV{"SCRIPT_DIR"} = dirname(abs_path($0));

    # This is only for Windows machine
    # This is not needed when we are running it manually from powershell or CMD.
    # But when running from 'task schedular' the directory path somehow converts to backslash.
    # This is just to rectify the deed of task schedular(replace backslash with forward slash).
    $ENV{"SCRIPT_DIR"} =~ s/\\/\//g;
}

use lib $ENV{"SCRIPT_DIR"} . "/";
use AWS::S3;

sub initialize_logger {

    # initialize and watch every 10sec
    Log::Log4perl->init_and_watch($ENV{'SCRIPT_DIR'} . '/etc/log4perl.conf', 10);
    my $logger = Log::Log4perl->get_logger;

    # This is to log in UTC time
    $Log::Log4perl::DateFormat::GMTIME = 1;
    return $logger;
}

sub read_json_file {
    my ($json_file) = @_;
    print "Reading $json_file";

    open(my $in, '<', $json_file) or print "Unable to open file $json_file : $!";
    my $json_text = do { local $/ = undef; <$in>; };
    close($in) or print "Unable to close file : $!";

    my $config_data = decode_json($json_text);
    return ($config_data);
}

# Any random date name folder or dir from where you will be uploading or downloading the file
my $date       = "2019-09-22";
my $output_dir = $ENV{'SCRIPT_DIR'} . "/output/" . $date;

my $config = read_json_file($ENV{"SCRIPT_DIR"} . "/etc/aws_config.json");

my $aws_s3
    = AWS::S3->new("logger" => initialize_logger(), "config" => $config->{'aws'}, "date" => $date);

# Upload file to AWS S3
$aws_s3->upload_to_S3($output_dir);

# Download file from AWS S3
$aws_s3->download_from_S3($output_dir);
