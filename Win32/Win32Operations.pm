package Win32Operations;
use strict;
use warnings;
use File::Basename;
use Win32::GuiTest qw/:ALL/;

sub new {
    my $class = shift;
    my ($self) = {@_};
    bless $self, $class;
    return $self;
}

# The system restricts which processes can set the foreground window.
# A process can set the foreground window only if one of the following conditions is true:
# 1. The process is the foreground process.
# 2. The process was started by the foreground process.
# 3. The process received the last input event.
# 4. There is no foreground process.
# 5. The foreground process is being debugged.
# 6. The foreground is not locked.
# 7. The foreground lock time-out has expired.
# 8. No menus are active.
# Please keep these in mind. Otherwise this function will fail.
sub _bring_window_to_front {
    my ($self, $window, $retry_attempts, $pause_between_operations) = @_;
    my $success = 1;
    my $count   = 0;
    while ($count < $retry_attempts) {
        $count++;
        if (SetActiveWindow($window)) {
            $self->{'logger'}->info("* Successfully set the window id: $window active");
        }
        else {
            $self->{'logger'}->warn("* Could not set the window id: $window active: $!");
            $success = 0;
        }
        if (SetForegroundWindow($window)) {
            $self->{'logger'}->info("* Window id: $window brought to foreground");
        }
        else {
            $self->{'logger'}->warn("* Window id: $window could not be brought to foreground: $!");
            $success = 0;
        }
        sleep $pause_between_operations;
        my $foreground_window_id = GetForegroundWindow();
        if ($foreground_window_id =~ /$window/i) {
            last;
        }
        else {
            $self->{'logger'}->info(
                "Found - $foreground_window_id instead of expected - $window. Will try again...");
            next;
        }
    }
    return $success;
}

sub _wait_for {
    my ($self, $title, $wait_time) = @_;
    my $win;
    while (1) {
        ($win) = FindWindowLike(0, $title);

        #($win) = WaitWindow ("^$title", 2);
        if (defined $win) {
            $self->{'logger'}->info("Found window with title : $title.");
            last;
        }
        else {
            $self->{'logger'}->info("Unable to find window with title : $title. Retrying...");
            sleep $wait_time;
        }
    }
    return $win;
}

sub _keys_press {
    my ($self, $keys_to_press, $pause_between_keypress) = @_;

    # start key "pressing" on keyboard
    foreach my $key (@$keys_to_press) {
        SendKeys($key);
        sleep $pause_between_keypress;
    }
}

sub start_explorer_operations {
    my ($self, $root_directory, $filename_to_open, $max_retry_attempts) = @_;
    my $explorer = "%windir%\\explorer.exe";
    $root_directory =~ s/\//\\/g;

    # seconds to spend between key presses
    my $key_press_delay = 1;

    # this is the interval the tester sleeps before checking/closing
    # any window; this is just for an eye effect so we can
    # watch what happens
    my $wait_time_for_windows = 3;

    my $count = 0;
    while ($count < $max_retry_attempts) {
        $count++;
        $self->{'logger'}->info("Opening dir: $root_directory in windows explorer");
        my $status_code = system($explorer , "$root_directory");
        if ($status_code == -1) {
            $self->{'logger'}->error(
                "Unable to open 'explorer.exe' with mentioned dir : $root_directory. Exited with return code :"
                    . $status_code);
            next;
        }
        elsif ($status_code & 127) {
            $self->{'logger'}->error("Child died with signal : " . ($status_code & 127));
            next;
        }
        else {
            my $window = $self->_wait_for(basename($root_directory), $wait_time_for_windows);
            $self->{'logger'}->info("Opened 'explorer.exe'. Window id : $window");
            $self->_bring_window_to_front($window, $max_retry_attempts, $wait_time_for_windows);
            $self->{'logger'}->info("Opening the file in Notepad++...");
            # 'N is to select Notepad++ in right click window.
            # Replace it with your own application shortcut if you are using something othe application'
            my @keys = ("$filename_to_open", "{APP}", "N", "{ENTER}");
            $self->_keys_press(\@keys, $key_press_delay);

            $self->{'logger'}->info("Opened the file in Notepad++. Closing it...");
            my $opened_explore_window = $self->_wait_for($filename_to_open, $wait_time_for_windows);
            if (!$opened_explore_window) {
                $self->{'logger'}->warn("Cannot find window with title/caption $filename_to_open");
                next;
            }
            else {
                $self->{'logger'}
                    ->info("Window handle of $filename_to_open is " . $opened_explore_window);
                print $opened_explore_window;
                $self->_bring_window_to_front($opened_explore_window, $max_retry_attempts,
                    $wait_time_for_windows);
                $self->{'logger'}->info("Closing Notepad++ window...");
                MenuSelect("&Close", 0, GetSystemMenu($opened_explore_window, 0));
                $self->{'logger'}->info("Bringing Explorer window to front...");
                $self->_bring_window_to_front($window, $max_retry_attempts, $wait_time_for_windows);
                $self->{'logger'}->info("Closing Explorer window...");

                # There are different way to close windows File explorer -
                # 1. Alt+F4 (Will close anything on the top - little risky)
                # 2. Alt+F, then C
                # 3. CTRL+w (only closes the current files you're working on but leaves the program open)
                SendKeys("^w");
                return 1;
            }
        }
    }
}

1;
