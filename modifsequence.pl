#!bin/perl
use warnings;
use strict;
use DBI;
use Switch;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

sub modif_sequence(){
  print("Veuillez entrez le nom \"Entry\" de la protéine dont vous souhaitez modifier la séquence :\n");
  my $prot = <STDIN>;
  chomp($prot);
  print("Entrez maintenant la séquence complète corrigée :");
  my $seq = <STDIN>;
  chomp($seq);
  my $modif_sequence = $dbh->do("UPDATE Informations_Proteines_UniProt SET Sequence = '$seq' WHERE Entry = '$prot'");
}

modif_sequence();

$dbh->disconnect();
