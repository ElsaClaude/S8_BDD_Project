#!bin/perl
use warnings;
use strict;
use DBI;
use Switch;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

sub insert_protein() {
  my @protein;
  my @ecran=("Veuillez entrez : \n Entry","Entry Name","Status (reviewed ou unreviewed)","Organisme","EnsemblePlantTranscript","ProteinNames","Length","Sequence"); ## <=  toutes les caractéristiques à demander à l'utilisateur pour remplir la table générale et la table protéine
  for my $e (@ecran) {
      print "$e : ";
      my $usr=<STDIN>;
      chomp($usr);
      push(@protein,$usr);
    }
  my $insert_general = $dbh->do("INSERT INTO Caracteristiques_generales_UniProt VALUES ('$protein[0]','$protein[1]','$protein[2]','$protein[3]','$protein[4]')");
  my $insert_protein = $dbh->do("insert into Informations_Proteines_UniProt values('$protein[0]','$protein[5]','$protein[6]','$protein[7]')"); # remplacer avec les bons éléments de @protéine
  ## faire 2e requête pour remplir la table générale avec les bons éléments de @protein
}

insert_protein();

$dbh->disconnect();
