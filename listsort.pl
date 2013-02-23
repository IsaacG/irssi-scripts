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
	my ( $nick, $name, $size, $modes, $desc ) = split ( / /, $data, 5 );
	$list{ $name }{'size'} = $size;
	$list{ $name }{'modes'} = $modes;
	$list{ $name }{'desc'} = $desc;
}

sub list_end {
	for my $name ( sort { $list{ $a }{'size'} <=> $list{ $b }{'size'} } keys %list ) {
		Irssi::print ( sprintf ( "%d: %s (%s)", $list{ $name }{'size'}, $list{ $name }{'desc'}, $list{ $name }{'modes'} ) );
	}
}

