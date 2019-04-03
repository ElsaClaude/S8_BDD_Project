# Projet Base de Donnees
# fichier Perl VS SQL : permet de comparer la vitesse d'execution d'une commande en passant par SQL ou Perl 
# groupe : Elsa Claude - Amelie Gruel
# 03 avril 2019

#!bin/perl
use warnings;
use strict;

my @UPsplit;
my $i=1;

print "Indiquez la longueur minimale des proteines que vous voulez obtenir : ";
my $usr = <STDIN>;

open(UniProt,"uniprot-arabidopsisthalianaSequence.tab");
while(<UniProt>) {
    chomp;
    @UPsplit=split(/\t/,$_);
    if (($UPsplit[6] >= $usr) && ($UPsplit[5]=~/Arabidopsis thaliana/)) {
        print $i," - ",join(" ",@UPsplit),"\n";
        $i++;
    }
}
close(UniProt);