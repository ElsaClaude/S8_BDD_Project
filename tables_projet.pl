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
    EnsemblePlantTranscript text
)");

# création de la table Informations Protéines UniProt
$dbh->do("create table Informations_Protéines_UniProt (
    Entry varchar(50) constraint entrée_protéines primary key references Caractéristiques_générales_UniProt(Entry),
    ProteinNames text,
    Length int constraint longueur check (Length > 0),
    Sequence text
)");

# création de la table Informations Gènes UniProt
$dbh->do("create table Informations_Gènes_UniProt (
    Entry varchar(50) constraint entrée_gènes primary key references Caractéristiques_générales_UniProt(Entry),
    GeneName text,
    SynonymGeneName text,
    GeneOntology text
)");

#création de la table Réactions_EnsemblePlantes
$dbh->do("create table Réactions_EnsemblePlantes(
    Gene_Stable_ID varchar(50) constraint syntaxe_Gene_ID CHECK(SUBSTR(Gene_Stable_ID,1,2)='AT'),
    Transcript_stable_ID varchar(50) constraint syntaxe_Transcript_ID CHECK(SUBSTR(Transcript_stable_ID,1,2)='AT'),
    UniProtKB_TrEMBL_ID varchar(50) constraint uniprot_trembl references Caractéristiques_générales_UniProt(Entry),
    Plant_Reactome_Reaction_ID varchar(50),
    primary key (UniProtKB_TrEMBL_ID,Plant_Reactome_Reaction_ID)

)");

$dbh->disconnect();
