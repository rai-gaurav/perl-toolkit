
package AWS::S3;
use strict;
use warnings;
use File::Basename;

sub new {
    my ($class, @arguments) = @_;
    my ($self) = {@arguments};
    bless $self, $class;
    $self->_initialize;
    return $self;
}

sub _initialize {
    my ($self) = @_;
    $self->{key} = $self->{config}->{key} . "/" . $self->{date};
    return $self->{key};
}

sub _key {
    my ($self) = @_;
    return $self->{key};
}

sub _bucket {
    my ($self) = @_;
    return $self->{config}->{bucket};
}

# Upload direcory content or a single file to S3
sub upload_to_S3 {
    my ($self, $input) = @_;
    my $upload_output;

    if (-d $input) {
        my $cmd = "aws s3 sync " . $input . " s3://" . $self->_bucket . "/" . $self->_key . "/";
        $self->{'logger'}->info("Executing '$cmd'");
        eval { $upload_output = `$cmd`; };
        if ($@) {
            $self->{'logger'}->error("Caught Exception while uploading directory to S3: $@");
        }
        else {
            $self->{'logger'}->info("Files uploaded successfully from dir : $input");
            $self->{'logger'}->debug($upload_output);
        }
    }
    elsif (-f $input) {
        my $filename = fileparse($input);
        my $cmd
            = "aws s3 cp "
            . $input
            . " s3://"
            . $self->_bucket . "/"
            . $self->_key . "/"
            . $filename;
        $self->{'logger'}->info("Reading the file : $input\n\n");
        $self->{'logger'}->info("Executing '$cmd'");
        eval { $upload_output = `$cmd`; };
        if ($@) {
            $self->{'logger'}->error("Caught Exception while uploading file to S3: $@");
        }
        else {
            $self->{'logger'}->info("File uploaded successfully : $input");
            $self->{'logger'}->debug($upload_output);
        }
    }
    else {
        $self->{'logger'}->error(
            "$input is neither a directory nor a file. Please provide a proper directory or file to upload to S3"
        );
    }
    return $upload_output;
}

# Download file to local machine
sub download_from_S3 {
    my ($self, $output) = @_;
    my $dwnld_output;

    if (-d $output) {
        my $cmd = "aws s3 sync s3://" . $self->_bucket . "/" . $self->_key . "/" . " " . $output;
        $self->{'logger'}->info("Executing '$cmd'");
        eval { $dwnld_output = `$cmd`; };
        if ($@) {
            $self->{'logger'}->error("Caught Exception while downloading directory from S3: $@");
        }
        else {
            $self->{'logger'}->info("File downloaded successfully from dir: $output");
            $self->{'logger'}->debug($dwnld_output);
        }
    }
    else {
        my $filename = fileparse($output);
        my $cmd
            = "aws s3 cp s3://"
            . $self->_bucket . "/"
            . $self->_key . "/"
            . $filename . " "
            . $output;
        $self->{'logger'}->info("Executing '$cmd'");
        eval { $dwnld_output = `$cmd`; };
        if ($@) {
            $self->{'logger'}->error("Caught Exception while downloading file from S3: $@");
        }
        else {
            $self->{'logger'}->info("File downloaded successfully : $output");
            $self->{'logger'}->debug($dwnld_output);
        }
    }
    return $dwnld_output;
}

# List down the keys in bucket
sub get_from_S3 {
    my ($self) = @_;
    my $get_output;
    my $cmd = "aws s3 ls s3://" . $self->_bucket . "/" . $self->_key . "/";
    $self->{'logger'}->info("Executing '$cmd'");
    eval { $get_output = `$cmd`; };
    if ($@) {
        $self->{'logger'}->error("Caught Exception while getting from S3: $@");
    }
    else {
        $self->{'logger'}->info("Listing done successfully");
        $self->{'logger'}->info($get_output);
    }
    return $get_output;
}

# Delete whole directory on S3
sub delete_from_S3 {
    my ($self) = @_;
    my $delete_output;
    my $cmd = "aws s3 rm s3://" . $self->_bucket . "/" . $self->_key . " --recursive";
    $self->{'logger'}->info("Executing '$cmd'");
    eval { $delete_output = `$cmd`; };
    if ($@) {
        $self->{'logger'}->error("Caught Exception while deleting from S3: $@");
    }
    else {
        $self->{'logger'}->info("File deleted successfully");
        $self->{'logger'}->debug($delete_output);
    }
    return $delete_output;
}

1;
