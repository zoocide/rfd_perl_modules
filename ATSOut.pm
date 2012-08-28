package ATSOut;
use strict;
use base qw(Exporter);

# ATSOut->new(@ats_output)
sub new
{
  my ($class, @ats_output) = @_;
  tr/\r//d for @ats_output;
  my ($cur, $etalon, $dry_run, $tests) = _parse_output(@ats_output);
  my $self = {
    current => $cur,
    etalon  => $etalon,
    tests   => $tests,
    dry_run => $dry_run,
  };
  bless $self, $class;
}

sub current { $_[0]{current}  }
sub etalon  { $_[0]{etalon}   }
sub dry_run { $_[0]{dry_run}  }
sub tests   { @{$_[0]{tests}} }

# my ($current, $etalon, $tests) = _parse_output(@ats_output); # $tests = \@tests
sub _parse_output
{
  my ($cur, $etalon, @tests);
  my $dry_run = 0;
  for(; @_; shift @_){
    $_ = $_[0];
    next if /^\s*$/; #< skip spaces
    
    # set current
    if    (/^Current:\s*(\d+)/){ $cur = $1; }
    # set etalon
    elsif (/^Etalon:\s*(\S+)/ ){ $etalon = int $1; }
    # parse tests
    elsif (/^(Run):/ || /^(Check):/){
      my $class = 'ATS::Test::'.$1;
      my $test = $class->new(\@_);
      if (!$test){
        print "WARNING: can`t create test $class\n";
        next;
      }
      push @tests, $test;
    }
    # dry-run
    elsif (/^Dry run: True/){ $dry_run = 1; }
    # skip
    elsif (/^Options: {/
         ||/^Applied '/
         ||/^Previous options restored: {/){}
    # unknown string
    else { print "skipped: $_[0]\n"; }
  }
  ($cur, $etalon, $dry_run, \@tests);
}



package ATS::Test;
use strict;
use base qw(Exporter);
use File::Spec;

# ATS::Test->new(\@out) # it removes processed lines from the array
sub new
{
  my ($class, $lines) = @_;
  return undef if $#$lines < 0;
  my ($title, $status) = parse_header(${$lines}[0]);
  return undef unless $title;
  my $self = {
    title  => $title,
    status => $status,
    name   => '',
  };
  bless $self, $class;
  $self->parse_info($lines);
  $self;
}

sub title { $_[0]{title} }
sub is_ok { $_[0]{status} eq 'ok' }
sub status{ $_[0]{status} }
sub state_dir { $_[0]{state_dir}  }
sub log_path  { File::Spec->catfile($_[0]{state_dir}, 'run.log') }
sub set_name { $_[0]{name} = $_[1] }
sub name { $_[0]{name} }

# my ($title, $status) = parse_header($line);
sub parse_header
{
  ($_[0] =~ /^(\w+):\s+(.+?)\s*\[(.+?)\]\s*$/) ||
  print "WARNING: can`t parse header: $_[0]\n";
  my ($title, $status) = ("$1: $2", $3);
  $status =~ tr/ //d if $status;
  ($title, lc $status);
}

# parse_info(\@lines) # it removes processed lines from the array
sub parse_info
{
  my ($self, $lines) = @_;
  for (; $#$lines > 0; shift @$lines){
    last if !$self->parse_info_recognize($lines);
  }
}

# $is_consumed = $self->parse_info_recognize(\@lines)
sub parse_info_recognize
{
  my ($self, $lines) = @_;
  $_ = ${$lines}[1];
  if    (/^Dry run command:/ && $#$lines > 1){
    shift @$lines;
    $self->{cmd} = ${$lines}[1];
  }
  elsif (/^Test state dir:\s+(.+)/){ $self->{state_dir} = $self->_str_to_path($1); }
  else { return 0 }
  1;
}

# $path = $self->_str_to_path($str);
sub _str_to_path{ File::Spec->catdir(split /[\\\/]/, $_[1]) }



package ATS::Test::Run;
use strict;
use base qw(ATS::Test);
use File::Spec;

sub model_path{ $_[0]{model_path} }
sub log_path  { $_[0]{log_path}   }
sub no_base   { $_[0]{no_base}    }

# $test->parse_info_recognize(\@lines)
sub parse_info_recognize
{
  my ($self, $lines) = @_;
  return 1 if $self->SUPER::parse_info_recognize($lines);
  $_ = ${$lines}[1];
  if    (/^Path to model:\s+(.+)/){ $self->{model_path} = $self->_str_to_path($1); }
  elsif (/^Path to log:\s+(.+)/  ){ $self->{log_path}   = $self->_str_to_path($1); }
  elsif (/^Result file of base model is not found/){ $self->{no_base} = 1; }
  else { return 0 }
  1;
}



package ATS::Test::Check;
use strict;
use base qw(ATS::Test);

sub results_path { $_[0]{results_path} }

# $test->parse_info_recognize(\@lines)
sub parse_info_recognize
{
  my ($self, $lines) = @_;
  return 1 if $self->SUPER::parse_info_recognize($lines);
  $_ = ${$lines}[1];
  if    (/^Path to result (\d):\s+(.+)/){ $self->{results_path}{$1} = $self->_str_to_path($2); }
  else { return 0; }
  1;
}

1;
