#!bin/perl

# vérifier la présence de la protéine dans les tables UniProt et EnsemblPlants
sub check_protein() {
  print "Veuillez entrer le nom \"Entry\" de la protéine dont vous voulez vérifier la présence :\n";
  my $usr = <STDIN>;
  my $check1=0;
  my $check2=0;
  my $check=0;
  my $req_check_EnsemblPlants = $dbh->prepare("select UniProtKB_TrEMBL_ID from Reactions_EnsemblPlants where UniProtKB_TrEMBL_ID = '$usr'") or die $dbh->errstr();
  my $req_check_UniProt = $dbh->prepare("select Entry from Caracteristiques_generales_UniProt where Entry = '$usr'") or die $dbh->errstr();
  $req_check_EnsemblPlants->execute() or die $req_check_EnsemblPlants->errstr();
  $req_check_UniProt->execute() or die $req_check_UniProt->errstr();
  while (my @tmp = $req_check_EnsemblPlants->fetchrow_array()) {
    $check1=1;
  }
  while (my @tmp = $req_check_UniProt->fetchrow_array()) {
    $check2=1;
  }
  if ($check1==1) {
    print "présente dans la table EnsemblPlants\n";
    $check+=1;
  }
  if ($check2==1) {
    print "présente dans les tables UniProt\n";
    $check+=10;
  }
  return $check;  ### si la fonction retourne 1, la protéine est présente dans EnsemblPlants // si la fonction retourne 10, la protéine est présente dans UniProt // si la fonction retourne 11, la protéine est présente dans les 2
}
