package UriOperations;
use strict;
use warnings;
use Win32::OLE;

sub new {
    my ( $class, @arguments ) = @_;
    my $self = {@arguments};
    bless $self, $class;
    return $self;
}

sub open_url_in_bowser {
    my ( $self, $url ) = @_;
    my $retry_attempts = 5;

    Win32::OLE->Option( Warn => 0 );
    $self->{'logger'}->info("Opening url in browser : $url");

    my $browser = Win32::OLE->GetActiveObject('InternetExplorer.Application');
    if ( !defined $browser ) {
        $self->{'logger'}->info("Can not find open object for browser. Creating one...");
        for my $retry_attempt ( 1 .. $retry_attempts ) {
            eval {
                # sets the app to open (IE)
                $browser = Win32::OLE->new("InternetExplorer.Application")
                  or $self->{'logger'}->logdie( "Could not start Internet Explorer.Application: $! "
                    . Win32::OLE->LastError() );
            };
            if ($@) {
                $self->{'logger'}->info( "Got exception :" . $@ );
                if ( $retry_attempt < $retry_attempts ) {
                    $self->{'logger'}->info("Retrying $retry_attempt time....");

                    #sleeping for 5 sec and will try to start internet explorer
                    sleep 5;
                    next;
                }
                else {
                    $self->{'logger'}->info("Retry attempt exausted. Ignoring url.");
                    return 0;
                }
            }
            else {
                $self->{'logger'}->info("Successfully created open object for browser.");
                last;
            }
        }
    }
    $browser->{visible}              = 1;   # sets whether the action is visible
    $browser->{RegisterAsDropTarget} = 1;
    $browser->{RegisterAsBrowser}    = 1;
    $browser->Navigate($url);               # opens the page

    $self->{'logger'}->info("Given url opened in browser.");

    # Give max 150 sec to IE to load the page (don't want to wait indefinitely)
    my $ie_timeout = 150;

    # Let IE load the page
    while ( $browser->{Busy} && ( $ie_timeout >= 0 ) ) {
        $self->{'logger'}->debug("Browser is busy loading the page. Will try to close after page load.");
        sleep 1;

        # Chill on the system resources with a 500 msec sleep while we wait.
        while ( $browser->SpinMessageLoop() ) {
            select undef, undef, undef, 0.50;
        }
        $ie_timeout--;
    }

    # close the page when done.
    $self->{'logger'}->info("Closing the browser...");
    $browser->Quit();
    return 1;
}

1;
