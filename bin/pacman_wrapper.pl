#!/usr/bin/perl
# This is like pacman(1), but prepends "sudo" when necessary.
use strict;
use warnings;
use v5.20;

# can only decide whether to add sudo if @ARGV has options in front
my $options = $ARGV[0] // '';
exec 'pacman', @ARGV unless $options =~ /^-/;

# decide whether to sudo or not
my $sudo = 0;
if ($options =~ /D/) {
   $sudo = $options !~ /k/;
}
elsif ($options =~ /S/) {
   $sudo = $options =~ /y/ || $options !~ /[gilps]/;
}
elsif ($options =~ /[RU]/) {
   $sudo = $options !~ /p/;
}
elsif ($options =~ /F/) {
   $sudo = $options =~ /y/;
}

exec($sudo ? 'sudo' : (), 'pacman', @ARGV);
