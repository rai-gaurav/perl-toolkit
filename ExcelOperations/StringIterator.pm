package StringIterator;
use strict;
use warnings;

sub new {
    my ($class, @arguments) = @_;
    my %self = @arguments;
    if (!exists $self{set}) {
        $self{set} = ["A" .. "Z"];
    }
    if (!exists $self{value}) {
        $self{value} = -1;
    }
    $self{size} = @{$self{set}};

    return bless \%self, $class;
}

sub increment {
    my $self = shift;
    return $self->{value}++;
}

sub get_current {
    my $self = shift;
    my $n    = $self->{value};
    my $size = $self->{size};
    my $s    = "";

    while ($n >= $size) {
        my $offset = $n % $size;
        $s = $self->{set}[$offset] . $s;
        $n /= $size;
    }
    $s = $self->{set}[$n] . $s;

    return $s;
}

sub get_next {
    my $self = shift;
    $self->increment;
    return $self->get_current;
}

1;
