#!bin/perl
use warnings;
use strict;
use DBI;

sub html_page($requete){
  open (HTML,">>$requete.html");
  close(HTML);
}
