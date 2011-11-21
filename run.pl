#
# Run an arbitrary command
# by Isaac Good
#

use Irssi;
use POSIX;
use vars qw($VERSION %IRSSI); 

use Data::Dumper;

my @commands = (
    [ '!trs', '#rss-spam', '~/bin/transmission-status' ],
    [ '!size', '#ttest', 'printf "Items in home dir: "; ls ~/ -1 | wc -l' ],
    [ '!upt', '#ttest', 'uptime' ],
    [ '!demonoid', '#rss-spam', '~/bin/testing' ],
);
$channel = '#ttest';

$VERSION = "0.01";
%IRSSI = (
    authors     => "Isaac Good",
    contact     => "irssi\@isaac.otherinbox.com", 
    name        => "run",
    description => "Run a command via incoming triggers. Like trigger.pl with much less functionality.",
    license     => "Public Domain",
    changed     => "1321296864" # localtime that
);

sub event_privmsg {
    my ($server, $data, $nick, $address) = @_;
    my ($target, $msg) = split(/ :/, $data, 2);
    my ($msg, @args) = split(/\s/, $msg);
    my ($cmd) = grep { $_->[0] eq $msg } @commands;
    return unless (defined $cmd);
    unless (defined Irssi::window_find_item($cmd->[1])) {
        printf("Can not find window %s for trigger %s -> %s", $cmd->[1], $cmd->[0], $cmd->[2]);
        return;
    }
    Irssi::window_find_item($cmd->[1])->command(join(' ', 'exec - -o', $cmd->[2], @args));
}

Irssi::signal_add_last("event privmsg", "event_privmsg");

# vim:set ts=4 sw=4 et:
