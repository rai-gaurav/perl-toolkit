package MultiCoreEngine;
use strict;
use warnings;
use MCE;

# Called once at the beginning
sub _user_begin {
    my ($mce) = @_;
    $mce->print( "Process Id : " . $mce->pid . " start" );
    return 1;
}

# Called once at the end
sub _user_end {
    my ($mce) = @_;
    $mce->print( "Process Id : " . $mce->pid . " end" );
    return 1;
}

sub _run_parrallel {
    my ($mce) = @_;
    my $counter = $_->[0];

    my $worker_id = MCE->wid;
    $mce->print("Starting worker -> $worker_id (PID: $$) ($counter)...");

    my $cmd_output;
    eval { $cmd_output = `<your program to run>`; };
    if ($@) {
        $mce->print( \*STDERR,
            "Exception while running worker => $counter : $@" );
        return 0;
    }
    else {
        $mce->print("Completed worker -> $worker_id for counter : $counter");
        return 1;
    }
}

sub start_multicore_engine {
    my ($self) = @_;

    my $counter    = 0;
    my @input_data = ();

    # Say we have to run on 10 cores
    # You can push any other data which you want to pass to the script which
    # will be running on multi core
    foreach my $counter ( 0 .. 10 ) {
        push( @input_data, [$counter] );
    }

    # you can set the max_worker as 'auto' which will be number of lcores, max 8
    my $mce = MCE->new(
        max_workers => 10,
        input_data  => \@input_data,
        user_begin  => \&_user_begin,
        user_end    => \&_user_end,
        user_func   => \&_run_parrallel,
        max_retries => 3,
        user_output => sub {
            $self->{logger}->info( $_[0] );
        },
        user_error => sub {
            $self->{logger}->error( $_[0] );
        },
    );
    $mce->run;
}

1;
