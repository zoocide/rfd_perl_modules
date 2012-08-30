package TestsSet;
use strict;
use ConfGroups;

# my $ts = TestsSet->new(@tests);
sub new
{
  my $class = shift;
  my $self = bless {
    tests => [@_],
  }, $class;
}

# my $ts = TestsSet->load('filename');
sub load
{
  my ($class, $fname) = @_;
  open(my $f, '<', $fname) || die "can`t open file '$fname': $!\n";
  my @tests = map {s/^\s*//; s/\s*$//; (/^#/ || !$_) ? () : $_} <$f>;
  close $f;
  $class->new(@tests);
}

# @tests = $ts->all;
sub all { @{$_[0]{tests}} }

#1: $ts_1->substract($ts_2); # ts_1 -= ts_2
#2: my $ts_res = TestsSet->substract($ts_1, $ts_2); # ts_res = ts_1 - ts_2
sub substract
{
  my $self = shift;
  #1: $ts_1->substract($ts_2); # ts_1 -= ts_2
  if (ref $self){
    @{$self->{tests}} = grep {my $name = $_; !grep $name eq $_, @{$_[0]{tests}}} @{$self->{tests}};
  }
  #2: my $ts_res = TestsSet->substract($ts_1, $ts_2); # ts_res = ts_1 - ts_2
  else{
    $self = TestsSet->new(grep {my $name = $_; !grep $name eq $_, @{$_[1]{tests}}} @{$_[0]{tests}});
  }
  $self;
}

#1: $ts_1->join($ts_2); # ts_1 U= ts_2
#2: my $ts_res = TestsSet->join($ts_1, $ts_2); # ts_res = ts_1 U ts_2
sub join
{
  my $self = shift;
  my @appeared;
  #1: $ts_1->join($ts_2);
  if (ref $self){
    @{$self->{tests}} = grep {my $name = $_; (!grep $name eq $_, @appeared) ? push @appeared, $name : 0}
                             (@{$self->{tests}}, @{$_[0]{tests}});
  }
  #2: my $ts_res = TestsSet->join($ts_1, $ts_2);
  else{
    $self = TestsSet->new(grep {my $name = $_; (!grep $name eq $_, @appeared) ? push @appeared, $name : 0}
                               (@{$_[0]{tests}}, @{$_[1]{tests}}));
  }
  $self;
}

# $ts->expand_groups('conf_groups_file');
sub expand_groups
{
  my ($self, $fname) = @_;
  my $grs = ConfGroups->new($fname);
  @{$self->{tests}} = map { $grs->exists_group($_) ? $grs->group($_) : $_ } @{$self->{tests}};
}

1;
