#!bin/perl
use warnings;
use strict;
use DBI;
use Switch;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

# ajouter une protéine 
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

# corriger une séquence 
sub modif_sequence(){
  print("Veuillez entrez le nom \"Entry\" de la protéine dont vous souhaitez modifier la séquence :\n");
  my $prot = <STDIN>;
  chomp($prot);
  print("Entrez maintenant la séquence complète corrigée :");
  my $seq = <STDIN>;
  chomp($seq);
  my $modif_sequence = $dbh->do("UPDATE Informations_Proteines_UniProt SET Sequence = '$seq' WHERE Entry = '$prot'");
}

# afficher le nom des protéines référencées dans le fichier EnsemblPlant
sub get_protein_EnsemblPlant() {
    my $req_protein_EnsemblPlant = $dbh->prepare("SELECT UniProtKB_TrEMBL_ID FROM Reactions_EnsemblePlantes") or die $dbh->errstr();
    $req_protein_EnsemblPlant->execute() or die $req_protein_EnsemblPlant->errstr();
    my $i=1;
    while (my @prot = $req_protein_EnsemblPlant->fetchrow_array()) {
        print $i," - ",join(" ",@prot),"\n";
        $i++;
    }
    $req_protein_EnsemblPlant->finish;
}

# afficher le nom des gènes du fichier UniProt également référencés dans le fichier EnsemblPlant
sub get_gene_UniProtANDEnsemblPlant() {
    my $req_gene = $dbh->prepare("select GeneName from Informations_Genes_Uniprot G join Reactions_EnsemblePlantes E on G.Entry = E.UniProtKB_TrEMBL_ID") or die $dbh->errstr();
    $req_gene->execute() or die $req_gene->errstr();
    my $i=1;
    while (my @gene = $req_gene->fetchrow_array()) {
        print $i," - ",join(" ",@gene),"\n";
        $i++;
    }
    $req_gene->finish;
}

#  afficher les protéines ayant une longueur au moins égale à une valeur donnée
sub req_longueur(){
    print("Entrez une longueur de séquence protéique (en pb) pour obtenir la liste des proteines ayant une séquence d'une longueur au moins égale :\n");
    my $size = <STDIN>;
    chomp($size);
    my $reqsize = $dbh->prepare("SELECT ProteinNames from Informations_Proteines_UniProt where length>='$size'") or die $dbh->errstr();
    $reqsize->execute() or die $reqsize->errstr();
    my $i=1;
    while (my @protsize = $reqsize->fetchrow_array()){
        print $i," - ",join(" ",@protsize),"\n";
        $i++;
    }
    $reqsize->finish;
}

# afficher les caractéristiques des protéines correspondant à un EC number donné
sub get_caract_protein() {
    print "Entrez un EC number (sans réécrire \"EC\") : ";
    my $ECn=<STDIN>;
    chomp($ECn);
    $ECn='(EC '.$ECn.')';
    my $req_ECnumber = $dbh->prepare("select * from Informations_Proteines_UniProt where ProteinNames ~ '$ECn'") or die $dbh->errstr();
    $req_ECnumber->execute() or die $req_ECnumber->errstr();
    my $i=1;
    while (my @caract = $req_ECnumber->fetchrow_array()){
        print $i," - ",join(" ",@caract),"\n";
        $i++;
    }
    if ($i == 1)  {
        print "Aucune protéine correspond à cet EC number.\n";
    }
    $req_ECnumber->finish;
}

### MAIN ###
sub main() {
    print "Bienvenu(e) ! Que voulez vous faire ?\n1 - Ajouter une protéine\n2 - Corriger une séquence\n3 - Afficher le nom (UniProt ID) des protéines référencées dans le fichier EnsemblPlant\n4 - Afficher le nom des gènes du fichier UniProt qui sont également référencés dans le fichier EnsemblPlant\n5 - Afficher les protéines ayant une longueur au moins égale à une valeur donnée\n6 - Afficher les caractéristiques des protéines correspondant à un EC number donné\n0 - Quitter le programme\nVotre choix : ";
    my $answer=<STDIN>;
    chomp($answer);
    while ($answer ne 0) {  # switch ?
        switch($answer) {
            case 1 {
                insert_protein();
            }
            case 2 {
                modif_sequence();
            }
            case 3 {
                get_protein_EnsemblPlant();
            }
            case 4 {
                get_gene_UniProtANDEnsemblPlant();
            }
            case 5 {
                req_longueur();
            }
            case 6 {
                get_caract_protein();
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