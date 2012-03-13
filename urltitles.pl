#!/usr/bin/perl -w

use strict;
use Irssi;
use LWP::UserAgent;

use Data::Dumper;

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


sub message_public {
    my ($server, $msg, $nick, $mask, $target) = @_;

	my ($word, $ws, $title, $response);
	$msg =~ s/^(\s*)//; # Strip leading spaces at the begining of the line
	my $out = $1;
	while ($msg =~ m/\G(\S+)(\s*)/g)
	{
		($word, $ws) = ($1, $2); # word, whitespace
		next unless ($word =~ /^$regex$/g);
		$word = "http://$word" unless ( $word =~ qr(^https?://) );

		eval{ $response = $ua->get($word) };
		next if( $@ or $response->code() != 200 );
		next if( $response->header('content-type') !~ qr{^text/html} );
		$title = $response->title() or next;

		$word = sprintf("'%s' [%s]", $title, $word);
	} continue {
		$out .= $word . $ws;
	}
	Irssi::signal_continue($server, $out, $nick, $mask, $target);
}

Irssi::signal_add('message public', \&message_public);

