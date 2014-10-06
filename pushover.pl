use Irssi;
use POSIX;
use LWP::UserAgent;
use vars qw($VERSION %IRSSI); 

# ==================================

# Throttle messages to not send one if a message was sent in the last "pushover_throttlewindow" seconds,
# considered on a per-nick/channel level. When a message was sent too recently, the new message gets
# put into a queue and is sent along with the next time we do send a message for that key.
my %throttle_data = {};
sub throttler {
    my ($throttle_key, $message) = @_;
    if (not exists $throttle_data{$throttle_key}) {
        $throttle_data{$throttle_key} = {last => time, lines => ()};
        return $message;
    }

    my $last_sent = $throttle_data{$throttle_key}{'last'};

    # Queue the message for sending - now or later
    push @{$throttle_data{$throttle_key}{'lines'}}, $message;
    if ((time - $last_sent) > Irssi::settings_get_int('pushover_throttlewindow')) {
        $to_send = join(' | ', @{$throttle_data{$throttle_key}{'lines'}});
        $throttle_data{$throttle_key}{'lines'} = ();
        $throttle_data{$throttle_key}{'last'} = time;
        return $to_send;
    } else {
        return '';
    }
}

# Check that the Pushover app token and user key was set.
sub keys_missing {
    return if (Irssi::settings_get_str('pushover_apptoken') and 
               Irssi::settings_get_str('pushover_userkey'));
    return 1;
}

# Process the signal data to form the message and send it, modulo the throttler.
sub notify {
    my ($nick, $target, $message, $is_action) = @_;

    my $title = $target;
    my $prepend = "${target}:${nick} ";
    $prepend .= 'said ' unless ($is_action);

    my $throttle_key = $target;
    $throttle_key .= $nick if ($target eq 'PM');
    $t_message = throttler($throttle_key, $message);

    LWP::UserAgent->new()->post(
        'https://api.pushover.net/1/messages.json', [
        'token' => Irssi::settings_get_str('pushover_apptoken'),
        'user' => Irssi::settings_get_str('pushover_userkey'),
        'message' => $prepend . $t_message,
        'title' => $title,
    ]) if ($t_message);
}

# ==================================

# Do we want to send this message via Pushover?
# 1 for yes, 0 for no.
# Filter out some stuff, send hilghts.
sub myMessageFilter
{
    my ( $server, $msg, $nick, $address, $target ) = @_;
    my $me = lc ( $server->{'nick'} );

    return 0 if ( $nick eq $me ); # Self-PM
    return 0 if ( $server->{'tag'} eq 'BitLBee' );
    return 1 if ( ! $target =~ /^#/ ); # PM
    return 1 if ( lc ( $target ) eq lc ( $server->{'nick'} ) );
    return 1 if ( lc ( $msg ) =~ qr/$me/ );

    return 0;
}

# ==================================

sub event_action {
    my ($server, $msg, $nick, $address, $target) = @_;

    return unless myMessageFilter ( $server, $msg, $nick, $address, $target );

    $target = "PM" unless ( $target =~ /^#/ );
    notify($nick, $target, $msg, 1);
}

sub event_privmsg {
    my ($server, $data, $nick, $address) = @_;
    my ($target, $msg) = split(/ :/, $data, 2);

    return unless myMessageFilter ( $server, $msg, $nick, $address, $target );

    $target = "PM" unless ( $target =~ /^#/ );
    notify($nick, $target, $msg, 0);
}

# ==================================

Irssi::signal_add_last("event privmsg", "event_privmsg");
Irssi::signal_add_last("message irc action", "event_action");

Irssi::settings_add_str('misc', 'pushover_userkey', '');
Irssi::settings_add_str('misc', 'pushover_apptoken', '');
Irssi::settings_add_int('misc', 'pushover_throttlewindow', 30);

Irssi::print('You need to set pushover_apptoken and pushover_userkey.') if keys_missing();

# vim:set ts=4 sw=4 et:
