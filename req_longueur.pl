#!bin/perl
use warnings;
use strict;
use DBI;
use Switch;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

sub req_longueur(){
  my @matrix;
  my $i=0;
  print @matrix;
  print("Entrez une longueur de séquence protéique (en pb) pour obtenir la liste des proteines ayant une séquence d'une longueur au moins égale.\n");
  my $size = <STDIN>;
  my $reqsize = $dbh->prepare("SELECT Proteinnames,length from Informations_Proteines_UniProt where length>='$size'") or die $dbh->errstr();
  $reqsize->execute() or die $reqsize->errstr();
  while (my @protsize = $reqsize->fetchrow_array()){
    print join(" ",@protsize),"\n";
    push @matrix,[@protsize];
  }
  $reqsize->finish;
  # print "\n",join(" ",@matrix),"\n";
  my @headers=("Nom de la protéine","Longueur(pb)");
  my $nbcolonnes = 2;
  html_page("requete_longueur",\@matrix,\@headers,$nbcolonnes);
}

sub html_page(){
  my $requete = shift;
  # my $mat = shift;
  my @matrix=@{shift()};
  # my $head = shift;
  my @headers = @{shift()};
  my $nbcolonnes = shift;
  open (HTML,">$requete.html");
  print HTML "<!DOCTYPE html>\n<html>\n<body>\n";
  print HTML "<table>";
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

  # if ($requete == 2){
  # } #requete des longueurs
}

req_longueur();

$dbh->disconnect();
