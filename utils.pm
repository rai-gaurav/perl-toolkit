package Utils;
use strict;
use warnings;
use List::Util qw( any first);
use Log::Log4perl;
use JSON::PP;
use Net::IDN::Encode qw(:all);
use IO::Socket::SSL::PublicSuffix;
use URI::Escape;


sub new {
    my ($class, @arguments) = @_;
    my $self = {@arguments};
    bless $self, $class;
    return $self;
}

# initialize your log4perl object
sub initialize_logger {
    my $self = shift;

    # This will read form your config. Put a proper path to your log4perl config
    Log::Log4perl->init_and_watch($ENV{'SCRIPT_DIR'} . '/log4perl.conf', 10);
    my $logger = Log::Log4perl->get_logger;
    $Log::Log4perl::DateFormat::GMTIME = 1;
    $self->{'logger'} = $logger;
    return $self;
}

# Left and right trim the whitspaces
sub trim {
    my ($self, $str) = @_;
    $str =~ s/^\s+|\s+$//g;
    return $str;
}

# Get the index of the value if exist in array
sub get_matching_index {
    my ($self, $array, $value) = @_;
    my ($index) = grep { $array->[$_] eq $value } (0 .. @$array - 1);
    if (defined $index) {
        return $index;
    }
    else {
        return -1;
    }
}

# Delete the value at a particular index in array
sub delete_item {
    my ($self, $array, $index) = @_;
    if ($index >= 0) {

        # this will remove and make it undef, which we don't want
        # return delete $array->[$index];
        return splice @$array, $index, 1;
    }
    else {
        # Wrong index value provided for deletion
        return 0;
    }
}

# Push to array if not exist in array
sub push_to_array {
    my ($self, $array, $value) = @_;
    if ($self->is_exist($array, $value)) {
        return 1;
    }
    else {
        push(@$array, $value);
    }
}

# Check whether a value exist in array or not
sub is_exist {
    my ($self, $array, $value) = @_;

  # grep solution loops through the entire list even if the first element of long list matches.
  # 'any' will short-circuit and quit the moment the first match is found, thus it is more efficient
  # Also its discourage to use smartmatch

    if (any { $_ eq $value } @$array) {
        return 1;
    }
    else {
        return 0;
    }
}

sub is_file_exist {
    my ($self, $filename) = @_;
    if (-e $filename) {
        return 1;
    }
    else {
        return 0;
    }
}

sub is_encoded {
    my ($self, $uri) = @_;
    $uri = $uri // '';

# There is no foolproof or reliable way to check whether url is encoded or not.
# You'll never know for sure if a string is URL-encoded or if it was supposed to have the sequence %2B in it.
# This logic will work if unescaped string will not contain '%'
    if ($uri =~ /(%[\dA-F]{2})+/i) {
        return 1;
    }
    else {
        return 0;
    }
}

# Punycode is a way to represent International Domain Names (IDNs) with the limited character set (A-Z, 0-9) supported by the domain name system.
# e.g. "münich" would be encoded as "mnich-kva".
sub is_punycode {
    my ($self, $uri) = @_;
    $uri = $uri // '';

    # To prevent non-international domain names containing hyphens from being accidentally interpreted as Punycode,
    # international domain name Punycode sequences have a so-called ASCII Compatible Encoding (ACE) prefix, "xn--", prepended.
    # An IDN takes the punycode encoding, and adds a "xn--" in front of it.
    # So "münich.com" would become "xn--mnich-kva.com".
    if ($uri =~ /xn--.+/i) {
        return 1;
    }
    else {
        return 0;
    }
}

# Get domain name from the given url
sub get_domainname {
    my ($self, $hostname) = @_;
    my $ps          = IO::Socket::SSL::PublicSuffix->default;
    my $root_domain = $ps->public_suffix($hostname, 1);
    return $root_domain;
}

# Get a value for a like matching key
sub get_value_for_key_like {
    my ($self, $hash_ref, $key_to_match) = @_;
    my $value = $hash_ref->{(first {m/$key_to_match/} keys %$hash_ref) || ''};
    return $value;
}

# Get your local IP
sub get_local_ip {
    my ($self) = @_;
    $self->{'logger'}->info("Getting the local IP address...");
    my $address = eval { Net::Address::IP::Local->public };
    if ($@) {
        $self->{'logger'}->error("Could not determine IP address : $@");
        return 0;
    }
    else {
        $self->{'logger'}->info("IP : $address");
        return $address;
    }
}

# Get the IP visible to outside world
sub get_public_ip {
    my ($self, $ua) = @_;
    $self->{'logger'}->info("Getting the public IP address...");

    my $url     = 'http://whatismyip.akamai.com/';
    my $address = eval { $ua->get($url)->res->body };
    if ($@) {
        $self->{'logger'}->error("Could not determine public IP address : $@");
        return 0;
    }
    else {
        $self->{'logger'}->info("IP : $address");
        return $address;
    }
}

# Read a JSON file
sub read_json_file {
    my ($self, $json_file) = @_;
    $self->{'logger'}->info("Reading $json_file");

    my $json_text   = $self->slurp_file($json_file);
    my $config_data = decode_json($json_text);
    return ($config_data);
}

# Write to a JSON file (pretty print)
sub write_json_file {
    my ($self, $output_file, $current_summary) = @_;
    $self->{'logger'}->info("Writing output to file: $output_file");

    my $out_json          = JSON::PP->new->ascii->pretty->allow_nonref;
    my $pretty_p_out_json = $out_json->encode($current_summary);
    open my $out_json_fh, ">", $output_file
        or $self->{'logger'}->error("Can't open $output_file for writing: $!\n");
    print $out_json_fh $pretty_p_out_json;
    close $out_json_fh or $self->{'logger'}->warn("Unable to close file : $!");

    $self->{'logger'}->debug($pretty_p_out_json);

    return 1;
}

# Convert file in dos format to unix (needed when you copied file form windows to linux machine)
sub dos2unix {
    my ($self, @filename_list) = @_;
    foreach my $filename (@filename_list) {
        my $exit_code = system('perl', '-p', '-i', '-e' => 's/\r\n/\n/', "$filename");
        if ($exit_code != 0) {
            $self->{'logger'}->error(
                "Unable to convert $filename to unix format. Failed with an exit code of $exit_code."
            );
            exit($exit_code >> 8);
        }
        else {
            $self->{'logger'}->info("$filename converted to unix format successfully!");
        }
    }
    return 1;
}

# Delete all files present in the given directory
sub del_all_files_from_dir {
    my ($self, $dir_name) = @_;
    $self->{'logger'}->info("Deleting all files from directory : $dir_name");
    while (my $file = glob("$dir_name/*")) {
        next if -d $file;
        unlink($file) or $self->{'logger'}->warn("Can't remove $file: $!");
    }
    return 1;
}

# Get all the files present in given directory based on matching criteria
sub get_files_list_in_dir {
    my ($self, $files_directory, $files_matching_criteria) = @_;
    if (!defined $files_matching_criteria) {
        $files_matching_criteria = "*";
    }
    my @files_with_full_path
        = File::Find::Rule->file->name($files_matching_criteria)->in($files_directory);
    return (\@files_with_full_path);
}
