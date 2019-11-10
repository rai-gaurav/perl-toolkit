use strict;
use warnings;
use DateTime;
use DateTime::Format::Strptime;

sub new {
    my ($class, @arguments) = @_;
    my $self = {@arguments};
    bless $self, $class;
    $self->_initialize_datetime;
    return $self;
}

# Initialize your datetime object
sub _initialize_datetime {
    my $self = shift;
    my $dt   = $self->get_datetime_now;
    $self->{'datetime'} = $dt;
    return $self;
}

# Get current datetime in UTC
sub get_datetime_now {
    my $self = shift;
    my $dt   = DateTime->now;
    $dt->set_time_zone('UTC');
    return $dt;
}

# Get current datetime
sub get_previous_date {
    my ($self, $days, $datetime) = @_;
    my $dt            = $datetime // $self->{'datetime'};
    my $previous_date = $dt->clone->subtract(days => $days)->ymd;
    return $previous_date;
}

# Retrieves date as a string in 'yyyymmdd' format
sub get_current_date_compact_format {
    my ($self, $datetime) = @_;
    my $dt       = $datetime // $self->{'datetime'};
    my $date_now = $dt->ymd('');
    return $date_now;
}

# Retrieves date as a string in 'yyyy-mm-dd' format
sub get_current_date_international_format {
    my ($self, $datetime) = @_;
    my $dt       = $datetime // $self->{'datetime'};
    my $date_now = $dt->ymd;
    return $date_now;
}

# Retrives current time in 'hh:mm:ss' format
sub get_current_time {
    my ($self, $datetime) = @_;
    my $dt   = $datetime // $self->{'datetime'};
    my $time = $dt->hms;
    return $time;
}

# Retrieves time as a string in 'hhmmss' format
sub get_current_time_compact_format {
    my ($self, $datetime) = @_;
    my $dt   = $datetime // $self->{'datetime'};
    my $time = $dt->hms('');
    return $time;
}

# Retrieves date time as a string in 'yyyy-mm-dd hh:mm:ss' format
sub get_current_datetime_international_format {
    my ($self, $datetime) = @_;
    my $dt           = $datetime // $self->{'datetime'};
    my $date         = $self->get_current_date_international_format($dt);
    my $time         = $dt->hms;
    my $datetime_now = $self->get_utc_format($date, $time);
    return $datetime_now;
}

# Retrieves time as a string in 'hh' format as we are processing whole hour data
sub get_current_hour {
    my ($self, $datetime) = @_;
    my $dt   = $datetime // $self->{'datetime'};
    my $hour = $dt->hour;
    return $hour;
}

# Retrieves date time to UTC format
sub get_utc_format {
    my ($self, $date, $time) = @_;
    my $dt_utc_format = $date . "T" . $time;
    return $dt_utc_format;
}

# Retrieves date time in utc format 'yyyy-mm-ddThh:mm:ss' from epoch time
sub get_utc_from_epoch {
    my ($self, $epoch_time) = @_;
    my $dt_utc_format = DateTime->from_epoch(epoch => $epoch_time);
    return $dt_utc_format;
}

# Convert date of format YYYYMMDD to YYYY-MM-DD
sub convert_date_to_international_format {
    my ($self, $date) = @_;
    my $parser = DateTime::Format::Strptime->new(pattern => '%Y%m%d');
    my $ymd    = $parser->parse_datetime($date)->ymd;
    return $ymd;
}

# Convert date of format YYYY-MM-DD to YYYYMMDD
sub convert_date_to_compact_format {
    my ($self, $date) = @_;
    my $parser = DateTime::Format::Strptime->new(pattern => '%Y-%m-%d');
    my $ymd    = $parser->parse_datetime($date)->ymd('');
    return $ymd;
}

# Convert time of format HHMMSS to HH:MM:SS
sub convert_time_to_international_format {
    my ($self, $time) = @_;
    my $parser = DateTime::Format::Strptime->new(pattern => '%H%M%S');
    my $hms    = $parser->parse_datetime($time)->hms;
    return $hms;
}

# Convert time of format HH:MM:SS to HHMMSS
sub convert_time_to_compact_format {
    my ($self, $time) = @_;
    my $parser = DateTime::Format::Strptime->new(pattern => '%H:%M:%S');
    my $hms    = $parser->parse_datetime($time)->hms('');
    return $hms;
}

# get difference between two datetime in seconds
sub get_time_diff_in_seconds {
    my ($self, $datetime1, $datetime2) = @_;
    my $delta = $datetime2->subtract_datetime_absolute($datetime1);
    return $delta->seconds;
}
