package Settings;
use strict;
use File::Path qw(mkpath);
use File::Copy qw(copy);
use File::Spec::Functions qw(catfile catdir splitdir splitpath);


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
sub fstate_dir  { catfile($_[0]->states_dir, '20000101') }
sub tNav_bin    { catfile($_[0]->tNav_dir, 'build-con', 'build', 'tNavigator-con.exe') }
sub tNav_bin_dst{ catfile($_[0]->fstate_dir, 'build-tNavigator-con-release', 'tNavigator-con') }
sub diff_bin    { catfile($_[0]->tNav_dir, 'utils', 'diff_rst', 'build', 'diff_rst.exe') }
sub diff_bin_dst{ catfile($_[0]->fstate_dir, 'build-diff-rst-release', 'diff_rst.exe') }
sub resources_dir{ catfile($_[0]->tests_dir, 'resources') }
sub debug_dir   { 'debug' }
sub etalon      { $_[0]{etalon} }

# $db->copy_bins
sub copy_bins
{
  my $self = shift;
  -d $self->states_dir || die "states_dir '".$self->states_dir." not exists\n";
  mkdir $self->fstate_dir;
  m_copy($self->tNav_bin, $self->tNav_bin_dst);
  m_copy($self->diff_bin, $self->diff_bin_dst);
}

# $db->load_etalon
sub load_etalon
{
  my $self = shift;
  my $conf_fname = 'states.conf';
  $conf_fname = catfile($self->{states_dir}, $conf_fname);
  open(my $f, '<', $conf_fname) || die "can`t open file '$conf_fname': $!\n";
  while (<$f>){
    if (/etalon\s*=\s*(\w+)/){ $self->{etalon} = $1 }
  }
  close $f;
  $self->{etalon} || die "etalon is not set\n";
}

# m_copy($src, $dst)
sub m_copy
{
  my $dst_dir = (splitpath($_[1]))[1];
  -e $dst_dir || mkpath($dst_dir);
  #print "copy '$_[0]' to '$_[1]'\n";
  copy($_[0], $_[1]) || die "can`t copy '$_[0]' to '$_[1]': $!\n";
}

# $self->m_load_main_settings('file.conf');
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
