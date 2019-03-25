#!bin/perl
use warnings;
use strict;
use DBI;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

my @UPsplit;
my $check;
my $i=0;

open(UniProt,"uniprot-arabidopsisthalianaSequence.tab");
while(<UniProt>){
  chomp;
  @UPsplit=split(/\t/,$_);
  $check=1;
  if ($i!=0){
    for (my $lineUP=0;$lineUP<$#UPsplit;$lineUP++){
      if ($UPsplit[$lineUP] eq (/^\s*$/)){
        $check=0;
      }
      if ($check==1){
        my $caracteristiques=$dbh->do("INSERT INTO Caractéristiques_générales_UniProt VALUES($UPsplit[0],$UPsplit[1],$UPsplit[2],$UPsplit[5],$UPsplit[9])");
      }
    }
  }
  $i++;
}
