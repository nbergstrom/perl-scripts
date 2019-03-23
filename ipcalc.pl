#!/usr/bin/perl
#
# Calculate network information from IPv4 address and netmask
# Requires Regexp::Common from CPAN
#

use strict;
use warnings;
use Regexp::Common qw(net number);

unless (@ARGV >= 2) {
    print "Usage: $0 ipv4-address netmask [flag].\n";
    print "Ex: $0 192.168.10.9 24\n";
    print "Optional flags:\n\t-x: output hexadecimal\n\t-b: output binary\n";
    exit;
}

my $ip = $ARGV[0];
my $sn = $ARGV[1];
my $flag = $ARGV[2] || "";

if ($ip =~ /^$RE{net}{IPv4}$/) {
    if ($sn =~ /^$RE{num}{int}$/ && ($sn >= 0 and $sn <= 32)) {
        
        my @ip = split /\./, $ip;
        my @subnet_address;
        
        my $full_bytes = int($sn / 8);
        my $remaining = $sn % 8;
        my $addresses = (2 ** (32 - $sn));
        my $hosts =  $addresses - 2;
        $hosts = 0 if $hosts < 0;

        # build subnet mask
        for (my $i = 0; $i < 4; $i++) {
            if ($i < $full_bytes) {
                $subnet_address[$i] = 255;
            } else {
                $subnet_address[$i] = bits2dec($remaining);
                $remaining = 0;
            }
        }
        
        my @network_address;
        my @broadcast_address;
        foreach (0 .. $#ip) {
            # do bitwise AND operation to find out network address
            $network_address[$_] = $ip[$_] & $subnet_address[$_];
            # do bitwise OR operation on inverted subnet address to 
            #   find out broadcast address
            # since the inversion returns a 32- or 64-bit value, do a bitwise 
            #   AND operation with an 8-bit mask to remove the extra bits
            $broadcast_address[$_] = 
                $network_address[$_] | (~$subnet_address[$_] & 0xFF);
        } 
        
        my $spacing = -20;

        printf "%*s %s\n", $spacing, "IP address", format_ip(\@ip);
        printf "%*s %s\n", $spacing, "Subnet mask", 
            format_ip(\@subnet_address);
        printf "%*s %s\n", $spacing, "Network address", 
            format_ip(\@network_address);
        printf "%*s %s\n", $spacing, "Broadcast address", 
            format_ip(\@broadcast_address);
        printf "%*s %d\n", $spacing, "Addresses", $addresses;
        printf "%*s %d\n", $spacing, "Maximum hosts", $hosts;
        
    } else {
        print "Invalid subnet\n";
    }
} else {
    print "Invalid IP\n";
}

sub format_ip {
    my $ipref = shift;
    my $string = "";
    
    foreach my $octet (@$ipref) {
        if ($flag eq "-x") {
            $string .= sprintf "%02x.", $octet;
        } elsif ($flag eq "-b") {
            $string .= sprintf "%08b.", $octet;
        } else {
            $string .= sprintf "%d.", $octet;
        }
    }
    $string =~ s/\.\z//; # remove last dot
    
    return $string;
}

# convert subnet octet to decimal
sub bits2dec {
    my $num = shift;
    my $msb = 128;
    my $result = 0;
    
    for (my $i = 0; $i < $num; $i++) {
        $result += $msb;
        $msb = $msb / 2;
    }
    
    return $result;
}