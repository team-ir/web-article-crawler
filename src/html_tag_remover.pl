#!/usr/local/bin/perl

use strict;
use warnings;
use feature 'say';
use LWP::Simple;

open(INPUT, "../res/testpage.html");
open(OUTPUT, "> ../doc/result.txt");

local $/ = undef;
my $html = <INPUT>;
close INPUT;

# my $html = get("http://megapolitan.kompas.com/read/2015/03/20/18243401/Lulung.Kejawab.Nih.yang.Pengin.Deadlock.Siapa")
#             or die "Could not fetch page.";

my @lines = split /[\r\n]+/, $html;
foreach (@lines) {
    chomp;
    if(/<(.*?)>/){
        s/<!-- (.*?) -->//gi;
        s/<title>/judul_berita\n/;
        s/<.*?(span6 nml|isi_artikel|isi_berita pt_5).>/isi_berita/;
        s/<.*?(grey small mb2|font11 c_abu03_kompas2011 pb_3).>/tanggal_berita/;
        if (/og:url/) {
            my @part = split(/"|'/);
            $_ = "link_berita\n".$part[3];
        }
        # if (/[A-Z|a-z]+, [0-9]+ [A-Z|a-z]+ [0-9]+/) {
        #     $_ = "tanggal_berita\n".$_;
        # }

        s/<br \/>|<\/p>/"linebreak"/gi;
        s/^\s+|\s+$//gi;
        s/&nbsp;/ /gi;
        s/&quot;|&ldquo;|&rdquo/"/gi;
        s/&mdash;/-/gi;
        s/<(.*?)>//gi;

        if($_ ne ""){
            say OUTPUT;
        }
    }
}

say "Done.";
close OUTPUT;
