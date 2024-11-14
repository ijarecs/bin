#cd /home/ijarecs/Dokumentumok/Erzsi-All/Erzsi_20191222-2147/üzenetek
cd /home/ijarecs/Dokumentumok/Erzsi-Sent/Erzsi-Sent_20191227-1620/üzenetek

egrep -h -e youtube -e youtu.be * | perl -ne '
use List::MoreUtils qw(uniq);

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
