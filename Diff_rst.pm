package Diff_rst;
use strict;
use base qw(Exporter);

our @EXPORT = qw(is_diff_output_file);

# $is_diff = Diff_rst::is_diff_output_file('file_name');
sub is_diff_output_file
{
  my $fname = shift;
  my $ret = 0;
  open(my $f, '<', $fname) || die "can`t open file '$fname': $!\n";
  while (<$f>){
    chomp;
    if( !/^model\d: /i   &&
        !/^-----/        &&
        !/^\s*$/         &&
        !/^\s*FOR\s*NX/i &&
        !/^info:/i       &&
        !/^warning:\s*data_ctrl:/i
      ){
      $ret = 1;
      last;
    }
  }
  close $f;
  $ret;
}

1;
