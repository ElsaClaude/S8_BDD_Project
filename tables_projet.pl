#!bin/perl
use warnings;
use strict;
use DBI;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

## SUPPRESSION AUTOMATIQUE DES TABLES - pour permettre de les modifier après-coup
$dbh->do("drop table Caractéristiques_générales_UniProt cascade");
$dbh->do("drop table Informations_Protéines_UniProt cascade");
$dbh->do("drop table Informations_Gènes_UniProt cascade");
$dbh->do("drop table Réactions_EnsemblePlantes cascade");

## CREATION DES TABLES

# création de la table Caractéristiques Générales UniProt
$dbh->do("create table Caractéristiques_générales_UniProt (
    Entry varchar(50) constraint entrée primary key,
    EntryName varchar(50),
    Status varchar(50) constraint état check (Status in ('reviewed','unreviewed')),
    Organism varchar(50),
    EnsemblePlantTranscript varchar(150) constraint ensemblePlante unique CHECK(SUBSTR(EnsemblePlantTranscript,1,2)='AT')
)");

# création de la table Informations Protéines UniProt
$dbh->do("create table Informations_Protéines_UniProt (
    Entry varchar(50) constraint entrée_protéines primary key references Caractéristiques_générales_UniProt(Entry),
    ProteinNames varchar(400),
    Length int constraint longueur check (Length > 0),
    Sequence varchar(1500)
)");

# création de la table Informations Gènes UniProt
$dbh->do("create table Informations_Gènes_UniProt (
    Entry varchar(50) constraint entrée_gènes primary key references Caractéristiques_générales_UniProt(Entry),
    GeneName varchar(200),
    SynonymGeneName varchar(150),
    GeneOntology varchar(1000)
)");

#création de la table Réactions_EnsemblePlantes
$dbh->do("create table Réactions_EnsemblePlantes(
    Gene_Stable_ID varchar(50) constraint syntaxe_Gene_ID CHECK(SUBSTR(Gene_Stable_ID,1,2)='AT'),
    Transcript_stable_ID varchar(50) constraint syntaxe_Transcript_ID CHECK(SUBSTR(Transcript_stable_ID,1,2)='AT') references Caractéristiques_générales_UniProt(EnsemblePlantTranscript),
    UniProtKB_TrEMBL_ID varchar(50) constraint uniprot_trembl references Caractéristiques_générales_UniProt(Entry) primary key,
    Plant_Reactome_Reaction_ID varchar(50) constraint syntaxe_Reactome_ID CHECK(SUBSTR(Plant_Reactome_Reaction_ID,1,6)='R-ATH-'))"
);

$dbh->disconnect();