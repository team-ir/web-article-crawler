#!/usr/bin/perl

use strict;
use warnings;

open(INPUT, "../docresult.txt");
open(OUTPUT, "> ../doc/article.txt");

my $tag = '';
my $take_next = 0;
my $stillvalid = 0;

while(<INPUT>) {
    chomp;
    if ($take_next) {
        s/"linebreak"/\n/gi;
        print OUTPUT $_."\n";
        $take_next = 0;
        $stillvalid = 1;
    } elsif ($tag eq 'isi_berita' && split(/\s+/, $_) > 10 && $stillvalid) {
        s/"linebreak"/\n/gi;
        print OUTPUT $_."\n";
    } else {
        $tag = '';
        $stillvalid = 0;
    }

    if ($_ eq 'judul_berita' || $_ eq 'isi_berita'
        || $_ eq 'tanggal_berita' || $_ eq 'link_berita') {
        $tag = $_;
        $take_next = 1;
    }
}

close INPUT;
close OUTPUT;
