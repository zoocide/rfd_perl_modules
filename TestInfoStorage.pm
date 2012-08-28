package TestInfoStorage;
use strict;
use Storable;
use File::Spec;
use File::Basename  qw(basename);
use TestsSet;

# $storage = TestInfoStorage->new('file_name');
sub new
{
  my ($class, $fname) = @_;
  my $self = -e $fname ?
    retrieve($fname)
  :
    {
      fname   => $fname, # storage filename
      t2n     => {},     # title => name
      infos   => {},     # name => test_info
    };
  $self->{fname} = $fname;
  bless $self, $class;
}

# clear the storage
# $storage->clear;
sub clear
{
  $_[0]{t2n} = {};
  $_[0]{infos} = {};
}

# $storage->save;
sub save
{
  my $self = shift;
  store $self, $self->{fname};
}

# $storage->init_storage('path_to_conf_dir');
sub init_storage
{
  my ($self, $dir) = @_;
  opendir(my $dh, $dir) || die "can`t open directory '$dir': $!\n";
  my @files = map {/.conf$/ ? File::Spec->catfile($dir,$_) : ()} readdir($dh);
  $self->clear();
  for my $fn(@files){
    if (open my $f, '<', $fn){
      my $name = basename($fn, '.conf');
      my $title;
      my $model;          #model path related to tests_dir
      my $run_model_test; #run model to perform check on it
      my $base_model;     #base model for restart models
      while(<$f>){
        chomp; tr/\r//d;
        if    (/^title\s*=\s*(.+?)\s*$/){ $title = $1; }
        elsif (/^model\s*=\s*(.+?)\s*$/){ $model = $1; }
        elsif (/^run_model_test\s*=\s*(.+?)\s*$/){ $run_model_test = $1; }
        elsif (/^restart_model_test\s*=\s*(.+?)\s*$/){ $base_model = $1; }
      }
      close $f;
      if ($title){
        $self->{t2n}{$title} = $name;
        $self->{infos}{$name} = TestInfo->new($name,$title,$model,$base_model,$run_model_test);
      }
    }
  }
  closedir $dh;
  1;
}

# $storage->title2name('title');
sub title2name{ $_[0]{t2n}{$_[1]} }

sub hash_t2n { $_[0]{t2n} }
sub all_infos{ values %{$_[0]{infos}} }

# $test_info = $storage->test_with_title('title');
sub test_with_title{ $_[0]{infos}{$_[0]{t2n}{$_[1]}} }
# $test_info = $storage->test_with_name('name');
sub test_with_name{ $_[0]{infos}{$_[1]} }

# @names = $storage->include_base_models(@names)
sub include_base_models
{
  my $self = shift;
  my @ret;
  for (map {my $r = $self->{infos}{$_}->run_model_test; $r ? ($r,$_) : $_ } @_){
    push @ret, grep { my $n=$_; !grep{$n eq $_} @ret } ($self->base_models_chain($_), $_);
  }
  @ret;
}

# @base_models = $storage->base_models_chain($name)
sub base_models_chain
{
  my $b = $_[0]{infos}{$_[1]}->base_model;
  $b ? ($_[0]->base_models_chain($b), $b) : ()
}

# @names = $storage->extend_test_set(@names)
sub extend_test_set
{
  my $self = shift;
  my @run = grep {!/^check/} $self->include_base_models(@_);
  my @check = map {
    my $r = $_->run_model_test;
    ($r && grep {$r eq $_} @run) ? $_->name : ()
  } values %{$self->{infos}};
  (@run, @check)
}

# @titles = $storage->remove_unknown_titles(@titles) # remove unknown titles
sub remove_unknown_titles
{
  my $self = shift;
  my @unknown_titles = grep !exists $self->{t2n}{$_}, @_;
  return @_ if !@unknown_titles;
  print "unknown tests (try to reinitialize storage):\n", map "  '$_'\n", @unknown_titles;
  grep exists $self->{t2n}{$_}, @_;
}

# $storage->check_tests_set($tests_set)
sub check_tests_set
{
  my ($self, $ts) = @_;
  my @unknown_tests = grep !exists $self->{infos}{$_}, $ts->all;
  if (@unknown_tests){
    print "ERROR: unknown tests:\n", map "  $_\n", @unknown_tests;
    die "Edit tests set and try again\n";
  }
}



package TestInfo;
use File::Spec::Functions qw(splitpath catfile);
use File::Basename qw(basename fileparse);

sub new
{
  my ($class, $name, $title, $model, $base_model, $run_model_test) = @_;
  my $self = {
    name => $name,
    title => $title,
    model => $model,
    run_model_test => $run_model_test,
    base_model     => $base_model,
  };
  bless $self, $class;
}

sub name           { $_[0]{name}  }
sub title          { $_[0]{title} }
sub model          { $_[0]{model} }
# for check-test
sub run_model_test { $_[0]{run_model_test} }
# the base of the restart model
sub base_model     { $_[0]{base_model}     }
# name of the base of the restart model
sub base_model_name{ $_[0]{base_model}     }
# 'model_file.rst'
sub rst_fname      { (fileparse($_[0]{model}, qr/\..+/i))[0].'.rst' }
# 'model_file.data'
sub data_fname     { basename($_[0]{model}) }
# 'model_dir_relative_to_resources_dir'
sub model_dir      { (splitpath($_[0]{model}))[1] }
# 'RESULTS/model_file.rst'
sub rst_result     { catfile('RESULTS', $_[0]->rst_fname) }

sub is_run  { $_[0]{name} =~ /^run-/ }
sub is_check{ $_[0]{name} =~ /^check-/ }

1;
