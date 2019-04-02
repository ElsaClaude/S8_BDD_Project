# Projet Base de Données
# fichier menu 
# groupe : Elsa Claude - Amelie Gruel
# 03 avril 2019

# Attention à ce que le module "Switch" soit bien installé

#!bin/perl
use warnings;
use strict;
use DBI;
use Switch;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

# ajouter une protéine
sub insert_protein() {
  my @protein;
  my @ecran=("Veuillez entrer : \nEntry","Entry Name","Status (reviewed ou unreviewed)","Protein names","Gene names","Organism","Length","Gene names synonyms","Gene Ontology","EnsemblPlantsTranscript","Sequence");
  for my $e (@ecran) {
      print "$e : ";
      my $usr=<STDIN>;
      chomp($usr);
      push(@protein,$usr);
    }
  my $insert_general = $dbh->do("INSERT INTO Caracteristiques_generales_UniProt VALUES ('$protein[0]','$protein[1]','$protein[2]','$protein[5]','$protein[9]')");
  my $insert_protein = $dbh->do("INSERT INTO Informations_Proteines_UniProt VALUES('$protein[0]','$protein[3]','$protein[6]','$protein[10]')");
  my $insert_gene = $dbh->do("INSERT INTO Informations_Genes_UniProt VALUES('$protein[0]','$protein[4]','$protein[7]','$protein[8]')");
}

# corriger une séquence
sub modif_sequence(){
  print("Veuillez entrer le nom \"Entry\" de la protéine dont vous souhaitez modifier la séquence :\n");
  my $prot = <STDIN>;
  chomp($prot);
  print("Entrez maintenant la séquence complète corrigée :");
  my $seq = <STDIN>;
  chomp($seq);
  my $modif_sequence = $dbh->do("UPDATE Informations_Proteines_UniProt SET Sequence = '$seq' WHERE Entry = '$prot'");
}

# supprimer une protéine provenant d'EnsemblPlants
sub delete_protein_EnsemblPlants() {
  print("Veuillez entrer le nom \"Entry\" de la protéine que vous voulez supprimer dans les données provenant d'EnsemblPlants :\n");
  my $usr = <STDIN>;
  chomp($usr);
  my $delete = $dbh->do("delete from Reactions_EnsemblPlants where UniProtKB_TrEMBL_ID in (select Entry from Caracteristiques_generales_UniProt where Entry='$usr')");
  print "Suppression faite.\n";
}

# supprimer une protéine provenant d'UniProt
sub delete_protein_UniProt() {
  print("Veuillez entrer le nom \"Entry\" de la protéine que vous voulez supprimer dans les données provenant d'EnsemblPlants :\n");
  my $usr = <STDIN>;
  my $req = $dbh->prepare("select UniProtKB_TrEMBL_ID FROM Reactions_EnsemblPlants E join Caracteristiques_generales_UniProt U on E.UniProtKB_TrEMBL_ID=U.Entry where U.Entry='$usr'") or die $dbh->errstr();
  $req->execute() or die $req->errstr();
  my @tmp = $req->fetchrow_array();
  my $delete_protein = $dbh->do("delete from Informations_Proteines_UniProt where Entry='$usr'");
  my $delete_gene = $dbh->do("delete from Informations_Proteines_UniProt where Entry='$usr'");
  my $delete_general = $dbh->do("delete from Caracteristiques_generales_UniProt where Entry='$usr'");
  print "Suppression faite.\n";
}

# afficher le nom des protéines référencées dans le fichier EnsemblPlant
sub get_protein_EnsemblPlant() {
  my @matrix;
  my $req_protein_EnsemblPlant = $dbh->prepare("SELECT UniProtKB_TrEMBL_ID FROM Reactions_EnsemblPlants") or die $dbh->errstr();
  $req_protein_EnsemblPlant->execute() or die $req_protein_EnsemblPlant->errstr();
  my $i=1;
  while (my @prot = $req_protein_EnsemblPlant->fetchrow_array()) {
    print $i," - ",join(" ",@prot),"\n";
    push @matrix,[@prot];
    $i++;
  }
  $req_protein_EnsemblPlant->finish;
  my @headers=("Nom de la protéine","Longueur(pb)");
  html_page("requete_proteines_EnsemblPlants",\@matrix,\@headers,"Noms des protéines référencées dans le fichier EnsemblPlants");
}

# afficher le nom des gènes du fichier UniProt également référencés dans le fichier EnsemblPlant
sub get_gene_UniProtANDEnsemblPlant() {
    my @matrix;
    my $req_gene = $dbh->prepare("select GeneName from Informations_Genes_Uniprot G join Reactions_EnsemblPlants E on G.Entry = E.UniProtKB_TrEMBL_ID") or die $dbh->errstr();
    $req_gene->execute() or die $req_gene->errstr();
    my $i=1;
    while (my @gene = $req_gene->fetchrow_array()) {
      print $i," - ",join(" ",@gene),"\n";
      push @matrix,[@gene];
      $i++;
    }
    $req_gene->finish;
    my @headers=("Nom du gène");
    html_page("requete_nom_gene",\@matrix,\@headers,"Nom des gènes issus d'UniProt étant également référencés dans EnsemblPlant");
}

#  afficher les protéines ayant une longueur au moins égale à une valeur donnée
sub get_longueur(){
  my @matrix;
  my $i=1;
  print("Entrez une longueur de séquence protéique (en pb) pour obtenir la liste des proteines ayant une séquence d'une longueur au moins égale.\n");
  my $size = <STDIN>;
  my $reqsize = $dbh->prepare("SELECT Proteinnames,length from Informations_Proteines_UniProt where length>='$size'") or die $dbh->errstr();
  $reqsize->execute() or die $reqsize->errstr();
  while (my @protsize = $reqsize->fetchrow_array()){
    print $i," - ",join(" ",@protsize),"\n";
    push @matrix,[@protsize];
    $i++;
  }
  $reqsize->finish;
  my @headers=("Nom de la protéine","Longueur(pb)");
  html_page("requete_longueur",\@matrix,\@headers,"Protéines ayant une longueur supérieure ou égale à $size pb");
}

# afficher les caractéristiques des protéines correspondant à un EC number donné
sub get_caract_protein() {
  my @matrix;
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
    push @matrix,[@caract];
  }
  if ($i == 1)  {
    print "Aucune protéine correspond à cet EC number.\n";
  }
  $req_ECnumber->finish;
  my @headers=("Entrée","Nom de la protéine","Longueur (en pb)","Séquence protéique");
  html_page("requete_caracteristiques_proteine",\@matrix,\@headers,"Caractéristiques des protéines ayant comme E.C number : $ECn");
}

sub html_page(){
  print "\nVoulez-vous enregistrer ces résultats dans un fichier html ?\n0 - Non\n1 - Oui\nVotre choix : ";
  my $usr = <STDIN>;
  chomp($usr);
  if ($usr == 1){
    my $requete = shift;
    my @matrix=@{shift()};
    my @headers = @{shift()};
    my $title = shift;
    open (HTML,">$requete.html");
    print HTML "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"UTF-8\">\n<title>$title</title>\n<h1>$title</h1>\n</head>\n<body>";
    print HTML "<table border=\"1\">";
    print HTML "\n\t<tr>";
    foreach my $h (@headers){
      print HTML "\n\t\t<td>$h</td>";
    }
    print HTML "\n\t</tr>";
    for (my $i=0;$i<$#matrix;$i++){
      print HTML "\n\t<tr>";
      for (my $j=0;$j<$#{$matrix[$i]}+1;$j++){
        print HTML "\n\t\t<td>$matrix[$i][$j]</td>";
      }
      print HTML "\n\t</tr>";
    }
    print HTML "\n</table>\n</body>\n</html>";
    close(HTML);
    print ("\n\n====== Vous avez généré le fichier --> $requete.html <-- associé à votre demande ======\n\n");
  }
}

sub menu(){
  print "\nQue voulez-vous faire ?\n1 - Ajouter une protéine\n2 - Corriger une séquence\n3 - Supprimer une protéine provenant d'EnsemblPlants\n4 - Supprimer une protéine provenant d'UniProt\n5 - Afficher le nom (UniProt ID) des protéines référencées dans le fichier EnsemblPlant\n6 - Afficher le nom des gènes du fichier UniProt qui sont également référencés dans le fichier EnsemblPlant\n7 - Afficher les protéines ayant une longueur au moins égale à une valeur donnée\n8 - Afficher les caractéristiques des protéines correspondant à un EC number donné\n0 - Quitter le programme\n\nVotre choix : ";
}

### MAIN ###
sub main() {
  print "Bienvenu(e) !\n";
  menu();
  my $answer=<STDIN>;
  chomp($answer);
  while ($answer ne 0) {
    switch($answer) {
        case 1 {
            insert_protein();
        }
        case 2 {
            modif_sequence();
        }
        case 3 {
          delete_protein_EnsemblPlants();
        }
        case 4 {
          delete_protein_UniProt();
        }
        case 5 {
            get_protein_EnsemblPlant();
        }
        case 6 {
            get_gene_UniProtANDEnsemblPlant();
        }
        case 7 {
            get_longueur();
        }
        case 8 {
            get_caract_protein();
        }
        else {
            print "Désolé, ceci n'est pas une option disponible.\n";
        }
      }
      menu();
      $answer=<STDIN>;
      chomp($answer);
  }
}

main();

$dbh->disconnect();
