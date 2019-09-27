#!/usr/bin/env perl
# This script is used to delete older fiels and folder from a given dir
# There is an option for 'dry-run' where you can cross verify what will be deleted
# It can recursively delete files and folder both on windows and nix platform
use strict;
use warnings;
use Getopt::Long;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use File::Find::Rule;
use File::Path qw( remove_tree );

BEGIN {
    $ENV{"SCRIPT_DIR"} = dirname(abs_path($0));
    # For Windows
    $ENV{"SCRIPT_DIR"} =~ s/\\/\//g;
}

my ($dry_run, $help);

sub usage {
    print "Usage: $0 [-d <dry run>(1|0)]\n";
    exit 0;
}

sub process_parameters {
    if (@ARGV > 0) {
        GetOptions('dryrun|d:s' => \$dry_run,
                    'help|h|?' => \$help
        ) or die usage;
    }
    usage if ($help);

    if (!defined $dry_run) {
        $dry_run = 0;
    }
    return 1;
}

sub main {
    process_parameters;

    # purge data files older than 'age' in days
    my $now             = time();
    my $days            = 5;
    my $seconds_per_day = 60 * 60 * 24;
    my $age             = $days * $seconds_per_day;

    # Location of directories where we want to purge files
    my @root_directories = ($ENV{"SCRIPT_DIR"} . "/input/", $ENV{"SCRIPT_DIR"} . "/output/");
    my @log_directories  = ($ENV{"SCRIPT_DIR"} . "/logs/");

    # We are only purging directory which match with date format (here -'YYYY-MM-DD') in the given @root_directories
    # You can change it with your own ,matching regex
    my @dirs = File::Find::Rule->new->maxdepth(1)->directory->name(qr /\d{4}-\d{2}-\d{2}/)->in(@root_directories);

# We are only purging log files which match with date format 'YYYY-MM-DD' in the given @log_directories
    my @log_dirs = File::Find::Rule->new->file()->name(qr /\d{4}-\d{2}-\d{2}/)->in(@log_directories);

    for my $dir (@dirs, @log_dirs) {
        my @stats = stat($dir);
        if ($now - $stats[9] > $age) {
            if (!$dry_run) {
                my $removed_count = remove_tree(
                    $dir,
                    {
                        verbose => 1,
                        error   => \my $err_list,
                        safe    => 1,
                        result  => \my $list,
                        keep_root => 0    # Make it 1 if you want to keep initially specified directories
                    }
                );

                if (@$err_list) {
                    for my $diag (@$err_list) {
                        my ($file, $message) = %$diag;
                        if ($file eq '') {
                            print "General error: $message\n";
                        }
                        else {
                            print "Problem unlinking $file: $message\n";
                        }
                    }
                }
                else {
                    print "No error encountered while removing $dir\n";
                }
                print "Unlinked $_\n" for @$list;
            }
            else {
                print "\n Unlinked $dir...";
            }
        }
    }
    return 1;
}

main;
