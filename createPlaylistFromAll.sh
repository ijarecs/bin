cd /home/ijarecs/Dokumentumok/Erzsi/Összes\ levél_20191230-0802

cat * | perl -ne '
use List::MoreUtils qw(uniq);

if (/^Feladó:/) {
	chomp;
	($felado = $_) =~ s/^Feladó:\s+//;
}

if (/^Címzett:/) {
	chomp;
	($cimzett = $_) =~ s/^Címzett:\s+//;
}
next if (not defined $cimzett) || (not defined $felado);

#print "$felado - $cimzett\n";
if (($felado =~ /oriovics/i && $cimzett =~ /Istv.+?n.Jarecsny/) || ($felado =~ /^Istv.+?n Jarecsny/ && $cimzett =~ /oriovics/i)) {
	print "$felado - $cimzett\n";
	undef $felado, $cimzett;
}
next;

if (m|https://youtu\.be/|) {
	chomp;
	s|.*https://youtu\.be/(.{11}).*|$1|g;
	#push @::arr, $_ if !/IakDIltZ7f7/;
}

if (m|https://www.youtube.com/watch\?v=|) {
	chomp;
	s|.*www.youtube.com/watch\?v=(.{11}).*|$1|g;
	push @::arr, $_ if !/IakDIltZ7f7/;
}

END{
	$i = 0;
	push @out, "http://www.youtube.com/watch_videos?video_ids=";
	foreach (uniq(@::arr)) {
		$i++;
		if ($i == 50) {
			push @out, "$_\n\n";
			$i = 0;
			push @out, "http://www.youtube.com/watch_videos?video_ids=";
		} else {
			push @out, "$_,";
		}
	}
	$out[$#out] =~ s/,$//;
	
	foreach (@out) {
		print;
	}
	print "\n";
}'
