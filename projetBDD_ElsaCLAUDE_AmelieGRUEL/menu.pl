# Projet Base de Donnees
# fichier menu 
# groupe : Elsa Claude - Amelie Gruel
# 03 avril 2019

# Attention a ce que le module "Switch" soit bien installe

#!bin/perl
use warnings;
use strict;
use DBI;
use Switch;

## IMPORTANT : entrez vos identifiants dbserver
# my $dbh = DBI->connect("DBI:Pg:dbname=>>>>identifiant<<<<;host=dbserver",">>>>identifiant<<<<",">>>>motdepasse<<<<",{'RaiseError' => 1});
my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

# ajouter une proteine
sub insert_protein() {
  my @protein;
  my @ecran=("Veuillez entrer : \nEntry","Entry Name","Status (reviewed ou unreviewed)","Protein names","Gene names","Organism","Length","Gene names synonyms","Gene Ontology","EnsemblPlantsTranscript","Sequence");
  for my $e (@ecran) {
      print "$e : ";
      my $usr=<STDIN>;
      chomp($usr);
      push(@protein,$usr);
    }
  if (check_protein($protein[0]) >= 10) {
    print "\nErreur : cette proteine existe deja dans la base de donnees. Cette operation est donc impossible.\n"
  } else {
    my $insert_general = $dbh->do("INSERT INTO Caracteristiques_generales_UniProt VALUES ('$protein[0]','$protein[1]','$protein[2]','$protein[5]','$protein[9]')");
    my $insert_protein = $dbh->do("INSERT INTO Informations_Proteines_UniProt VALUES('$protein[0]','$protein[3]','$protein[6]','$protein[10]')");
    my $insert_gene = $dbh->do("INSERT INTO Informations_Genes_UniProt VALUES('$protein[0]','$protein[4]','$protein[7]','$protein[8]')");
  }
}

# ajouter une reaction dans la table Reactions
sub insert_reaction() {
  my @reaction;
  my @ecran=("Veuillez entrer : \nGene stable ID","Transcript stable ID","UniProtKB TrEMBL ID","Plant Reactom Reaction ID");
  for my $e (@ecran) {
    print "$e : ";
    my $usr=<STDIN>;
    chomp($usr);
    push(@reaction,$usr);
  }
  if (check_protein($reaction[2]) == 1 || check_protein($reaction[2]) == 11) {
    print "\nErreur : cette proteine a deja une reaction referencee. Cette operation est donc impossible.\n";
  } elsif (check_protein($reaction[2]) >= 10) {
    my $reactions=$dbh->do("INSERT INTO Reactions_EnsemblPlants VALUES ('$reaction[0]','$reaction[1]','$reaction[2]','$reaction[3]')");
  } else {
    print "Erreur : cette proteine n'appartient pas a la base de donnees. Veuillez d'abord entrer la proteine a l'aide de la 1ere operation.\n"
  }
}

# corriger une sequence
sub modif_sequence(){
  print("Veuillez entrer le nom \"Entry\" de la proteine dont vous souhaitez modifier la sequence :\n");
  my $prot = <STDIN>;
  chomp($prot);
  if (check_protein($prot) < 10) {
    print "\nErreur : cette proteine n'existe pas dans la base de donnees. Veuillez entrer un autre \"Entry\".\n";
  } else {
    print("Entrez maintenant la sequence complete corrigee : ");
    my $seq = <STDIN>;
    chomp($seq);
    my $modif_sequence = $dbh->do("UPDATE Informations_Proteines_UniProt SET Sequence = '$seq' WHERE Entry = '$prot'");
  }
}

# supprimer les informations de reaction d'une proteine (que dans la table de Reactions)
sub delete_protein_EnsemblPlants() {
  print("Veuillez entrer le nom \"Entry\" de la proteine dont vous voulez supprimer les informations de reaction :\n");
  my $usr = <STDIN>;
  chomp($usr);
  if (check_protein($usr) == 1 || check_protein($usr) == 11) {
    my $delete = $dbh->do("delete from Reactions_EnsemblPlants where UniProtKB_TrEMBL_ID in (select Entry from Caracteristiques_generales_UniProt where Entry='$usr')");
    print "\nSuppression faite.\n";
  } else {
    print "\nErreur : cette proteine n'a pas de reaction. Veuillez entrer un autre \"Entry\".\n";
  }
}

# supprimer une proteine de la base de donnees
sub delete_protein_UniProt() {
  print("Veuillez entrer le nom \"Entry\" de la proteine que vous voulez supprimer de la base de donnees :\n");
  my $usr = <STDIN>;
  chomp($usr);
  if (check_protein($usr) < 10) {
    print "\nErreur : cette proteine n'existe pas dans la base de donnees. Veuillez entrer un autre \"Entry\".\n";
  } else {
    my $delete_protein = $dbh->do("delete from Informations_Proteines_UniProt where Entry='$usr'");
    my $delete_gene = $dbh->do("delete from Informations_Genes_UniProt where Entry='$usr'");
    my $delete_general = $dbh->do("delete from Caracteristiques_generales_UniProt where Entry='$usr'");
    if (check_protein($usr) == 11) {
      my $delete = $dbh->do("delete from Reactions_EnsemblPlants where UniProtKB_TrEMBL_ID in (select Entry from Caracteristiques_generales_UniProt where Entry='$usr')");
      print "Note : la proteine a une reaction referencee dans la base de donnees, qui sera aussi supprimee.\n"
    }
    print "\nSuppression faite.\n";
  }
}

# affichage de la presence de la proteine dans la base de donnees et si elle a une reaction (affiche a l'utilisateur si la proteine est presente ou non)
sub display_check_protein() {
  print "Veuillez entrer le nom \"Entry\" de la proteine dont vous voulez verifier la presence :\n";
  my $entry = <STDIN>;
  chomp($entry);
  my $check = check_protein($entry);
  if ($check == 10 || $check == 11) {
    print "=> presente dans la base de donnees\n";
  }
  if ($check == 1 || $check == 11) {
    print "=> a une reaction referencee dans la base de donnees\n";
  }
  if ($check == 0) {
    print "=> absente de la base de donnees\n";
  }
}


# verifier la presence de la proteine dans la base de donnees et si elle a une reaction (retourne une valeur utilisee pour gerer les erreurs dans d'autres fonctions)
sub check_protein() {
  my $usr = shift;
  my $check=0;
  # verification dans la table reactions
  my $check1=0;
  my $req_check_EnsemblPlants = $dbh->prepare("select UniProtKB_TrEMBL_ID from Reactions_EnsemblPlants where UniProtKB_TrEMBL_ID = '$usr'") or die $dbh->errstr();
  $req_check_EnsemblPlants->execute() or die $req_check_EnsemblPlants->errstr();
  while (my @tmp = $req_check_EnsemblPlants->fetchrow_array()) {
    $check1=1;
  }
  if ($check1==1) {
    $check+=1;
  }
  # verification de la presence de la proteine dans la base de donnees (avec ou sans reaction)
  my $check2=0;
  my $req_check_UniProt = $dbh->prepare("select Entry from Caracteristiques_generales_UniProt where Entry = '$usr'") or die $dbh->errstr();
  $req_check_UniProt->execute() or die $req_check_UniProt->errstr();
  while (my @tmp = $req_check_UniProt->fetchrow_array()) {
    $check2=1;
  }
  if ($check2==1) {
    $check+=10;
  }
  return $check;  ### si la fonction retourne 1, la proteine a une reaction // si la fonction retourne 10, la proteine est presente dans la base de donnees // si la fonction retourne 11, la proteine est presente et a une reaction
}

# afficher le nom des proteines referencees dans le fichier EnsemblPlant
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
  my @headers=("Nom de la proteine","Longueur(pb)");
  html_page("requete_proteines_EnsemblPlants",\@matrix,\@headers,"Noms des proteines referencees dans le fichier EnsemblPlants");
}

# afficher le nom des genes du fichier UniProt egalement references dans le fichier EnsemblPlant
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
    my @headers=("Nom du gene");
    html_page("requete_nom_gene",\@matrix,\@headers,"Nom des genes issus d'UniProt etant egalement references dans EnsemblPlant");
}

#  afficher les proteines ayant une longueur au moins egale a une valeur donnee
sub get_longueur(){
  my @matrix;
  my $i=1;
  print("Entrez une longueur de sequence proteique (en pb) pour obtenir la liste des proteines ayant une sequence d'une longueur au moins egale.\n");
  my $size = <STDIN>;
  my $reqsize = $dbh->prepare("SELECT Proteinnames,length from Informations_Proteines_UniProt where length>='$size'") or die $dbh->errstr();
  $reqsize->execute() or die $reqsize->errstr();
  while (my @protsize = $reqsize->fetchrow_array()){
    print $i," - ",join(" ",@protsize),"\n";
    push @matrix,[@protsize];
    $i++;
  }
  $reqsize->finish;
  my @headers=("Nom de la proteine","Longueur(pb)");
  html_page("requete_longueur",\@matrix,\@headers,"Proteines ayant une longueur superieure ou egale a $size pb");
}

# afficher les caracteristiques des proteines correspondant a un EC number donne
sub get_caract_protein() {
  my @matrix;
  print "Entrez un EC number (sans reecrire \"EC\") : ";
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
    print "Aucune proteine correspond a cet EC number.\n";
  }
  $req_ECnumber->finish;
  my @headers=("Entree","Nom de la proteine","Longueur (en pb)","Sequence proteique");
  html_page("requete_caracteristiques_proteine",\@matrix,\@headers,"Caracteristiques des proteines ayant comme E.C number : $ECn");
}

# creer une page html contenant les resultats
sub html_page(){
  print "\nVoulez-vous enregistrer ces resultats dans un fichier html ?\n1 - Oui\n0 - Non\nVotre choix : ";
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
    print ("\n\n====== Vous avez genere le fichier --> $requete.html <-- associe a votre demande ======\n\n");
  }
}

sub menu(){
  print "\nQue voulez-vous faire ?\n1 - Ajouter une proteine\n2 - Ajouter une reaction\n3 - Corriger une sequence\n4 - Supprimer une proteine de la base de donnees\n5 - Supprimer les informations de reaction d'une proteine (de la table Reactions)\n6 - Verifier la presence d'une proteine dans la base de donnees\n7 - Afficher le nom (UniProt ID) des proteines referencees dans le fichier EnsemblPlant\n8 - Afficher le nom des genes du fichier UniProt qui sont egalement references dans le fichier EnsemblPlant\n9 - Afficher les proteines ayant une longueur au moins egale a une valeur donnee\n10- Afficher les caracteristiques des proteines correspondant a un EC number donne\n0 - Quitter le programme\n\nVotre choix : ";
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
          insert_reaction();
        }
        case 3 {
          modif_sequence();
        }
        case 4 {
          delete_protein_UniProt();
        }
        case 5 {
          delete_protein_EnsemblPlants();
        }
        case 6 {
          display_check_protein();
        }
        case 7 {
          get_protein_EnsemblPlant();
        }
        case 8 {
          get_gene_UniProtANDEnsemblPlant();
        }
        case 9 {
          get_longueur();
        }
        case 10 {
          get_caract_protein();
        }
        else {
          print "Desole, ceci n'est pas une option disponible.\n";
        }
      }
      menu();
      $answer=<STDIN>;
      chomp($answer);
  }
}

main();

$dbh->disconnect();
