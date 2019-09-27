#!/usr/bin/env perl
# This script is intended to install all the cpan module dependendency automatically (windows and Linux).
# If you want to add/delete any new/old modules, add/delete that to '__DATA__' section.
# Run this only once when setting the environment for first time.
# Run this script as administrator/root or with elevated user rights.

use strict;
use warnings;
use CPAN;

sub configure_cpan {
    my $c = "CPAN::HandleConfig";
    $c->load(doit => 1, autoconfig => 1);
    $c->edit(prerequisites_policy => "follow");
    $c->edit(build_requires_install_policy => "yes");
    $c->commit;
    return 1;
}

sub check_pre_req_package {
    my $package = shift;

    print "\n---> Checking module - $package";
    eval { require $package; };
    if ($@) {
        print "\n---> Error loading module: $@";
    }
    else {
        print "\n---> Package $package is already installed\n";
        return 1;
    }

    my $exit_code;
    print "\n---> Installing $package...";
    eval { $exit_code = system("cpan $package > cpan_installation.log"); };
    if ($@ or $exit_code != 0) {
        print
            "\n---> [ERROR] CPAN installation for $package failed with an exit code of $exit_code. $@";
        print "\n Please try to install $package manually if needed\n";
        return 0;
    }
    else {
        print "\n---> CPAN installation for $package is successfull!\n";
        return 1;
    }
}

sub main {
    my $os_name = $^O;

    print "\nRunning on operating System : " . $os_name . "\n";
    configure_cpan;

    while (my $pre_req_packages = <DATA>) {
        chomp $pre_req_packages;
        next if $pre_req_packages =~ /^\s*$/;
        check_pre_req_package($pre_req_packages);
    }
    return 1;
}

main;


__DATA__

File::Find::Rule
Mojo::UserAgent
Email::Sender
Email::MIME
Log::Log4perl
DateTime
Excel::Writer::XLSX
