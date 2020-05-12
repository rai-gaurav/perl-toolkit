use strict;
use warnings;
use Win32::GuiTest;

sub open_installed_app {
	my ($app_name) = @_;

	# Handle the special characters in application name
	# This may or may not be needed
	my @special_characters = ('~', '+', '^', '$');
	foreach my $special_char (@special_characters){
		if ($app_name =~ /\Q$special_char\E/){
			$app_name =~ s/(\Q$special_char\E)/{$1}/g;
			last;
		}
	}
	
	# Sleep is just to give a proper effect and time for a application
	# Click Left Windows Key
	Win32::GuiTest::SendKeys("{LWI}");
	sleep 5;
	
	# Type the application name
	Win32::GuiTest::SendKeys("$app_name");
	sleep 5;
	
	# Press Enter
	Win32::GuiTest::SendKeys("{ENTER}");
	sleep 2;
	
	print "Installed application $app_name opened successfully.";
}

sub close_installed_app {
	my ($app_name) = @_;

	# Close opened application by Alt+ F4 as it is on top
	Win32::GuiTest::SendKeys("%{F4}");
	print "Installed application $app_name closed successfully.";
}

sub main {
	my $app_name = "notepad++";
	open_installed_app($app_name);
	close_installed_app($app_name);
}

main;
