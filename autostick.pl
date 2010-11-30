use Irssi;
use POSIX;

use vars qw($VERSION %IRSSI); 
use Data::Dumper;

$VERSION = "0.01";
%IRSSI = (
    authors     => "Isaac Good",
    contact     => "irssi\@isaac.otherinbox.com", 
    name        => "autostick",
    description => "Autostick window items on creation",
    license     => "Public Domain",
    url         => "http://irssi.org/",
    changed     => "1291087764" # localtime that
);

sub stickme { 
    my ($window, $window_item) = @_;
    Irssi::command("window " . $window_item->{'refnum'} . " stick");
}

Irssi::signal_add("window item new", "stickme" );


# vim:set ts=4 sw=4 et:
