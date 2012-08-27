package Settings;
use strict;
use File::Copy qw(copy);
use File::Spec::Functions qw(catfile catdir splitdir);


## SYNOPSIS
# my $conf = Settings->new;
# my $failed_filename = $conf->failed_file;
# ...

sub new
{
  my $class = shift;
  my $user_conf = catfile($ENV{HOME}, '.RFD', 'tests.conf');
  my $self = bless {}, $class;
  $self->m_load_main_settings($user_conf);
  $self;
}

sub tests_dir   { $_[0]->{tests_dir} }
sub states_dir  { $_[0]->{states_dir} }
sub db_file     { 'tests_info' }
sub failed_file { 'failed_ex.set' }
sub tNav_dir    { $_[0]{tNav_dir} }
sub fstate_dir  { catfile($_[0]->states_dir, '20110120') }
sub tNav_bin    { catfile($_[0]->tNav_dir, 'build-con', 'build', 'tNavigator-con.exe') }
sub tNav_bin_dst{ catfile($_[0]->fstate_dir, 'build-tNavigator-con-release', 'tNavigator-con') }
sub diff_bin    { catfile($_[0]->tNav_dir, 'utils', 'diff_rst', 'build', 'diff_rst.exe') }
sub diff_bin_dst{ catfile($_[0]->fstate_dir, 'build-diff-rst-release', 'diff_rst.exe') }

sub copy_bins
{
  my $self = shift;
  m_copy($self->tNav_bin, $self->tNav_bin_dst);
  m_copy($self->diff_bin, $self->diff_bin_dst);
}

# m_copy($src, $dst)
sub m_copy
{
  copy($_[0], $_[1]) || die "can`t copy '$_[0]' to '$_[1]': $!\n";
}

sub m_load_main_settings
{
  my ($self, $fconf) = @_;
  open(my $f, '<', $fconf) || die "can`t open file '$fconf': $!\n";
  my ($root_dir, $tnav_dir);
  while (<$f>){
    if    (/^tests_dir\s*=\s*(.+?)\s*$/ ){ $self->{tests_dir}  = catdir(split /[\\\/]/, $1); }
    elsif (/^states_dir\s*=\s*(.+?)\s*$/){ $self->{states_dir} = catdir(split /[\\\/]/, $1); }
    elsif (/^sources_root_dir\s*=\s*(.+?)\s*$/){ $root_dir = catdir(split /[\\\/]/, $1); }
    elsif (/^default_source_dir\s*=\s*(.+?)\s*$/){ $tnav_dir = catdir(split /[\\\/]/, $1); }
  }
  close $f;
  $tnav_dir = catdir($root_dir, $tnav_dir);
  -d $self->{tests_dir}  || die "error: tests_dir '" .$self->{tests_dir} ."' not found\n";
  -d $self->{states_dir} || die "error: states_dir '".$self->{states_dir}."' not found\n";
  -d $tnav_dir || die "error: tNavigator directory '".$tnav_dir."' not found\n";
  $self->{tNav_dir} = $tnav_dir;
}

1;
