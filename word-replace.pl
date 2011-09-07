# Signal stuff stolen from scrmable.pl
# Line processing from shabble's aspell.pl
# `/completion -auto` does this mostly for you

use warnings;
use strict;

use Irssi;

use vars qw($VERSION %IRSSI);
our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'IsaacG',
    name        => 'AutoReplace',
    description => 'Auto replace words with correct words',
);

# INCLUDES
use Config::Tiny;


# GLOBALS
my $dict;

# CODE

# Capture the send text event
sub intercept_send
{
	my ($msg, $server, $witem) = @_;
	Irssi::signal_stop();
	Irssi::signal_remove('send text', 'intercept_send');
	Irssi::signal_emit('send text', word_replace("$msg"), $server, $witem);
	Irssi::signal_add('send text', 'intercept_send');
}

# Repair the text being send
sub word_replace 
{
	my ($inputline) = @_;
	my $output = "";
	while ($inputline =~ m/\G(\S+)(\s*)/g) {
		my ($word, $ws) = ($1, $2); # word, whitespace
		if ($word =~ m/^([[:lower:]])/) 
		{
			$word = $dict->{uc($1)}->{$word} if ($dict->{uc($1)}->{$word});
		}
		$output .= $word . $ws;
	}
	return $output;
}

sub replace_word_add
{
	my ($data, $server, $witem) = @_;
	my ($word, $replace) = split(/\s+/, lc($data), 2);

	if ($word =~ m/^([[:lower:]])/) 
	{
		$dict->{uc($1)}->{$word} = $replace;
		$dict->write(Irssi::get_irssi_dir . '/pxdict.ini') or die "Failed to write dict file: " . $!;
	}
}


# INIT

$dict = Config::Tiny->new;
$dict = Config::Tiny->read(Irssi::get_irssi_dir . '/pxdict.ini') or die "Failed to open dict file: " . $!;

Irssi::signal_add('send text', 'intercept_send');
Irssi::command_bind('replace_add', 'replace_word_add');

1;
