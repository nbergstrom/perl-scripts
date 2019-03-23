#!/usr/bin/perl
#
# Display end of support dates for Microsoft Windows operating systems
# Requires Time::Moment from CPAN
#

use strict;
use warnings;
use Time::Moment;
use List::Util qw(max);

my $flag = $ARGV[0] || "";

if ($flag eq "-h") {
    print "Supported flags:\n\t-a: show all\n\t-o: show obsolete\n";
    exit;
}

# extended support end dates for Microsoft products go here
# format: name => arrayref (yyyy, mm, dd)
my %operating_systems = (
    "NT 3.1"                        => [2000, 12, 31],
    "95"                            => [2001, 12, 31],
    "NT 3.51 Workstation"           => [2001, 12, 31],
    "NT 3.51 Server"                => [2002,  9, 30],
    "NT 4.0"                        => [2004,  6, 30],
    "98"                            => [2006,  7, 11],
    "ME"                            => [2006,  7, 11],
    "2000"                          => [2010,  7, 13],
    "XP"                            => [2014,  4,  8],
    "Fundamentals for Legacy PCs"   => [2014,  4,  8],
    "Home Server 2011"              => [2016,  4, 12],
    "Embedded Standard 2009"        => [2019,  1,  8],
    "Embedded POSReady 2009"        => [2019,  4,  9],
    "Vista"                         => [2017,  4, 11],
    "7"                             => [2020,  1, 14],
    "8"                             => [2016,  1, 12],
    "8.1"                           => [2023,  1, 10],
    "Server 2003"                   => [2015,  7, 14],
    "Server 2008 (R2)"              => [2020,  1, 14],
    "Server 2012 (R2)"              => [2023, 10, 10],
    "Server 2016"                   => [2027,  1, 12],
    "10 Enterprise 2015 LTSB"       => [2025, 10, 14],
    "10 Enterprise 2016 LTSB"       => [2026, 10, 13],
    "10 Enterprise 2019 LTSC"       => [2029,  1,  9],
);

# get current time
my $now = Time::Moment->now;
my @months = qw(
    January February March April May June July August September October 
    November December);

# build hash of Time::Moment objects
my %dates = map { 
    "Windows " . $_ => Time::Moment->new(
        year => $operating_systems{$_}->[0], 
        month => $operating_systems{$_}->[1], 
        day => $operating_systems{$_}->[2]
    )} keys %operating_systems;

my @oslist = keys %dates;
my @list_to_use = ();

# determine which list to use based on command line arguments
if ($flag eq "-a") {
    # all
    @list_to_use = @oslist;
} elsif ($flag eq "-o") {
    # obsolete
    @list_to_use = grep { $dates{$_} < $now } @oslist;
} else {
    # current
    @list_to_use = grep { $dates{$_} > $now } @oslist;
}

# find out longest OS name so we can format output properly
my $max_len = max map { length($_) } @list_to_use;
$max_len += 2;

my $width = 50 + $max_len;

printf "%*s", -$max_len, "Operating System";
printf "%s", "End of Support\n";
print "=" x $width;
print "\n";

foreach my $os (sort { 
        # primary sort by date, ascending
        # secondary sort by OS name
        $dates{$a}->epoch <=> $dates{$b}->epoch
        or
        $a cmp $b
    } @list_to_use) {
    my $delta = $now->delta_days($dates{$os});
    my $d_years = abs($now->delta_years($dates{$os}));
    my $d_months = abs($now->delta_months($dates{$os})) % 12;
    
    # if the OS has a negative number of days left, it's obsolete
    my $obsolete = ($delta < 0 ? 1 : 0);

    printf "%*s", -$max_len, $os;
  
    printf "%s %02d, %04d", 
        $months[$dates{$os}->month - 1],
        $dates{$os}->day_of_month, 
        $dates{$os}->year;
  
    printf "\n%*s%d days ", -$max_len, " ", abs($delta);
    
    if ($d_years > 0 && $d_months > 0) {
        printf "or %d year(s) and %d month(s) ", $d_years, $d_months;
    } elsif ($d_months > 0) {
        printf "or %d month(s) ", $d_months;
    }
    
    print ($obsolete ? "ago" : "from now");
    print "\n";
    print "-" x $width;
    print "\n";
}