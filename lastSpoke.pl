#!/usr/bin/perl

use strict;
use warnings;
use Irssi;
use POSIX;
use Data::Dumper 'Dumper';
use vars qw($VERSION %IRSSI); 

$VERSION = "0.01";
%IRSSI = (
    authors     => "Isaac Good",
    contact     => "irssi\@isaacgood.com",
    name        => "lastSpoke",
    description => "Track when a user last spoke in a channel",
    license     => "Public Domain",
);

my %lastSpoke;

sub event_privmsg {
    my ($server, $data, $nick, $address) = @_;
    my ($target, $msg) = split(/ :/, $data, 2);

	$lastSpoke{ lc( $target ) }{ lc( $nick ) } = time;
}

sub event_action {
    my ($server, $data, $nick, $address, $target) = @_;
	$lastSpoke{ lc( $target ) }{ lc( $nick ) } = time;
}

sub checkLastSpoke
{
	my ( $nick, $server, $channelItem ) = @_;
	$nick =~ / *$/;

	if ( not ref ( $channelItem ) eq 'Irssi::Irc::Channel' )
	{
		Irssi::active_win()->print( "You need to run that command in a channel" );
		return;
	}

	my $nickL = lc( $nick );
	my $channel = lc( $channelItem->{'name'} );

	if ( not defined( $lastSpoke{ $channel } ) )
	{
		Irssi::active_win()->print( "I don't have any info for this channel" );
		return;
	}
	if ( not defined( $lastSpoke{ $channel }{ $nickL } ) )
	{
		Irssi::active_win()->print( "I don't have any info for that user" );
		return;
	}

	my $last = $lastSpoke{ $channel }{ $nickL };
	my $elapsed = time - $last;

	my $message = sprintf(
		"%s last spoke in this channel %d:%02d:%02d ago", 
		$nick,
		int( ( $elapsed / 60 ) / 60 ),
		int( ( $elapsed / 60 ) % 60 ),
		int( ( $elapsed % 60 ) % 60 )
	);
	Irssi::active_win()->print( $message );

}

Irssi::command_bind( 'lspoke', \&checkLastSpoke );

Irssi::signal_add_last( "event privmsg", "event_privmsg" );
Irssi::signal_add_last( "message irc action", "event_action" );

# vim:set ts=4 sw=4 et:
