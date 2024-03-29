package Biotool::Getopt;

use 5.26.0;
use strict;
use File::Basename;
use Data::Dumper;
use List::Util qw(max);
use lib '..';
use Biotool::Logger;

my $DEBUG=0;

sub validate {
  my($self, $type, $value) = @_;
  my $valid = {
    'int'     => sub { @_[0] =~ m/^[-+]?\d+$/; },
    'bool'    => sub { @_[0] =~ m/^(0|1)$/; },
    'counter' => sub { @_[0] =~ m/^\d+$/; },
    'float'   => sub { @_[0] =~ m/^[+-]?\d+\.\d+$/; },
    'string'  => sub { @_[0] =~ m/\S/; },
    'char'    => sub { length(@_[0])==1; },
    'ifile'   => sub { -f @_[0] && -r _ },
    'idir'    => sub { -d @_[0] && -r _ },
    'file'    => sub { 1 },
    'dir'     => sub { 1 },
  };
  exists $valid->{$type} or err("Don't know how to validate type '$type'");
  my $ok = $valid->{$type}->($value);
  err("Paramater '$value' is not a valid $type type") unless $ok;
  return $ok; 
}

sub show_help {
  my($self, $d, $p, $pp, $err) = @_;
  select $err ? \*STDERR : \*STDOUT;
  printf "NAME\n  %s %s\n", $d->{name}, $d->{version};
  printf "SYNOPSIS\n  %s\n", $d->{desc};
  my $argv = $pp->{argv} ? ' '.$pp->{argv} : '';;
  printf "USAGE\n  %s [options]$argv\n", $d->{name};
  printf "OPTIONS\n";
  $$p{help} = { type=>'', desc=>'Show this help' };
  $$p{version} = { type=>'', desc=>'Print version and exit' };
  my @opt = sort keys %$p;
  my $width = max( map { length } @opt );
  for my $opt (@opt) {
    printf "  --%-${width}s  %-7s  %s%s\n",
      $opt,
      $$p{$opt}{type},
      $$p{$opt}{desc}||'',
      ($$p{$opt}{default} ? " [".$$p{$opt}{default}."]" : '');
  }
  printf "AUTHOR\n  %s\n", $d->{author} if $d->{author};
  printf "HOMEPAGE\n  %s\n", $d->{url} if $d->{url};
  exit($err ? $err : 0);
}

sub show_version {
  my($self, $d) = @_;
  printf "%s %s\n", $d->{name}, $d->{version};
  exit(0);
}

sub getopt {
  my($self, $d, $p, $pp) = @_;   ## pp = positional param
#  print Dumper($p);
  my $opt = {};
  my $switch = '';
  while (my $arg = shift @ARGV) {
    msg("Handling arg=[$arg]") if $DEBUG;
    if ($arg =~ m/^--(\w+)(=(\S+))?$/) {
      $switch = $1;
      unshift @ARGV, $3 if defined $3; # handle =value syntax on next loop
      $switch =~ m/^(h|help)$/ and show_help($self,$d,$p,$pp);
      $switch =~ m/^(V|version)$/ and show_version($self,$d);
      exists $p->{$switch} or err("Invalid option --$switch");
      my $s = $$p{$switch};
      msg("Switch=[$switch] has type", $$s{type}) if $DEBUG;;
      if ($$s{type} eq 'bool') { $$opt{$switch}=1; $switch=undef; }
      elsif ($$s{type} eq 'counter') { $$opt{$switch}++; $switch=undef; }
    }
    else {
      if ($switch) {
        msg("Value=[$arg] attaching to --$switch") if $DEBUG;
        $$opt{$switch} = $arg;
        $switch = '';
      }
      else {
        msg("Value=[$arg] adding to ARGV") if $DEBUG;
        push @{ $opt->{ARGV} }, $arg;
      }
    }
  }
  
  # check we have the correct amount of positional parameters
  my $argc = $opt->{ARGV} ? scalar(@{$opt->{ARGV}}) : 0;
  msg("You have $argc positional parameters") if $DEBUG;
  if (defined $pp->{argc_min} and $argc < $pp->{argc_min}) {
    err("Need at least",$pp->{argc_min},"positional parameters; you have $argc.");
  }
  if (defined $pp->{argc_max} and $argc > $pp->{argc_max}) {
    err("Can only handle",$pp->{argc_max},"positional parameters; you have $argc.");
  }
 
  # go back and fill in defaults
  for my $switch (keys %$p) {
    $opt->{$switch} //= $p->{$switch}{default};
    err("Option --$switch is mandatory") 
      if $p->{$switch}{need} and not defined $opt->{$switch};
    #say Dumper($p->{$switch});
    validate($self, $p->{$switch}{type}, $opt->{$switch})
      if defined $opt->{$switch};
  }
  
  return $opt;
}

sub main {
  my $opt = __PACKAGE__->getopt(
    {
      name => 'biotool',
      version => '0.0.1',
      desc => 'Helps do bio stuff easier and quicker',
    },
    {
      indir => { type=>'idir', default=>'/tmp' },
      dbdir => { type=>'idir' },
      infile => { type=>'ifile', need=>0, desc=>"File to read" },
      outdir => { type=>'dir', },
      outfile => { type=>'file', desc=>"File to write to"},
      myint => { type=>'int', default=>42, need=>1 },
      myfloat => { type=>'float', default=>'3.14' },
      mybool => { type=>'bool', default=>0 },
      myinc => { type=>'counter', default=>0 },
      mystring => { type=>'string', default=>'piece of string' },
      mychar => { type=>'char', default=>'N', desc=>"Single character" },
      check => { type=>'bool', default=>0, desc=>"Check dependencies and exit" },
    },
    {
      argv => 'contigs.fa ...',
      min_argc => 1,
      max_argc => 3,
    }
  );
  print Dumper($opt);
  return 0;
}

if (basename($0) eq 'Getopt.pm') {
  exit main();
}

1;
