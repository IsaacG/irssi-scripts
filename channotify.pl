use warnings;
use strict;
 
use Irssi;
 
use vars qw($VERSION);
our $VERSION = 1.00;

use Data::Dumper;
 
use vars qw(%IRSSI);
%IRSSI = (
  name        => 'channotify',
  authors     => 'Isaac Good',
  contact     => 'irssi@isaacgood.com',
  url         => 'https://www.github.com/IsaacG',
  license     => 'Perl',
  description => 'Filter notify list by people in a channel with you',
);

sub filter_notify
{
	my @nicks = @_;

	my (%on, %care);
	for my $nick (@nicks)
	{
		$on{$nick} = 1
	}
	for my $notify (map {$_->{mask}} Irssi::Irc::notifies())
	{
		$care{$notify} = 1 if $on{$notify}
	}
	return keys %care;
}

sub cmd_channotify
{
	my @nicks = filter_notify(map {$_->{nick}} (map {$_->nicks} Irssi::channels()));
	Irssi::print("People on your channels: " . join ", ", @nicks);
}

sub cmd_actchan
{
	my $active = Irssi::active_win()->{active};
	if (ref $active ne 'Irssi::Irc::Channel')
	{
		Irssi::print("Active item is not a channel");
		return;
	}
	my @nicks = filter_notify(map {$_->{nick}} $active->nicks);
	Irssi::print("People on your active channel: " . join ", ", @nicks);
}

Irssi::command_bind("channotify", "cmd_channotify"); 
Irssi::command_bind("actchan", "cmd_actchan"); 

