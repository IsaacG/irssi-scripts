use warnings;
use strict;

use Irssi;

use vars qw($VERSION %IRSSI);
$VERSION = '1.0';
%IRSSI = (
    authors     => 'IsaacG',
    name        => 'aspell',
    description => 'aspell wrapper',
);

sub check_line {
	my ($inputline, $guesses) = @_;

	# Strip non-alpha/space and form the command
	$inputline =~ tr/a-zA-Z' //cd;
	my $cmd = "aspell -a <<< \"$inputline\"";
	# Run the command and parse the output. Print the output of an all clear message
	my @results = split(/\n/, `$cmd`);
	shift @results;
	@results = grep {$_ ne "*"} @results;
	Irssi::active_win()->print("spell: $_", MSGLEVEL_CRAP ) for @results;
	Irssi::active_win()->print("spell: Nothing found. All good :)", MSGLEVEL_CRAP ) unless @results;
}

# Read from the input line
sub cmd_spellcheck {
	Irssi::command('SCROLLBACK LEVELCLEAR -level CRAP');
	my $inputline = Irssi::parse_special("\$L");
	check_line($inputline);
}

# Read from the argument list
sub cmd_spell {
	my ($inputline) = @_;
	check_line($inputline);
}


Irssi::command_bind('_spellcheck', 'cmd_spellcheck');
Irssi::command_bind('spell', 'cmd_spell');

1;
