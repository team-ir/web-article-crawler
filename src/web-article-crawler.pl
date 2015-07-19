#!/usr/local/bin/perl

use strict;
use warnings;

use feature 'say';
use LWP::Simple;

require 'webcrawler.pl';

my %wordlist;
my @doc;
my $index = 1;

my $cmd = 0;
while ($cmd != 3) {
    Clear();

    say "1) refresh URL list";
    say "2) process URLs' articles";
    say "3) exit";
    print "? ";
    $cmd = <STDIN>;

    Clear();
    if ($cmd == 1) {
        RefreshURLlist();
        Pause();
    } elsif ($cmd == 2) {
        open(INPUT, "../res/URLlist.txt") or die "failed to open INPUT file.";
        open(OUTPUT, "> ../doc/articles.doc") or die "failed to open OUTPUT file.";

        while(<INPUT>) {
            chomp;
            say "Processing page ".$index++."..";
            my $raw = RemoveTags($_);
            say "Extracting articles";
            push @doc, {ExtractArticles($raw)};
        }

        close INPUT;
        close OUTPUT;

        %wordlist = CompileWords(\@doc);
        PrintTFIDFtoFile(\%wordlist, \@doc);

        say "Done.";
        Pause();
    }
}

# -----

sub RemoveTags {
    my $html = get($_[0]) or die "Could not fetch page.";
    my @lines = split /[\r\n]+/, $html;
    my $result;

    foreach my $line (@lines) {
        chomp $line;
        if($line =~ /<(.*?)>/){
            $line =~ s/<!-- (.*?) -->//gi;
            $line =~ s/<title>/judul_berita\n/;
            $line =~ s/<.*?(span6 nml|isi_artikel|isi_berita pt_5|div-read).>/isi_berita/;
            $line =~ s/<.*?(grey small mb2|font11 c_abu03_kompas2011 pb_3).>/tanggal_berita/;
            if ($line =~ /og:url/) {
                my @part = split(/"|'/, $line);
                $line = "link_berita\n".$part[3];
            }

            $line =~ s/<br \/>|<\/p>/"linebreak"/gi;
            $line =~ s/^\s+|\s+$//gi;
            $line =~ s/&nbsp;/ /gi;
            $line =~ s/&quot;|&ldquo;|&rdquo/"/gi;
            $line =~ s/&mdash;/-/gi;
            $line =~ s/<(.*?)>//gi;

            if($line ne ''){
                $result .= $line."\n";
            }
        }
    }
    return $result;
}

sub ExtractArticles {
    my $tag = '';
    my $valid = 0;
    my $take_next = 0;
    my %wordlist = ();

    foreach my $line (split /\n/, $_[0]) {
        chomp $line;
        if ($take_next) {
            $line =~ s/"linebreak"/\n/gi;
            say OUTPUT $line;

            if ($tag eq 'isi_berita') {
                %wordlist = WordCount($line, \%wordlist);
            }

            $take_next = 0;
            $valid = 1;
        } elsif ($tag eq 'isi_berita' && split(/\s+/, $line) > 10 && $valid) {
            $line =~ s/"linebreak"/\n/gi;
            say OUTPUT $line;

            %wordlist = WordCount($line, \%wordlist);
        } else {
            $tag = '';
            $valid = 0;
        }

        if ($line eq 'judul_berita' || $line eq 'isi_berita'
            || $line eq 'tanggal_berita' || $line eq 'link_berita') {
            $tag = $line;
            $take_next = 1;
        }
    }
    say OUTPUT "________________________________________________________________________________";
    return %wordlist;
}

sub WordCount {
    my %count = %{$_[1]};
    my $line = $_[0];
    chomp $line;

    $line =~ tr/A-Z/a-z/;
    $line =~ tr/.,:;!?"(){}\///d;

    foreach my $word(split /\s+/, $line) {
        if(exists $count{$word}) {
            $count{$word}++;
        } else {
            $count{$word} = 1;
        }
    }

    return %count;
}

sub log10 {
    return log($_[0]) / log(10);
}

sub CompileWords {
    my %wordlist;
    my $total = 0;
    foreach my $itemhash (@{$_[0]}) {
        foreach my $word (keys %$itemhash) {
            if (exists $wordlist{$word}) {
                ++$wordlist{$word};
            } else {
                $wordlist{$word} = 1;
            }
            ++$total;
        }
    }
    $wordlist{'TOTALWORD'} = $total;
    return %wordlist;
}

sub PrintTFIDFtoFile {
    open(PRINT, ">tf-idf.xls") or die "failed to open OUTPUT file";

    my %wordlist = %{$_[0]};
    my $total_doc = scalar @{$_[1]};

    say PRINT "Word\tTotal Frequency\tTF\tIDF\tTF-IDF";

    foreach my $key (sort keys %wordlist) {
        if ($key ne 'TOTALWORD') {
            my $word_found = 0;

            foreach my $hash (@{$_[1]}) {
                if (exists ${$hash}{$key}) {
                    ++$word_found;
                }
            }

            # tf-idf total
            my $tf = $wordlist{$key}/$wordlist{'TOTALWORD'};
            my $idf = log10($total_doc/$word_found);
            my $tf_idf = $tf * $idf;

            say PRINT "$key\t$wordlist{$key}\t$tf\t$idf\t$tf_idf";
        }
    }
    close PRINT;
}

sub Clear {
    for (my $i = 0; $i < 60; $i++) {
        say "";
    }
}

sub Pause {
    say "press ENTER to continue..";
    my $dump = <STDIN>;
}
