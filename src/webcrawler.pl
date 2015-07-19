#!/usr/bin/perl

use strict;
use warnings;

use feature "say";
use LWP::Simple;

sub RefreshURLlist {
    open(OUTPUT, "> ../res/URLlist.txt");

    my $html = get("http://indeks.kompas.com") or die "Could not fetch page.";
    while($html =~ /(http:\/\/.*?\/read.*?)"/g){
        say OUTPUT $1;
    }

    say "Done.";
    close OUTPUT;
}
1;
