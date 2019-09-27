#!/usr/bin/env perl
use strict;
use warnings;
use Schedule::Cron;
use Cwd qw( abs_path );
use File::Basename qw( dirname );

BEGIN {
    $ENV{"SCRIPT_DIR"} = dirname(abs_path($0));
}

# Dispatcher subroutine called from cron
sub dispatcher {
    open(my $cron_out, ">>", "$ENV{'SCRIPT_DIR'}/logs/cron_timestamps.txt");
    print $cron_out "Started Cron Schedular\n";
    print $cron_out "Current: ", scalar(localtime), "\n";
    print $cron_out "Next:    ", scalar(localtime($cron->get_next_execution_time($entry->{time}))), "\n\n";
    close $cron_out;
    return 1;
}


# Create new object with default dispatcher
my $cron = Schedule::Cron->new(\&dispatcher);

# Get all the crontab present in 'crons' dir
while (my $file = glob("$ENV{'SCRIPT_DIR'}/crons/*")) {
    next if -d $file;

    # Load a crontab file
    eval {
        $cron->load_crontab(file => "$file", eval => 1);
    };
    if ($@) {
        print "Error during loading of crontab file $file: $@\n";
    }
}

my $pid_filename = "$ENV{'SCRIPT_DIR'}/logs/cron_scheduler.pid";
if ($pid_filename =~ /^(.*)\/([^\/])+$/) {

    # If logs directory doesn't exist create it
    if (!-d $1) {
        mkdir $1 or die "Error creating directory $1: $!";
    }
}

# Return a list of cron entries found in file. Each entry is a hash ref
# my @entries = $cron->list_entries();

# Get a single cron entry. Since no parameter is given it will get 0th index entry, which we need
my $entry = $cron->get_entry;

# Start scheduler, detach from current process and
# write the PID of the forked scheduler to the specified file
$cron->run(detach => 1, pid_file => $pid_filename);
