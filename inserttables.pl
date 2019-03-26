#!bin/perl
use warnings;
use strict;
use DBI;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

my @UPsplit;
my @REACsplit;
my $check;
my $i;
my @test;

# open(UniProt,"uniprot-arabidopsisthalianaSequence.tab");
# $i=0;
# while(<UniProt>){
#   #print $i;
#   chomp;
#   $_=~s/ /_/g;
#   $_=~s/\./_/g;
#   $_=~s/;/-/g;
#   $_=~s/'/`/g;
#   @UPsplit=split(/\t/,$_);
#   if (($i != 0) && ($UPsplit[5]=~/Arabidopsis_thaliana/)){
#     print "caca\n";
#     my $caracteristiques=$dbh->do("INSERT INTO Caractéristiques_générales_UniProt VALUES ('$UPsplit[0]','$UPsplit[1]','$UPsplit[2]','$UPsplit[5]','$UPsplit[9]')");
#     my $prot=$dbh->do("INSERT INTO Informations_Protéines_UniProt VALUES('$UPsplit[0]','$UPsplit[3]','$UPsplit[6]','$UPsplit[10]')");
#     my $gene=$dbh->do("INSERT INTO Informations_Gènes_UniProt VALUES('$UPsplit[0]','$UPsplit[4]','$UPsplit[7]','$UPsplit[8]')");
#   }
#   $i++;
# }
# print $i,"\n";
# close(UniProt);

open(REAC,"mart_export.csv");
$i=0;
while(<REAC>) {
  chomp;
  $_=~s/\./_/g;
  @REACsplit=split(/,/,$_);
  # $check=1;
  # for (my $lineREAC=0;$lineREAC<4;$lineREAC++){
  #   print "ok ";
  #   if (not (defined($REACsplit[$lineREAC]))){
  #     $check=0;
  #     print "nope\n";
  #   }
  # }
  if (($#REACsplit+1 == 4) && ($i != 0) && primary keys couple not in  @test) {
    print "prout\n";
    my $reactions=$dbh->do("INSERT INTO Réactions_EnsemblePlantes VALUES('$REACsplit[0]','$REACsplit[1]','$REACsplit[2]','$REACsplit[3]')");
    primary keys double ajouté dans @test;
  }
  $i++;
}
print "$i\n";
close(REAC);
