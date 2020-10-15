#!/usr/bin/env perl

# This script can be used to monitor dir to hot reload apache or to perform any
# other side-effect you want in case file/files are changed in directory

use strict;
use warnings;
use File::Find;

# Add comma seperated list of directories here where you want to do hot reload
my @dir_to_search = (".");

# Add list of file extension which you want to monitor in given dir
my @files_ext_to_match = (".pm", ".pl");

my %files;

sub wanted {
    my $all_files_ext = join('|', map { $_ . "\$" } @files_ext_to_match);
    if (-f $File::Find::name && /$all_files_ext/) {
        # Set initial time of each file
        my $orig_change_time = (stat $File::Find::name)[9];
        $files{$File::Find::name} = $orig_change_time;
    }
}

sub main {
    finddepth(\&wanted, @dir_to_search);
    while (1) {
        foreach my $file (keys %files) {
            my $new_change_time = (stat $file)[9];
            if ($files{$file} != $new_change_time) {
                print "\n $file changed.";
                $files{$file} = $new_change_time;
                # Restart apache. Add or modify your side effect here.
                `systemctl restart apache2 2>&1`;
            }
        }
        sleep 5;
    }
}

main;
