use strict;
use warnings;
use JSON;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use SendMail;

sub read_json_file {
    my ($json_file) = @_;
    print "Reading $json_file";

    open(my $in, '<', $json_file) or print "Unable to open file $json_file : $!";
    my $json_text = do { local $/ = undef; <$in>; };
    close($in) or print "Unable to close file : $!";

    my $config_data = decode_json($json_text);
    return ($config_data);
}

my $config = read_json_file("config.json");

my $mail = SendMail->new("config" => $config->{'mail'});

# param which you want to substitute in mail template
my $mail_parameters = "NAME => 'Gaurav', LOCATION => 'INDIA'";

# path to mail attachments
my $attachments = [];

# path to mail template
my $mail_template = "mail_template/template.html";

print "Generating HTML template for mail body";
my $template = $mail->generate_mail_template($mail_template, $mail_parameters);

print "Creating mail with body and attachments to send";
my $mail_subject = "Test Mail";
my $email        = $mail->create_mail($attachments, $mail_subject, $template->output);

print "Sending email...";
my ($mail_return_code, $mail_exception) = $mail->send_mail($email);

if (defined $mail_exception) {
    print "Exception while sending mail: $mail_exception";
    return 0;
}
else {
    print "Mail Sent successfully";
    return 1;
}
