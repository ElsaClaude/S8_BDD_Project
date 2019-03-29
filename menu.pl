#!bin/perl
use warnings;
use strict;
use DBI;
use Switch;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

# ajouter une protéine => sur EnsemblPlant ???
sub insert_protein() {
    my @protein;
    my @ecran=[]; ## <=  toutes les caractéristiques à demander à l'utilisateur pour remplir la table générale et la table protéine
    for my $e (@ecran) {
        print "$e : ";
        my $usr=<STDIN>;
        chomp($usr);
        push(@protein,$usr);
    ## faire 2e requête pour remplir la table générale avec les bons éléments de @protein
    }
}

# afficher le nom des protéines référencées dans le fichier EnsemblPlant
sub get_protein_EnsemblPlant() {
    my $req_protein_EnsemblPlant = $dbh->prepare("SELECT entry FROM 'Caractéristiques_générales_UniProt'") or die $dbh->errstr();
    $req_protein_EnsemblPlant->execute() or die $req_protein_EnsemblPlant->errstr();
    my $i=1;
    while (my @prot = $req_protein_EnsemblPlant->fetchrow_array()) {
        print $i," - ",join(" ",@prot),"\n";
        $i++;
    }
    $req_protein_EnsemblPlant->finish;
}


# menu
sub menu() {  
}

### MAIN ###
sub main() {
    print "Bienvenu(e) ! Que voulez vous faire ?\n1 - Ajouter une protéine\n2 - Corriger une séquence\n3 - Afficher le nom (UniProt ID) des protéines référencées dans le fichier EnsemblPlant\n4 - Afficher le nom des gènes du fichier UniProt qui sont également référencés dans le fichier EnemblPlant\n5 - Afficher les protéines ayant une longueur au moins égale à une valeur donnée\n6 - Afficher les caractéristiques des protéines correspondant à un EC number donné\n0 - Quitter le programme\nVotre choix : ";
    my $answer=<STDIN>;
    chomp($answer);
    while ($answer ne 0) {  # switch ?
        switch($answer) {
            case 1 {
                print "Cette option n'est pas encore implémenté.\n";
            }
            case 2 {
                print "Cette option n'est pas encore implémenté.\n";
            }
            case 3 {
                get_protein_EnsemblPlant();
            }
            case 4 {
                print "Cette option n'est pas encore implémenté.\n";
            }
            case 5 {
                print "Cette option n'est pas encore implémenté.\n";
            }
            case 6 {
                print "Cette option n'est pas encore implémenté.\n";
            }
            else {
                print "Désolé, ceci n'est pas une option disponible.\n";
            }
        }
        print "Votre choix : ";
        $answer=<STDIN>;
        chomp($answer);
    }
}

main();

$dbh->disconnect(); 

# my $req1 = $dbh->prepare("select Superficie from Appart") or die $dbh->errstr();
# $req1->execute() or die $req1->errstr();

# while (my @t = $req1->fetchrow_array()) {
#     print join(" ",@t),"\n";
# }
# $req1->finish;