#!/usr/bin/perl -w

use strict;
use Date::Calc qw(Delta_Days);

my $maildir="~/Data/saved-mails/gmail-NN";
my (%inputdata, %outputdata);

# mentett email-fájlok feldolgozása
foreach (`ls $maildir/*.eml`) {
	chomp;
	my $file = $_;
	#print "$file\n";

	# Értékes sorok kimmentése az email-fájlból
	my($datum, @dayvalues, @quantity);
	#my $command = "egrep -e 'eszk.zalap\$' -e ' eszk.\$' -e 'eszk.zalaponk.nt, ' -e ' EUR\$' '$file'";
	my $command = "egrep -e 'eszk.zalap\$' -e 'eszk.zalap - B\$' -e ' eszk.\$' -e 'eszk.zalaponk.nt, ' -e ' EUR\$' -e ' db\$' '$file'";
	foreach (`$command`) {
		next if /aktu..lis/;
		
		# Tipikus feldolgozandó szekvencia:
		# A befektetési egységeinek összesített értéke =eszközalaponként, 2018.01.04-i
		#   Euró kötvény eszközalap
		#   9 360,65 EUR 
		#   9190,53 db 
		#   USA részvénypiaci eszközalap
		#   11 386,42 EUR
		#   7979,50 db
		chomp;

		if (/ EUR$/) {
			# alap értéke
			s/\D+(.+)\s+EUR/$1/;
			s/\s+//;
			s/,/./;
			push @dayvalues, $_;
		} elsif (/eszk..zalaponk..nt,\s+(\d{4}\.\d{2}\.\d{2})/) {
			# dátum
			$datum = "$1";
			print "-- $file - $1\n";
		} elsif (/(\d+,\d{2})\s+db/) {
			# darabszám
			$_ = $1;
			$_ =~ s/,/./;
			push @quantity, $_;
		} else {
			# alap neve
			s/^\s*//;
			s/ eszk.+$//;
			push @dayvalues, $_;
		}
	}

	# @dayvalues tartalma: alapnév/érték párok:
	# páros elem   : alap neve 
	# páratlan elem: alap értéke
	# stb...
	my($key_fondportfolio, @fondvalue, @fondname);
	@fondvalue = do {my $i = 0; grep {$i++ % 2} @dayvalues};
	@fondname = do {my $i = 1; grep {$i++ % 2} @dayvalues};
	$key_fondportfolio = join('#', @fondname);

	#print "datum: $datum\n";
	#print "fondnames: @fondname\n";
	#print "fondvalues: @fondvalue\n";
	#print "fondportfolio: $key_fondportfolio\n";

	$inputdata{$key_fondportfolio}{$datum}{values} = \@fondvalue; 
	$inputdata{$key_fondportfolio}{$datum}{quantities} = \@quantity; 
}

my (%gaintotal, $gaintotal, $gaintotalproc);
foreach (sort keys %inputdata) {
	my $key_fondportfolio = $_;
	print "=== $key_fondportfolio\n";

	my @datums = sort keys %{$inputdata{$key_fondportfolio}};
	foreach my $datum (@datums) {
		print " $datum - ";

		my $total = 0;
		foreach my $fondvalue (@{$inputdata{$key_fondportfolio}{$datum}{values}}) {
			print "$fondvalue ";
			$total += $fondvalue;
		}
		printf " TOTAL: %.2f", $total;
		$outputdata{$datum} += $total;

		print " - Quantities: ";
		foreach my $quantity (@{$inputdata{$key_fondportfolio}{$datum}{quantities}}) {
			print "$quantity ";
		}
		print "\n";
	}

	my $days = Delta_Days((split /\./, $datums[0]), split(/\./, $datums[$#datums]));
	my $gain = $outputdata{$datums[$#datums]}-$outputdata{$datums[0]}; 
	my $proc = $gain*100/$outputdata{$datums[0]}; 
	$gaintotal{$key_fondportfolio} = sprintf "%.2f %.2f%%", $gain, $proc;
	printf "=== Days: %4s - Gain: %.2f - %.2f%%\n\n", $days, $gain, $proc; 

	#$days = Delta_Days((split /\./, "2005.11.23"), split(/\./, $datums[$#datums]));
	#$gain = $outputdata{$datums[$#datums]}-14306; 
	#$proc = $gain*100/14306; 
	#printf "=== Days: %4s - Gain: %.2f - %.2f%%\n\n", $days, $gain, $proc/($days/366); 

	$gaintotal += $gain;
	$gaintotalproc += $proc;ain:
}
my $title = sprintf "Gain total: %.2f %.2f%%", $gaintotal, $gaintotalproc;
print "=== $title ===\n";

my $command = qq|feedgnuplot --lines --domain --timefmt '%Y.%m.%d' --set 'format x "%m.%d"' --xlabel "Dátum" --ylabel "EUR" --legend 0 "Total" --title "$title" --set grid --set 'xtics font ", 8"' --set 'term wxt title "Total"' --exit|;
open PLOT, "| $command" or die "can't fork: $!";
foreach (sort keys %outputdata) {
	print PLOT "$_ $outputdata{$_}\n";
}
close PLOT or die "bad spool: $! $?";

my $pf = "Fejlődő részv.piacok magas oszt.#Luxusmárkák részvény";
#do_plot($pf);
#do_plot_quantity($pf);
#do_plot_separat($pf);

#$pf = "Luxusmárkák részvény";
#do_plot($pf);
#do_plot_quantity($pf);
#do_plot_separat($pf);

$pf = "Euró likviditás";
do_plot($pf);
do_plot_quantity($pf);
do_plot_separat($pf);

sub do_plot {
	my $key_fondportfolio = shift; # pld.: Euró kötvény#USA részvénypiaci
	my @datums = sort keys %{$inputdata{$key_fondportfolio}};

	my @fondname = split '#', $key_fondportfolio;
	my $days = Delta_Days((split /\./, $datums[0]), split(/\./, $datums[$#datums]));

	my ($legend, $i, $gain);
	for ($i=0; $i <= $#fondname; $i++) {
		$legend .= qq|--legend $i "$fondname[$i]" |;
		$gain += ${$inputdata{$key_fondportfolio}{$datums[$#datums]}{values}}[$i] - ${$inputdata{$key_fondportfolio}{$datums[0]}{values}}[$i]; 
	}

	my $proc = $gain*100/$outputdata{$datums[0]}; 
	my $title = sprintf "$key_fondportfolio - Gain: %.2f %.2f%%", $gain, $proc;
	$command = qq|feedgnuplot --lines --domain --timefmt '%Y.%m.%d' --set 'format x "%m.%d"' --xlabel "Dátum" --ylabel "EUR" $legend --title '$title' --set grid --set 'xtics font ", 8"' --set 'term wxt title "@fondname"' --exit|;
	open PLOT, "| $command" or die "can't fork: $!";

	foreach my $datum (@datums) {
		my $t = ${$inputdata{$key_fondportfolio}{$datum}{values}}[0];
		print PLOT "$datum ";

		for ($i=0; $i <= $#fondname; $i++) {
			print PLOT "${$inputdata{$key_fondportfolio}{$datum}{values}}[$i] ";
		}
		print PLOT "\n";
	}
	close PLOT or die "bad spool: $! $?";
}

sub do_plot_quantity {
	my $key_fondportfolio = shift; # pld.: Euró kötvény#USA részvénypiaci

	my @fondname = split '#', $key_fondportfolio;
	my ($legend, $i);
	for ($i=0; $i <= $#fondname; $i++) {
		$legend .= qq|--legend $i "$fondname[$i]" |;
	}

	$command = qq|feedgnuplot --lines --domain --timefmt '%Y.%m.%d' --set 'format x "%m.%d"' --xlabel "Dátum" --ylabel "Darab" $legend --title "Darabszámok - $key_fondportfolio" --set grid --set 'xtics font ", 8"' --set 'term wxt title "@fondname"' --exit|;
	open PLOT, "| $command" or die "can't fork: $!";

	my @datums = sort keys %{$inputdata{$key_fondportfolio}};
	foreach my $datum (@datums) {
		print PLOT "$datum ";

		my $i = 0;
		foreach my $quantity (@{$inputdata{$key_fondportfolio}{$datum}{quantities}}) {
			print PLOT "$quantity ";
		}
		print PLOT "\n";
	}
	close PLOT or die "bad spool: $! $?";
}

sub do_plot_separat {
	my $key_fondportfolio = shift; # pld.: Euró kötvény#USA részvénypiaci
	my @datums = sort keys %{$inputdata{$key_fondportfolio}};

	my @fondname = split '#', $key_fondportfolio;
	my ($legend, $i);
	for ($i=0; $i <= $#fondname; $i++) {
		$legend = qq|--legend 0 "$fondname[$i]"|;
		my $gain = ${$inputdata{$key_fondportfolio}{$datums[$#datums]}{values}}[$i] - ${$inputdata{$key_fondportfolio}{$datums[0]}{values}}[$i]; 
		my $proc = $gain*100/$outputdata{$datums[0]}; 
		my $title = sprintf "$fondname[$i] - Gain: %.2f %.2f%%", $gain, $proc;

		$command = qq|feedgnuplot --lines --domain --timefmt '%Y.%m.%d' --set 'format x "%m.%d"' --xlabel "Dátum" --ylabel "EUR" $legend --title '$title' --set grid --set 'xtics font ", 8"' --set 'term wxt title "$fondname[$i]"' --exit|;
		open PLOT, "| $command" or die "can't fork: $!";

		foreach my $datum (@datums) {
			print PLOT "$datum ";

			my @values = @{$inputdata{$key_fondportfolio}{$datum}{values}};
			print PLOT $values[$i];
			print PLOT "\n";
		}
		close PLOT or die "bad spool: $! $?";
	}
}
