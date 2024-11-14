#!/usr/bin/perl -w

use strict;
use warnings;
use Mail::IMAPClient;
use Mail::IMAPClient::BodyStructure;

my $username = 'istvan.jarecsny';
my $password = 'Sdfg0123';
my $server   = 'imap.gmail.com';

# initialize the IMAP object
my $imap = Mail::IMAPClient->new ( Server => $server,
                                User => $username,
                                Password => $password,
                                Port => 993,
                                Ssl => 1,
                                Uid => 1 )
or die "Could not connect to server, terminating...\n";

# find which folder to read from
#print "Mailboxes: ".  join(", ", $imap->folders) . "\n";
#print "Folder to use: ";
#chomp (my $folder = <STDIN>);

my $folder = "INBOX";
$imap->select($folder) or die "select() failed, terminating...\n";

# get message IDs and number of messages
my @msgIDs = $imap->search("SUBJECT", "RegEx");
print scalar(@msgIDs) . " message(s) found in mailbox.\n";
foreach my $msgid (@msgIDs) {
	#print $imap->message_string($msgid)\n";
	#print $imap->subject($msgid) . "\n";
	print $imap->message_string($msgid) . "\n";
	next;

	my $bsdat = $imap->fetch( $msgid, "bodystructure" );
	my $bso   = Mail::IMAPClient::BodyStructure->new( join("", $imap->History) );
	my $mime  = $bso->bodytype . "/" . $bso->bodysubtype;
	my $parts = map( "\n\t" . $_, $bso->parts );
	#print "Msg $msgid (Content-type: $mime) contains these parts:$parts\n";
	#my @keys = keys %{$bso};
	#print "@keys";

	my $ImapBodyStruct = $imap->get_bodystructure($msgid);
	my @BodyParts = $ImapBodyStruct->parts();
	foreach my $BodyPart (@BodyParts) {
		my $Message = $imap->bodypart_string($msgid, $BodyPart);
		print $Message;
	} 
}
