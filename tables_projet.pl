# Projet Base de Données
# fichier Création des tables  
# groupe : Elsa Claude - Amelie Gruel
# 03 avril 2019

#!bin/perl
use warnings;
use strict;
use DBI;

my $dbh = DBI->connect("DBI:Pg:dbname=elclaude;host=dbserver","elclaude","*Cochon04111997",{'RaiseError' => 1});

## SUPPRESSION AUTOMATIQUE DES TABLES - pour permettre de les modifier apres-coup
# $dbh->do("drop table Caracteristiques_generales_UniProt cascade");
# $dbh->do("drop table Informations_Proteines_UniProt cascade");
# $dbh->do("drop table Informations_Genes_UniProt cascade");
# $dbh->do("drop table Reactions_EnsemblePlantes cascade");

## CREATION DES TABLES

# création de la table Caracteristiques Generales UniProt
$dbh->do("create table Caracteristiques_generales_UniProt (
    Entry varchar(50) constraint entree primary key,
    EntryName varchar(50),
    Status varchar(50) constraint etat check (Status in ('reviewed','unreviewed')),
    Organism varchar(50),
    EnsemblePlantTranscript text
)");

# creation de la table Informations Proteines UniProt
$dbh->do("create table Informations_Proteines_UniProt (
    Entry varchar(50) constraint entree_proteines primary key references Caracteristiques_generales_UniProt(Entry),
    ProteinNames text,
    Length int constraint longueur check (Length > 0),
    Sequence text
)");

# création de la table Informations Genes UniProt
$dbh->do("create table Informations_Genes_UniProt (
    Entry varchar(50) constraint entree_genes primary key references Caracteristiques_generales_UniProt(Entry),
    GeneName text,
    SynonymGeneName text,
    GeneOntology text
)");

#création de la table Reactions_EnsemblePlantes
$dbh->do("create table Reactions_EnsemblePlantes(
    Gene_Stable_ID varchar(50) constraint syntaxe_Gene_ID CHECK(SUBSTR(Gene_Stable_ID,1,2)='AT'),
    Transcript_stable_ID varchar(50) constraint syntaxe_Transcript_ID CHECK(SUBSTR(Transcript_stable_ID,1,2)='AT'),
    UniProtKB_TrEMBL_ID varchar(50) constraint uniprot_trembl primary key references Caracteristiques_generales_UniProt(Entry),
    Plant_Reactome_Reaction_ID varchar(50)
)");

$dbh->disconnect();
