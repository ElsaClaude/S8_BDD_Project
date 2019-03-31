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
  my @ecran=("Veuillez entrez : \n Entry","Entry Name","Status (reviewed ou unreviewed)","Organisme","EnsemblePlantTranscript","ProteinNames","Length","Sequence");
  for my $e (@ecran) {
      print "$e : ";
      my $usr=<STDIN>;
      chomp($usr);
      push(@protein,$usr);
    }
  my $insert_general = $dbh->do("INSERT INTO Caracteristiques_generales_UniProt VALUES ('$protein[0]','$protein[1]','$protein[2]','$protein[3]','$protein[4]')");
  my $insert_protein = $dbh->do("insert into Informations_Proteines_UniProt values('$protein[0]','$protein[5]','$protein[6]','$protein[7]')");
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
    my @matrix;
    my $req_gene = $dbh->prepare("select GeneName from Informations_Genes_Uniprot G join Reactions_EnsemblePlantes E on G.Entry = E.UniProtKB_TrEMBL_ID") or die $dbh->errstr();
    $req_gene->execute() or die $req_gene->errstr();
    my $i=1;
    while (my @gene = $req_gene->fetchrow_array()) {
      print $i," - ",join(" ",@gene),"\n";
      $i++;
      push @matrix,[@gene];
    }
    $req_gene->finish;
    my @headers=("Nom du gène");
    html_page("requete_nom_gene",\@matrix,\@headers,"Nom des gènes issus d'UniProt étant également référencés dans EnsemblPlant");
}

#  afficher les protéines ayant une longueur au moins égale à une valeur donnée
sub req_longueur(){
  my @matrix;
  print("Entrez une longueur de séquence protéique (en pb) pour obtenir la liste des proteines ayant une séquence d'une longueur au moins égale.\n");
  my $size = <STDIN>;
  my $reqsize = $dbh->prepare("SELECT Proteinnames,length from Informations_Proteines_UniProt where length>='$size'") or die $dbh->errstr();
  $reqsize->execute() or die $reqsize->errstr();
  while (my @protsize = $reqsize->fetchrow_array()){
    print join(" ",@protsize),"\n";
    push @matrix,[@protsize];
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
    html_page("requete_caracteristiques_proteine",\@matrix,\@headers,"Caractéristiques des protéines ayant comme E.C : $ECn");
}

sub html_page(){
  my $requete = shift;
  # my $mat = shift;
  my @matrix=@{shift()};
  # my $head = shift;
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

sub menu(){
  print "Que voulez-vous faire ?\n1 - Ajouter une protéine\n2 - Corriger une séquence\n3 - Afficher le nom (UniProt ID) des protéines référencées dans le fichier EnsemblPlant\n4 - Afficher le nom des gènes du fichier UniProt qui sont également référencés dans le fichier EnsemblPlant\n5 - Afficher les protéines ayant une longueur au moins égale à une valeur donnée\n6 - Afficher les caractéristiques des protéines correspondant à un EC number donné\n0 - Quitter le programme\n\nVotre choix : ";
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
            menu();
        }
        case 2 {
            modif_sequence();
            menu();
        }
        case 3 {
            get_protein_EnsemblPlant();
            menu();
        }
        case 4 {
            get_gene_UniProtANDEnsemblPlant();
            menu();
        }
        case 5 {
            req_longueur();
            menu();
        }
        case 6 {
            get_caract_protein();
            menu();
        }
        else {
            print "Désolé, ceci n'est pas une option disponible.\n";
        }
      }
      $answer=<STDIN>;
      chomp($answer);
  }
}

main();

$dbh->disconnect();
