package OSType;

=head1 SYNOPSIS

  use OSType;
  if (OSType->is_win){ ... }
  if (OSType->is_unix_emulator){ ... }
  if (OSType->is_unix){ ... }

=cut

our %os_types = (
    'aix'       => 'AIX',
    'bsdos'     => 'BSD/OS',
    'dgux'      => 'dgux',
    'dynixptx'  => 'DYNIX/ptx',
    'freebsd'   => 'FreeBSD',
    'haiku'     => 'Haiku',
    'linux'     => 'Linux',
    'hpux'      => 'HP-UX',
    'irix'      => 'IRIX',
    'darwin'    => 'Mac OS X',
    'next'      => 'NeXT 3',
    'openbsd'   => 'openbsd',
    'dec_osf'   => 'OSF1',
    'svr4'      => 'reliantunix-n',
    'sco_sv'    => 'SCO_SV',
    'svr4'      => 'SINIX-N',
    'unicosmk'  => 'sn6521',
    'unicos'    => 'sn9617',
    'solaris'   => 'SunOS',
    'sunos'     => 'SunOS4',
    'MSWin32'   => 'windoze',
    'cygwin'    => 'windoze',
    'msys'      => 'windoze',
    'dos'       => 'windoze',
);

sub is_win  { exists $os_types{$^O} && $os_types{$^O} eq 'windoze' }
sub is_unix { !is_win() }
sub is_unix_emulator { $^O eq 'cygwin' || $^O eq 'msys' }

1;

__END__

unix:
    uname         $^O        $Config{'archname'}
    --------------------------------------------
    AIX           aix        aix
    BSD/OS        bsdos      i386-bsdos
    Darwin        darwin     darwin
    dgux          dgux       AViiON-dgux
    DYNIX/ptx     dynixptx   i386-dynixptx
    FreeBSD       freebsd    freebsd-i386    
    Haiku         haiku      BePC-haiku
    Linux         linux      arm-linux
    Linux         linux      i386-linux
    Linux         linux      i586-linux
    Linux         linux      ppc-linux
    HP-UX         hpux       PA-RISC1.1
    IRIX          irix       irix
    Mac OS X      darwin     darwin
    NeXT 3        next       next-fat
    NeXT 4        next       OPENSTEP-Mach
    openbsd       openbsd    i386-openbsd
    OSF1          dec_osf    alpha-dec_osf
    reliantunix-n svr4       RM400-svr4
    SCO_SV        sco_sv     i386-sco_sv
    SINIX-N       svr4       RM400-svr4
    sn4609        unicos     CRAY_C90-unicos
    sn6521        unicosmk   t3e-unicosmk
    sn9617        unicos     CRAY_J90-unicos
    SunOS         solaris    sun4-solaris
    SunOS         solaris    i86pc-solaris
    SunOS4        sunos      sun4-sunos


DOS:    
     OS            $^O      $Config{archname}   ID    Version
     --------------------------------------------------------
     MS-DOS        dos        ?                 
     PC-DOS        dos        ?                 
     OS/2          os2        ?
     Windows 3.1   ?          ?                 0      3 01
     Windows 95    MSWin32    MSWin32-x86       1      4 00
     Windows 98    MSWin32    MSWin32-x86       1      4 10
     Windows ME    MSWin32    MSWin32-x86       1      ?
     Windows NT    MSWin32    MSWin32-x86       2      4 xx
     Windows NT    MSWin32    MSWin32-ALPHA     2      4 xx
     Windows NT    MSWin32    MSWin32-ppc       2      4 xx
     Windows 2000  MSWin32    MSWin32-x86       2      5 00
     Windows XP    MSWin32    MSWin32-x86       2      5 01
     Windows 2003  MSWin32    MSWin32-x86       2      5 02
     Windows Vista MSWin32    MSWin32-x86       2      6 00
     Windows 7     MSWin32    MSWin32-x86       2      6 01
     Windows 7     MSWin32    MSWin32-x64       2      6 01
     Windows CE    MSWin32    ?                 3           
     Cygwin        cygwin     cygwin

