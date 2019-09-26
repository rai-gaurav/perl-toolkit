use strict;
use warnings;


# HashAlgorithm choices: MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512
sub get_checksum {
    my ( $path_to_file, $hash_algorithm ) = @_;
    my $checksum;
    my $os = $^O;
    eval {
        if ( -s $path_to_file ) {
            if ( $os =~ /MSWin32/i ) {
                $checksum = (split('\n', `C:/Windows/System32/certutil.exe -hashfile $path_to_file $hash_algorithm`))[1];
            }
            else {
                my $cmd = "/usr/bin/" . lc($hash_algorithm) . "sum $path_to_file";
                $checksum = ( split( ' ', `$cmd` ) )[0];
            }
        }
        else {
            $checksum = "File is empty";
        }
    };
    if ($@) {
        print ("Unable to calculate the $hash_algorithm for $path_to_file : $@");
    }
    return $checksum;
}

# Calculate cheksum of the given file
my $checksum = get_checksum("/home/grai/test.txt", "SHA256");
print $checksum;
