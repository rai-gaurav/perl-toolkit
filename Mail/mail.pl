use strict;
use warnings;
use JSON;
use SendMail;


sub read_json_file {
    my ($self, $json_file) = @_;
    print "Reading $json_file";

    open (my $in, '<', $json_file) or print "Unable to open file $json_file : $!";
    my $json_text = do { local $/ = undef; <$in>; };
    close ($in) or print "Unable to close file : $!";

    my $config_data = decode_json($json_text);
    return ($config_data);
}

read_json_file("config.json");

my $mail = SendMail->new("config" => $config);

my $mail_parameters = "<param which you want to substitute in mail template>";
my $attachments = "<path to mail attachments>";
my $mail_template = "<path to mail template>";

print "Generating HTML template for mail body";
my $template = $mail->generate_mail_template($mail_template, $mail_parameters);

print "Creating mail with body and attachments to send";
my $mail_subject = "Test Mail";
my $email = $mail->create_mail($attachments, $mail_subject, $template->output);

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
