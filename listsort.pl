use Irssi;
use vars qw/$VERSION %IRSSI/;

$VERSION = '0.1';
%IRSSI = (
    authors     => 'Isaac Good',
    name        => 'listsort',
    contact     => 'irssi@isaacgood.com',
    decsription => 'Sort the /list output by channel size',
    license     => 'BSD',
    url         => 'https://github.com/IsaacG/irssi-scripts',
    created     => '2013/02/23',
);

# Bindings
Irssi::signal_add_last( 'event 322', \&list_event );
Irssi::signal_add_last( 'event 323', \&list_end );
Irssi::signal_add_last( 'notifylist event', \&list_start );

my %list;

sub list_start {
	%list = {};
}

sub list_event {
    my ( $server, $data, $server_name ) = @_;
	my ( $meta, $more ) = split ( / :/, $data, 2 );
	my ( $nick, $name, $size ) = split ( / /, $meta, 3 );
	$list{ $name }{'size'} = $size;

	$more =~ /^[^[]*\[([^]]*)\][^ ]* *([^ ].*)$/;
	my $modes = $1;
	$list{ $name }{'desc'} = $2;

	$modes =~ s/ +$//;
	$list{ $name }{'modes'} = $modes;
}

sub list_end {

	for my $name ( sort { $list{ $a }{'size'} <=> $list{ $b }{'size'} } keys %list ) {
		my $msg = sprintf (
			"%d %s: %s (%s)",
			$list{ $name }{'size'},
			$name,
			$list{ $name }{'desc'},
			$list{ $name }{'modes'}
		);

		Irssi::print ( $msg, MSGLEVEL_CRAP );
	}
}

