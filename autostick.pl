use Irssi;
use POSIX;

use vars qw($VERSION %IRSSI); 
use Data::Dumper;

$VERSION = "0.02";
%IRSSI = (
    authors     => "Isaac Good",
    contact     => "irssi\@isaacgood.com", 
    name        => "autostick",
    description => "Autostick window items on creation",
    license     => "Public Domain",
    url         => "http://irssi.org/",
    changed     => "2015-01-03" # localtime that
);

sub stickme { 
    my ($window, $window_item) = @_;
    Irssi::command("^window stick " . $window->{'refnum'});
}

Irssi::signal_add("window item new", "stickme" );


# vim:set ts=4 sw=4 et:
