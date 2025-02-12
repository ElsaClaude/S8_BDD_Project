# Projet Base de Donnees
# fichier Insert Tables : inserer le contenu dans les tables creees a l'aide de tables_projet.pl 
# groupe : Elsa Claude - Amelie Gruel
# 03 avril 2019

#!bin/perl
use warnings;
use strict;
use DBI;

## IMPORTANT : entrez vos identifiants dbserver
my $dbh = DBI->connect("DBI:Pg:dbname=>>>>identifiant<<<<;host=dbserver",">>>>identifiant<<<<",">>>>motdepasse<<<<",{'RaiseError' => 1});

my @UPsplit;
my @REACsplit;
my $check;
my $i;
my @testUniProt;
my @testEnsemblPlants;

open(UniProt,"uniprot-arabidopsisthalianaSequence.tab");
$i=0;
while(<UniProt>){
  chomp;
  # $_=~s/ /_/g;
  # $_=~s/\./_/g;
  # $_=~s/;/-/g;
  $_=~s/'/`/g;
  @UPsplit=split(/\t/,$_);
  if ($UPsplit[7]=~/^s*$/) {
    $UPsplit[7]='NULL';
  }
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
  # $_=~s/\./_/g;
  @REACsplit=split(/,/,$_);
  $check=1;
  if (not (defined($REACsplit[2])) || ($REACsplit[2]=~/^s*$/)){
    $check=0;
  } elsif (not (defined($REACsplit[3]))) {
    push(@REACsplit,'NULL');
  }
  if (($check==1) && ($i != 1) && (join(" ",@testEnsemblPlants) !~ /$REACsplit[2]/) && (join(" ",@testUniProt) =~ /$REACsplit[2]/)) {
    push(@testEnsemblPlants,$REACsplit[2]);
    my $reactions=$dbh->do("INSERT INTO Reactions_EnsemblPlants VALUES ('$REACsplit[0]','$REACsplit[1]','$REACsplit[2]','$REACsplit[3]')");
  }
  $i++;
}
print "EnsemblPlant done\n";
close(REAC);

$dbh->disconnect(); 
