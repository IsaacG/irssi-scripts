#
# Print everything in a url window. Ripped off of the hilightwin script by Timo Sirainen. Idea from FauxFaux:
# by Isaac Good
#

use Irssi;
use POSIX;
use vars qw($VERSION %IRSSI); 

$VERSION = "0.01";
%IRSSI = (
    authors     => "Timo \'cras\' Sirainen, Mark \'znx\' Sangster, Isaac Good",
    contact     => "tss\@iki.fi, znxster\@gmail.com, irssi\@isaac.otherinbox.com", 
    name        => "allwin",
    description => "Print everything to window named \"all\"",
    license     => "Public Domain",
    url         => "http://irssi.org/",
    changed     => "1290189792" # localtime that
);

sub event_action {
    my ($server, $data, $nick, $address, $target) = @_;
    do_allwin($server, $target, "* $data", $nick);
}
sub event_privmsg {
    my ($server, $data, $nick, $address) = @_;
    my ($target, $msg) = split(/ :/, $data, 2);
    do_allwin($server, $target, "| $msg", $nick);
}
sub do_allwin
{
    my($server, $target, $msg, $nick) = @_;
    my $isQuery = $server->{nick} eq $target ? 1 : 0;
    my $rnum = $isQuery ? $server->window_find_item($nick) : $server->window_find_item($target);
    $rnum = $rnum ? $rnum->{'refnum'} : 0;

	my @filter = split (/,/, Irssi::settings_get_str('allwin_filter'));
    return if (grep {$rnum == $_} @filter);

    $window = Irssi::window_find_name('all');
    return unless ($window);
    my $message = sprintf("%s%2d %-25.25s\00312\017%s", getcolor($rnum), $rnum, 
        $isQuery ? sprintf("\00313\00313%s", $nick) : sprintf("%s%.10s:\00312%s", getcolor(dohash($target)), $target, $nick), $msg);
    $window->print($message, MSGLEVEL_CLIENTCRAP);
}

sub dohash
{
    my $sum = 0;
    map { $sum += ord($_) } split(//, lc(shift));
    return $sum;
}

sub getcolor
{
    my $num = shift;
    @colors = (0, 2..11, 15); # Exclude (1, 14 -> black) and (12 -> nicks) and (13 -> privmsg)
    return sprintf("\003%02d", $colors[$num % ($#colors +1)]);
}

$window = Irssi::window_find_name('all');
Irssi::print("Create a window named 'all'") if (!$window);

Irssi::signal_add_last("event privmsg", "event_privmsg");
Irssi::signal_add_last("message irc action", "event_action");
Irssi::settings_add_str('misc', 'allwin_filter', '');

# vim:set ts=4 sw=4 et:
