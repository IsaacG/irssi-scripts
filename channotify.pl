use warnings;
use strict;
 
use Irssi;
 
use vars qw($VERSION);
our $VERSION = 1.00;
 
use vars qw(%IRSSI);
%IRSSI = (
  name        => 'channotify',
  authors     => 'Isaac Good',
  contact     => 'irssi@isaacgood.com',
  url         => 'https://www.github.com/IsaacG',
  license     => 'Perl',
  description => 'Filter notify list by people in a channel with you',
);

sub cmd_channotify
{
	my (%on, %care);
	for my $nick (map {$_->{nick}} (map {$_->nicks} Irssi::channels()))
	{
		$on{$nick} = 1
	}
	for my $notify (map {$_->{mask}} Irssi::Irc::notifies())
	{
		$care{$notify} = 1 if $on{$notify}
	}
	Irssi::print("People on your channels: " . join ", ", keys %care)
}

Irssi::command_bind("channotify", "cmd_channotify"); 

