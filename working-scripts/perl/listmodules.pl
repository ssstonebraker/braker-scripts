#!/usr/bin/perl -w
# listmodules.pl
#
# Displays currently installed perl modules
use ExtUtils::Installed;
my $inst    = ExtUtils::Installed->new();
my @modules = $inst->modules();
 foreach $module (@modules){
      print $module . "\n";
}