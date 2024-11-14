#!/usr/bin/perl -w

use strict;
use warnings;

use Mail::IMAPTalk;
use IO::Socket::SSL;

my $username = 'istvan.jarecsny';
my $password = 'Sdfg0123';
my $server   = 'imap.gmail.com:993';

sub find_messages {
	my $sock = IO::Socket::SSL->new("$server") or die "Problem connecting via SSL to $server: ", IO::Socket::SSL::errstr();
	my $ofh = select($sock); $| = 1; select ($ofh);
	my $IMAP = Mail::IMAPTalk->new(
		Socket => $sock,
		State  => Mail::IMAPTalk::Authenticated,
		Username => $username ,
		Password => $password,
		Uid    => 0) or die "Could not query on existing socket. Reason: $@";

	$IMAP->select('inbox');
	#my @MsgIds = $IMAP->search('not', 'seen');
	my @MsgIds = $IMAP->search(('SUBJECT', 'nform'));
	#my @MsgIds = $IMAP->search(('FROM', 'noreply@nn.hu'));

	my @messages;
	foreach my $uid (@MsgIds) {
        	#my %info = fetch_message($IMAP, $uid);
        	#push @messages, \%info;

    		my $Msg = $IMAP->fetch($uid, 'envelope')->{$uid}->{envelope};
		if ($Msg->{Subject} =~ /Inform/) {
			print "$Msg->{Subject}\n";
		}
	}
	$IMAP->logout();
	return \@messages;
}

sub fetch_message {
    # fetch a message ID, display some information
    my ($IMAP, $uid) = @_;
    my $Msg = $IMAP->fetch($uid, 'envelope')->{$uid}->{envelope};

    # clean the sender
    $Msg->{From} =~ s/(")|(<.*>)|(\s{2,})|(\s+$)//g;

    # clean the subject
    $Msg->{Subject} =~ s/\[[[:alpha:]]+#\d{6}\]//g;
    $Msg->{Subject} =~ s/(\(.*\))|(\s{2,})|(\s+$)|(^\s+)//g;

    return ( From    => $Msg->{From},
             Subject => $Msg->{Subject});
}

my $messages = find_messages();

if (scalar (@$messages) > 0) {
    foreach my $msg (@$messages) {
        print $msg->{From}, " - ",
              $msg->{Subject}, "\n";

    }
} else {
    print "No mail";
}
