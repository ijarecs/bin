perl -ne '
chomp;
s/\r//;
$::full.=$_;

END {
$::full =~ s/=+c3=+81/Á/gi;
$::full =~ s/=+c3=+89/É/gi;
$::full =~ s/=+c3=+8d/Í/gi;
$::full =~ s/=+c3=+93/Ó/gi;
$::full =~ s/=+c3=+96/Ö/gi;
$::full =~ s/=+c5=+90/Ő/gi;
$::full =~ s/=+c3=+9a/Ú/gi;
$::full =~ s/=+c3=+9c/Ü/gi;
$::full =~ s/=+c3=+a1/á/gi;
$::full =~ s/=+c3=+a9/é/gi;
$::full =~ s/=+c3=+ad/í/gi;
$::full =~ s/=+c3=+b3/ó/gi;
$::full =~ s/=+c3=+b6/ö/gi;
$::full =~ s/=+c5=+91/ő/gi;
$::full =~ s/=+c3=+ba/ú/gi;
$::full =~ s/=+c3=+bc/ü/gi;
$::full =~ s/=+c5=+b1/ű/gi;
$::full =~ s/=+E2=+80=+93/-/gi;
$::full =~ s/=+e2=+82=+ac/EUR/gi;

print $::full;
}
'
