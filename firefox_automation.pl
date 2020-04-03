use strict;
use warnings;
use Firefox::Marionette();

my $firefox       = Firefox::Marionette->new(visible => 1);
my $window_handle = $firefox->new_window(type => 'tab', focus => 1);
$firefox->switch_to_window($window_handle);
$firefox->go('https://metacpan.org/');

#say $firefox->html();

# $firefox->find_class('container-fluid')->find_id('search-input')->type('Test::More');

# my $file_handle = $firefox->selfie(highlights => [ $firefox->find_name('lucky') ]);

# $firefox->find('//button[@name="lucky"]')->click();

#$firefox->await(sub { $firefox->interactive() && $firefox->find_partial('Download') })->click();

sleep 5;
