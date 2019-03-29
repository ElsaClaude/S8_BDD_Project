#!bin/perl
use warnings;
use strict;
use DBI;
use Switch;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

sub req_longueur(){
  print("Entrez une longueur de séquence protéique (en pb) pour obtenir la liste des proteines ayant une séquence d'une longueur au moins égale.\n");
  my $size = <STDIN>;
  my $reqsize = $dbh->prepare("SELECT Proteinnames from Informations_Proteines_UniProt where length>='$size'") or die $dbh->errstr();
  $reqsize->execute() or die $reqsize->errstr();
  while (my @protsize = $reqsize->fetchrow_array()){
    print join("\n",@protsize),"\n";
  }
  $reqsize->finish;
}

req_longueur();

$dbh->disconnect();
