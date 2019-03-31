#!bin/perl
use warnings;
use strict;

my @UPsplit;
my $i=1;

print "Indiquez la longueur minimale des protéines que vous voulez obtenir : ";
my $usr = <STDIN>;

open(UniProt,"uniprot-arabidopsisthalianaSequence.tab");
while(<UniProt>) {
    chomp;
    @UPsplit=split(/\t/,$_);
    if ($UPsplit[6] >= $usr) {
        print $i," - ",join(" ",@UPsplit),"\n";
        $i++;
    }
}
close(UniProt);