#!/usr/bin/perl
#
# Generate unique random numbers
# Requires Math::Random::Secure from CPAN
#

use strict;
use warnings;
use Math::Random::Secure qw(irand);
use List::Util qw(none);
use Getopt::Long;

# defs
my $start = 1;
my $end = 40;
my $count = 7;
my $debug = 0;

GetOptions("start=i" => \$start,
            "end=i", => \$end,
            "count=i" => \$count,
            "debug" => \$debug)
or do { 
    print "Valid options:\n";
    print "\t--start [-s] integer\n\t--end [-e] integer" . 
        "\n\t--count [-c] integer\n\t--debug [-d]\n";
    exit;
};

die "Error: can't begin at $start and count up to $end\n" if $start >= $end;
# print $end - $start;
die "Error: can't generate enough random numbers with given options.\n" 
    if ($end - $start < $count);

print "Generating $count numbers between $start and $end\n";
            
my @results;

for (my $i = 0; $i < $count; $i++) {
    my $num = irand($end) + 1;

    redo if ($num < $start);
    
    print "Found $num\n" if $debug;
    
    if (none { $_ == $num } @results) {
        push @results, $num;
    } else {
        redo;
    }
}

print map { "$_ " } (sort { $a <=> $b } @results);
print "\n";