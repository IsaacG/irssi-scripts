#
# Poll gmail for new emails and display in a gmail window
# by Isaac Good
#

use Irssi;
use POSIX;
require HTML::TokeParser;
use Time::Local;
use vars qw($VERSION %IRSSI); 

$VERSION = "0.01";
%IRSSI = (
    authors     => "Isaac Good",
    contact     => "irssi\@isaac.otherinbox.com", 
    name        => "gmailwin",
    description => "Poll gmail for new emails and display in a gmail window",
    license     => "Public Domain",
    url         => "http://irssi.org/",
    changed     => "1291057023" # localtime that
);

my ($timertag, $lastcheck) = (undef, 0);

sub gmail_login
{
    my ($input, $server, $window) = @_;
    my ($username, $password) = split(/\s+/, $input);
    return Irssi::print('Usage: /gmail_login address@gmail.com password', MSGLEVEL_CLIENTCRAP) unless ($username and $password);
    gmail_stop();
    check_gmail([$username, $password]);
    $timertag = Irssi::timeout_add(Irssi::settings_get_time("gmail_time"), check_gmail, [$username, $password]);
}

sub gmail_stop
{
    return unless ($timertag);
    Irssi::timeout_remove($timertag);
    $timertag = undef;
}

sub check_gmail
{
    my $data = shift;
    my ($username, $password) = @{$data};
    my $oldest = 0;
    my $skip = 0;
    $window = Irssi::window_find_name('gmail') or return;

    my $cmd = sprintf('curl -u "%s:%s" --silent "https://mail.google.com/mail/feed/atom"', $username, $password);
    my $inbox = qx/$cmd/;

    utf8::decode($inbox);
    my $p = HTML::TokeParser->new( \$inbox );


    while (my $token = $p->get_token) { last if $token->[1] eq "entry" }
    my ($title,$summary,$from,$date);
    while (my $token = $p->get_token) 
    {
        if ($token->[0] eq "S" and $token->[1] eq "title")
        {
            $token = $p->get_token;
            $title = $token->[1];
        }
        if ($token->[0] eq "S" and $token->[1] eq "summary")
        {
            $token = $p->get_token;
            $summary = $token->[0] eq "T" ? $token->[1] : "";
        }
        if ($token->[0] eq "S" and $token->[1] eq "issued")
        {
            $token = $p->get_token;
            $date = $token->[1];
            $date =~ /(\d{4})-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)Z/;
            $date = timelocal($6, $5, $4, $3, $2, $1);
            $oldest = $date if ($date > $oldest);
            $skip = 1 if ($date <= $lastcheck);
        }
        if ($token->[0] eq "S" and $token->[1] eq "author")
        {
            while (my $token = $p->get_token) { last if $token->[1] eq "name" }
            $token = $p->get_token;
            $from = $token->[1];
        }
        if ($token->[0] eq "E" and $token->[1] eq "entry")
        {
            $window->print("$from: $title" . ($summary ? " [$summary]" : ""), MSGLEVEL_CLIENTCRAP) unless ($skip);
            $skip = 0;
        }

    }

    $lastcheck = $oldest;
}

$window = Irssi::window_find_name('gmail') or Irssi::print("Create a window named 'gmail'");

Irssi::command_bind("gmail_login", "gmail_login");
Irssi::command_bind("gmail_stop",  "gmail_stop");
Irssi::settings_add_time("misc", "gmail_time", "2m");


# vim:set ts=4 sw=4 et:
