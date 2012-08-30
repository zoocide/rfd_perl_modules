package ConfGroups;
use strict;
use base qw(ConfMultiline);

# my $grs = ConfGroups->new('conf_file');
# my @items = $grs->group('group_name');

# my @items = $grs->group('group_name');
sub exists_group { exists $_[0]{sections}{groups}{$_[1]} }
sub group        { @{$_[0]{sections}{groups}{$_[1]}} }

# $self->init('conf_file');
sub init
{
  my $self = shift;
  $self->SUPER::init(@_);
  exists $self->{sections}{groups} || die "can`t find [groups] section in config file '$_[1]'\n";
  $self->m_split_groups_items;
  my $sect = $self->{sections}{groups};
  $sect->{$_} = [m_expand_group($_, $sect)] for keys %$sect;
}

# my @items = m_expand_group($gr_name, $section_hash);
sub m_expand_group
{
  my ($gname, $sect) = @_;
  my @items;
  # not group
  if (!exists $sect->{$gname}){
    push @items, $gname;
  }
  # group
  else{
    push @items, m_expand_group($_, $sect) for @{$sect->{$gname}};
  }
  @items
}

sub m_split_groups_items
{
  my $self = shift;
  my $sect = $self->{sections}{groups};
  foreach my $gr (keys %$sect){
    $sect->{$gr} = [grep $_, split /\s+/m, $sect->{$gr}];
  }
}

1;
