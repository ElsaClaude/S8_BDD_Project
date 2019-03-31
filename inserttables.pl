# Projet Base de Données
# fichier Insert Tables : insérer le contenu dans les tables créées à l'aide de tables_projet.pl 
# groupe : Elsa Claude - Amelie Gruel
# 03 avril 2019

#!bin/perl
use warnings;
use strict;
use DBI;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

my @UPsplit;
my @REACsplit;
my $check;
my $i;
my @testUniProt;
my @testEnsemblePlant;

open(UniProt,"uniprot-arabidopsisthalianaSequence.tab");
$i=0;
while(<UniProt>){
  chomp;
  # $_=~s/ /_/g;
  # $_=~s/\./_/g;
  # $_=~s/;/-/g;
  $_=~s/'/`/g;
  @UPsplit=split(/\t/,$_);
  if (($i != 0) && ($UPsplit[5]=~/Arabidopsis thaliana/)){
    my $caracteristiques=$dbh->do("INSERT INTO Caracteristiques_generales_UniProt VALUES ('$UPsplit[0]','$UPsplit[1]','$UPsplit[2]','$UPsplit[5]','$UPsplit[9]')");
    my $prot=$dbh->do("INSERT INTO Informations_Proteines_UniProt VALUES('$UPsplit[0]','$UPsplit[3]','$UPsplit[6]','$UPsplit[10]')");
    my $gene=$dbh->do("INSERT INTO Informations_Genes_UniProt VALUES('$UPsplit[0]','$UPsplit[4]','$UPsplit[7]','$UPsplit[8]')");
    push(@testUniProt,$UPsplit[0]);
  }
  $i++;
}
print "UniProt done\n";
close(UniProt);

open(REAC,"mart_export.csv");
$i=1;
while(<REAC>) {
  chomp;
  $_=~s/\./_/g;
  @REACsplit=split(/,/,$_);
  $check=1;
  if (not (defined($REACsplit[2])) || ($REACsplit[2]=~/^s*$/)){
    $check=0;
  } elsif (not (defined($REACsplit[3]))) {
    push(@REACsplit,'NULL');
  }
  if (($check==1) && ($i != 1) && (join(" ",@testEnsemblePlant) !~ /$REACsplit[2]/) && (join(" ",@testUniProt) =~ /$REACsplit[2]/)) {
    push(@testEnsemblePlant,$REACsplit[2]);
    my $reactions=$dbh->do("INSERT INTO Reactions_EnsemblePlantes VALUES ('$REACsplit[0]','$REACsplit[1]','$REACsplit[2]','$REACsplit[3]')");
  }
  $i++;
}
print "EnsemblPlant done\n";
close(REAC);

$dbh->disconnect(); 