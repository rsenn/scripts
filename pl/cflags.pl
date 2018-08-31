#!/usr/bin/env perl

# TODO: Differentiate between 32- and 64-bits

use strict;
use warnings;
use Sys::Info;
use version;

my $gccversion;
my $cputype;
my $isllvm;
my $cflags;

my $fin;
open($fin, '-|', 'gcc --version 2>&1');
if((!$fin) || eof($fin)) {
  open($fin, '-|', 'cc --version 2>&1');
  die "Can't find C compiler" if(!defined($fin));
}
my $gccinfo = do { local $/; <$fin> };
close($fin);
if($gccinfo =~ /\s([\d\.]+)/) {
  $gccversion = $1;
} elsif($gccinfo =~ /LLVM\sversion\s([\d\,]+)/s) {
  $gccversion = $1;
  $isllvm = 1;
}

my $cpu = Sys::Info->new()->device('CPU');

my @i =  $cpu->identify();
my $info = $i[0];
if($info) {
  if($info->{'architecture'} eq 'AMD-64') {
    $cputype = 'amd';
  } elsif($info->{'name'} =~ /^AMD/) {
    $cputype = 'amd';
  } elsif($info->{'architecture'} =~ /^AMD/i) {
    $cputype = 'amd';
  } elsif($info->{'name'} =~ /^Intel/) {
    $cputype = 'x86';
  } elsif(($info->{'architecture'} eq 'aarch64') || ($info->{'architecture'} eq 'armv7l')) {
    $cputype = 'arm';
  } elsif($info->{'architecture'} eq 'ppc') {
    $cputype = 'ppc';
  } elsif($info->{'manufacturer'} eq 'GenuineIntel') {
    $cputype = 'x86';
  } elsif($info->{'architecture'} eq 's390x') {
    $cputype = 's390x';
  } else {
    require Data::Dumper;
    Data::Dumper->import();
    print Data::Dumper->new([\$info])->Dump();
    die "Can't determine the architecture";
  }
} elsif($^O eq 'gnu') {
  $cputype = 'x86';  # I believe GNU/Hurd only runs on this
}

if(!defined($cputype)) {
  require Data::Dumper;
  Data::Dumper->import();
  print Data::Dumper->new([\@i])->Dump();
  die "Can't determine the CPU type";
}

my $warnflags = '-W -Wformat=2 -Wswitch -Wshadow -Wwrite-strings -Wuninitialized -Wall -Wpointer-arith -Wstrict-prototypes -Wstack-protector -Wextra -Wbad-function-cast -Wcast-align -Wcast-qual -Wdisabled-optimization -Wendif-labels -Wfloat-equal -Wformat-nonliteral -Winline -Wmissing-declarations -Wmissing-prototypes -Wnested-externs -Wpointer-arith -Wundef -Wformat-security';

if(($cputype eq 'amd') || ($cputype eq 'x86')) {
  $cflags = '-O2 -pipe -fomit-frame-pointer -pedantic -D_FORTIFY_SOURCE=2 -fstack-protector -ftree-vectorize';
} elsif($cputype eq 'arm') {
  $cflags = '-O2 -pipe -fomit-frame-pointer -D_FORTIFY_SOURCE=2 -fstack-protector';
} elsif($cputype eq 'ppc') {
  $cflags = '-O2 -pipe -mtune=native -fomit-frame-pointer -ffast-math -D_FORTIFY_SOURCE=2 -fstack-protector';
} elsif($cputype eq 's390x') {
  $cflags = '-O2 -pipe -fomit-frame-pointer -ffast-math -D_FORTIFY_SOURCE=2 -fstack-protector';
}

foreach my $flag (@{$info->{'flags'}}) {
  if(($flag eq 'SSE') || ($flag eq 'sse')) {
    $cflags .= ' -msse -mfpmath=sse';
  } elsif(($flag eq 'SSE2') || ($flag eq 'sse2')) {
    $cflags .= ' -msse2';
  } elsif($flag eq 'SSE3') {
    $cflags .= ' -msse3';
  } elsif(($flag eq 'ssse3') || ($flag eq 'SSSE3')) {
    $cflags .= ' -mssse3';
  } elsif(($flag eq 'SSE4.1') || ($flag eq 'sse4_1')) {
    $cflags .= ' -msse4.1';
  } elsif(($flag eq 'SSE4.2') || ($flag eq 'sse4_2')) {
    $cflags .= ' -msse4.2';
  } elsif(($flag eq 'aes') || ($flag eq 'AES')) {
    $cflags .= ' -maes';
  } elsif($flag eq 'MMX') {
    $cflags .= ' -mmmx';
  # } else {
    # print ">>>$flag\n";
  }
}

if($ENV{'CFLAGS'}) {
  foreach my $arg (split(' ', $ENV{'CFLAGS'})) {
    if($arg =~ /^-I/) {
      $cflags .= " $arg";
    }
  }
}

if($^O eq 'linux') {
  # FIXME: Probably also in Sys::Info
  open($fin, '<', '/proc/cpuinfo');
  my $cpuinfo = do { local $/; <$fin> };
  close $fin;

  if($cpuinfo =~ /CPU implementer/s) {
    die $cputype if($cputype ne 'arm');
    if(($cpuinfo =~ /^Features.+crc32/ms) && ($cpuinfo =~ /^Features.+atomics/ms)) {
      $cflags .= ' -march=armv8-a+crc';
    } elsif(($cpuinfo =~ /^Features.+vfpv4/ms) && ($cpuinfo =~ /^Features.+neon/ms)) {
      $cflags .= ' -mfpu=neon-vfpv4 -mfloat-abi=hard';
    } elsif($cpuinfo =~ /^Features.+vfpv4/ms) {
      $cflags .= ' -mfpu=vfpv4 -mfloat-abi=hard';
    } elsif($cpuinfo =~ /^Features.+vfpv3/ms) {
      $cflags .= ' -mfpu=vfpv3 -mfloat-abi=hard';
    }
    if($info->{'architecture'} eq 'armv7l') {
      $cflags .= ' -mtune=cortex-a7';
    }
  } elsif($cpuinfo =~ /model name/s) {
    die $cputype if($cputype ne 'x86' && $cputype ne 'amd');
  } elsif($cputype eq 'ppc') {
    if($cpuinfo =~ /^cpu.+altivec supported/ms) {
      $cflags .= ' -mabi=altivec';
    }
    if($cpuinfo =~ /^cpu.+7450/ms) {
      $cflags .= ' -mtune=7450';
    }
  } elsif($cputype eq 's390x') {
    # Don't add -m64, since it stops things being found in
    # /usr/include/sys.
    # $cflags .= ' -mzarch -m64';
    $cflags .= ' -mzarch';
  } else {
    die $cputype if($cputype ne 'x86' && $cputype ne 'amd');
  }
}

die "Can't determine CPU type - submit a bug report" if(!defined($cputype));
die "Can't determine GCC version - submit a bug report" if(!defined($gccversion));

my $v = version->parse($gccversion);
if($v >= version->parse('5.0')) {
  $cflags .= ' -fdiagnostics-color=auto';
}

if(($cputype eq 'amd') || ($cputype eq 'x86')) {
  $cflags .= ' -mtune=native -march=native';
}

# print "$cputype, $gccversion\n";
die "Can't determine best CFLAGS - submit a bug report" if(!defined($cflags));
print $cflags." ".$warnflags."\n";
