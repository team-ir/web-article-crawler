#!/usr/bin/perl

use strict;
use warnings;

my %count = ();
my $sc = 0;
my $take_next = 0;

open(INPUT, "../doc/article.txt") or die "failed to open INPUT file";
open(OUTPUT, "> ../doc/indeks.txt") or die "failed to open INPUT file";

while(<INPUT>) {
    chomp;
    if ($take_next) {
        my @lc = split(/\./);
        $sc += scalar @lc;

        tr/A-Z/a-z/;
        tr/.,:;!?"(){}//d;

        foreach my $wd (split(/\s+/)) {
            if(exists($count{$wd})) {
                $count{$wd}++;
            } else {
                $count{$wd} = 1;
            }
        }
    }

    if (/ISI:/) {
        $take_next = 1;
    }
    # print "$line\n";
}
close INPUT;

my $wc = 0;
foreach my $w (sort {$count{$b} <=> $count{$a}} keys %count) {
    print OUTPUT "$w : $count{$w}\n";
    $wc += $count{$w};
}
print OUTPUT "\nWord     : ".$wc."\n";
print OUTPUT "Sentence : ".$sc."\n";

close OUTPUT;
