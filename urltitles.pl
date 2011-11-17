#!/usr/bin/perl -w

use strict;
use Irssi;
use LWP::UserAgent;

use vars qw($VERSION %IRSSI);

$VERSION = "0.2";
%IRSSI = (
	authors     => 'IsaacG',
	name        => 'urltitles',
	description => 'Prints titles for URLs typed in the channel',
);

my $ua = LWP::UserAgent->new(
	agent    => 'Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.6) Gecko/2009011913 Firefox/3.0.6',
	timeout  => 2,
	max_size => 102400,
);
my $regex   = qr{\b((?:https?://|www\.)[-~=\/a-zA-Z0-9.:_?&%,#+]+)\b};


sub event_privmsg {
    my ($server, $data, $nick, $address) = @_;
    my ($target, $msg) = split(/ :/, $data, 2);

    for my $url ($msg =~ /$regex/g)
    {
		$url = "http://$url" unless ( $url =~ qr(^https?://) );

		my $response;
		eval{ $response = $ua->get($url) };
		return if( $@ or $response->code() != 200 );
		return if( $response->header('content-type') !~ qr{^text/html} );
		my $title = $response->title() or return;
		my $win = Irssi::window_find_item($target) or return;
		$win->print(sprintf("%s [%s]", $title, $url));
	}
}

Irssi::signal_add('event privmsg', \&event_privmsg);

