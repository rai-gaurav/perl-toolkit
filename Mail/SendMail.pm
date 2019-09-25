package SendMail;
use strict;
use warnings;
use HTML::Template;
use Email::MIME;
use Email::Sender::Simple qw( sendmail );
use Email::Sender::Transport::SMTP;
use IO::All;
use File::Basename qw( basename );

sub new {
    my ( $class, @arguments ) = @_;
    my $self = {@arguments};
    bless $self, $class;
    return $self;
}

sub generate_mail_template {
    my ( $self, $filename, $parameters ) = @_;

# create mail body template. We don't want to die/exit if any of the parameters is missing
    my $template = HTML::Template->new( filename => $filename, die_on_bad_params => 0 );
    $template->param($parameters);
    return $template;
}

sub create_mail {
    my ( $self, $file_attachments, $mail_subject, $mail_body ) = @_;

    my @mail_attachments;
    foreach my $attachment (@$file_attachments) {
        my $single_attachment = Email::MIME->create(
            attributes => {
                filename     => basename($attachment),
                content_type => "application/json",
                disposition  => 'attachment',
                encoding     => 'base64',
                name         => basename($attachment)
            },
            body => io->file($attachment)->all
        );
        push( @mail_attachments, $single_attachment );
    }

    # Multipart message : It contains attachment as well as html body
    my @parts = (
        @mail_attachments,
        Email::MIME->create(
            attributes => {
                content_type => 'text/html',
                encoding     => 'quoted-printable',
                charset      => 'US-ASCII'
            },
            body_str => $mail_body,
        ),
    );

    my $mail_to_users    = join ', ', @{ $self->{config}->{mail_to} };
    my $cc_mail_to_users = join ', ', @{ $self->{config}->{mail_cc_to} };

    my $email = Email::MIME->create(
        header => [
            From    => $self->{config}->{mail_from},
            To      => $mail_to_users,
            Cc      => $cc_mail_to_users,
            Subject => $mail_subject,
        ],
        parts => [@parts],
    );
    return $email;
}

sub send_mail {
    my ( $self, $email ) = @_;
    my $transport = Email::Sender::Transport::SMTP->new(
        {
            host => $self->{config}->{smtp_server}
        }
    );
    eval { sendmail( $email, { transport => $transport } ); };
    if ($@) {
        return 0, $@;
    }
    else {
        return 1;
    }
}

1;
