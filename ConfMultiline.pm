package ConfMultiline;
use strict;

# my $conf = ConfMuliline->new('conf_file');
# my $sect = $conf->section('section_name');
# my $var_value = $sect->{var_name};

#### conf file ####
# [section_name_without_spaces]
# var = multiline
#       value
#    #  comment line
#       till the next
#       variable
# var2 = another value

# my $conf = ConfMultiline->new('conf_file');
sub new
{
  my $class = shift;
  my $self = bless {}, $class;
  $self->init(@_);
  $self
}

# $self->init('conf_file');
sub init
{
  my ($self, $fname) = @_;
  $self->{fname} = $fname;
  $self->{sections} = {};     #{section_name => {var_name => var_value}}
  $self->load_config;
}

sub section { $_[0]{sections}{$_[1]} }

# $conf->load_config
sub load_config
{
  my $self = shift;
  my $fname = $self->{fname};
  open(my $f, '<', $fname) || die "can`t open file '$fname': $!\n";
  my @errors;
  my @warnings;
  my $cur_sect  = 'global';
  my $cur_var = '';
  for(my $line = 1; <$f>; $line++){
    s/\r//;
    # remove comments
    s/^\s*#.*//;
    # section
    if    (/^\s*\[/){
      if  (/^\s*\[(\S+)\]\s*$/){ $cur_sect = lc $1 }
      else { push @errors, [$line, "wrong section expression"] }
    }
    # var
    elsif (/^\s*(\S+)\s*=(.*)/){
      $cur_var = lc $1;
      if (exists $self->{sections}{$cur_sect}{$cur_var}){ push @warnings, [$line, "variable '$cur_var' redefinition"] }
      $self->{sections}{$cur_sect}{$cur_var} = $2;
    }
    # value
    else{
      if (!$cur_var){ push @errors, [$line, "no variable to be assigned"] }
      else{ $self->{sections}{$cur_sect}{$cur_var} .= $_ }
    }
  }
  close $f;
  ## print errors ##
  print map "$fname:$_->[0]: warning: $_->[1].\n", @warnings;
  print map "$fname:$_->[0]: error: $_->[1].\n", @errors;
  die "\n" if @errors;
}

1;
