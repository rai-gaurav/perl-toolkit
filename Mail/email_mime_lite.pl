#!/usr/bin/env perl

# Please note that this is not the recommended way to send mail in Perl.
# Please use Email::Sender::Simple for sending email.

use strict;
use warnings;
use MIME::Lite;

my $from_email = "your email";
my $to_email = "your email";
my $smtp_server = "your smtp server";

my $msg = MIME::Lite->new (
                'From'      => $from_email,
                'To'        => $to_email,
                'Subject'   => 'Testing',
                'Type'      => 'text/html',
                'Data'      => 'Hey there!!!',
            );

eval {
    $msg->send('smtp', $smtp_server, Debug=> 1);
};
if ($@) {
    print "Failed to send email: $@";
}
else {
    print "Mail Sent.";
}
