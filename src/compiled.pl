#!/usr/local/bin/perl

use strict;
use warnings;

use feature 'say';
use LWP::Simple;

# open(INPUT, "testpage.html") or die "failed to open INPUT file";
# my @lines = <INPUT>;

open(OUTPUT, "> ../doc/result.txt") or die "failed to open OUTPUT file.";

my $url = "http://tekno.kompas.com/read/xml/2015/03/22/13300217/Siang.Ini.Balon.Google.Melintas.di.Laut.Jawa";
say "Downloading page from $url..";

my $html = get($url) or die "Could not fetch page.";
my @lines = split /[\r\n]+/, $html;

say "Page downloaded successfully.";
say "Processing HTML tags..";

foreach (@lines) {
    chomp;
    if(/<(.*?)>/){
        s/<!-- (.*?) -->//gi;
        s/<title>/judul_berita\n/;
        s/<.*?(span6 nml|isi_artikel|isi_berita pt_5|div-read).>/isi_berita/;
        s/<.*?(grey small mb2|font11 c_abu03_kompas2011 pb_3).>/tanggal_berita/;
        if (/og:url/) {
            my @part = split(/"|'/);
            $_ = "link_berita\n".$part[3];
        }

        s/<br \/>|<\/p>/"linebreak"/gi;
        s/^\s+|\s+$//gi;
        s/&nbsp;/ /gi;
        s/&quot;|&ldquo;|&rdquo;/"/gi;
        s/&mdash;/-/gi;
        s/<(.*?)>//gi;

        if($_ ne ""){
            say OUTPUT;
        }
    }
}

close INPUT;
close OUTPUT;

say "HTML tags removed.";
say "Extracting article..";

open(INPUT, "result.txt") or die "failed to open INPUT file.";
open(OUTPUT, ">article.txt") or die "failed to open OUTPUT file.";

my $valid = 0;
my $take_next = 0;
my $tag = '';

while(<INPUT>) {
    chomp;
    if ($take_next) {
        s/"linebreak"/\n/gi;
        print OUTPUT $tag.":\n".$_."\n\n";

        $take_next = 0;
        $valid = 1;
    } elsif ($tag eq 'ISI' && split > 10 && $valid) {
        s/"linebreak"/\n/gi;
        say OUTPUT;
    } else {
        $tag = '';
        $valid = 0;
    }
    # if ($_ eq 'judul_berita' || $_ eq 'isi_berita'
    #     || $_ eq 'tanggal_berita' || $_ eq 'link_berita') {
    #     $take_next = 1;
    # }
    if (/link_berita/) {
        $take_next = 1;
        $tag = 'SOURCE';
    } elsif (/judul_berita/) {
        $take_next = 1;
        $tag = 'JUDUL';
    } elsif (/tanggal_berita/) {
        $take_next = 1;
        $tag = 'TANGGAL';
    } elsif (/isi_berita/) {
        $take_next = 1;
        $tag = 'ISI';
    }
}

close INPUT;
close OUTPUT;

say "Article successfully extracted.";
say "Done.";
