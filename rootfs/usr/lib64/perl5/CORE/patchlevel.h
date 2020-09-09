/*    patchlevel.h
 *
 *    Copyright (C) 1993, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002,
 *    2003, 2004, 2005, 2006, 2007, 2008, 2009, by Larry Wall and others
 *
 *    You may distribute under the terms of either the GNU General Public
 *    License or the Artistic License, as specified in the README file.
 *
 */

#ifndef __PATCHLEVEL_H_INCLUDED__

/* do not adjust the whitespace! Configure expects the numbers to be
 * exactly on the third column */

#define PERL_REVISION	5		/* age */
#define PERL_VERSION	16		/* epoch */
#define PERL_SUBVERSION	3		/* generation */

/* The following numbers describe the earliest compatible version of
   Perl ("compatibility" here being defined as sufficient binary/API
   compatibility to run XS code built with the older version).
   Normally this should not change across maintenance releases.

   Note that this only refers to an out-of-the-box build.  Many non-default
   options such as usemultiplicity tend to break binary compatibility
   more often.

   This is used by Configure et al to figure out
   PERL_INC_VERSION_LIST, which lists version libraries
   to include in @INC.  See INSTALL for how this works.

   Porting/bump-perl-version will automatically set these to the version of perl
   to be released for blead releases, and to 5.X.0 for maint releases. Manually
   changing them should not be necessary.
*/
#define PERL_API_REVISION	5
#define PERL_API_VERSION	16
#define PERL_API_SUBVERSION	0
/*
   XXX Note:  The selection of non-default Configure options, such
   as -Duselonglong may invalidate these settings.  Currently, Configure
   does not adequately test for this.   A.D.  Jan 13, 2000
*/

#define __PATCHLEVEL_H_INCLUDED__
#endif

/*
	local_patches -- list of locally applied less-than-subversion patches.
	If you're distributing such a patch, please give it a name and a
	one-line description, placed just before the last NULL in the array
	below.  If your patch fixes a bug in the perlbug database, please
	mention the bugid.  If your patch *IS* dependent on a prior patch,
	please place your applied patch line after its dependencies. This
	will help tracking of patch dependencies.

	Please either use 'diff --unified=0' if your diff supports
	that or edit the hunk of the diff output which adds your patch
	to this list, to remove context lines which would give patch
	problems. For instance, if the original context diff is

	   *** patchlevel.h.orig	<date here>
	   --- patchlevel.h	<date here>
	   *** 38,43 ***
	   --- 38,44 ---
	     	,"FOO1235 - some patch"
	     	,"BAR3141 - another patch"
	     	,"BAZ2718 - and another patch"
	   + 	,"MINE001 - my new patch"
	     	,NULL
	     };

	please change it to
	   *** patchlevel.h.orig	<date here>
	   --- patchlevel.h	<date here>
	   *** 41,43 ***
	   --- 41,44 ---
	   + 	,"MINE001 - my new patch"
	     	,NULL
	     };

	(Note changes to line numbers as well as removal of context lines.)
	This will prevent patch from choking if someone has previously
	applied different patches than you.

        History has shown that nobody distributes patches that also
        modify patchlevel.h. Do it yourself. The following perl
        program can be used to add a comment to patchlevel.h:

#!perl
die "Usage: perl -x patchlevel.h comment ..." unless @ARGV;
open PLIN, "patchlevel.h" or die "Couldn't open patchlevel.h : $!";
open PLOUT, ">patchlevel.new" or die "Couldn't write on patchlevel.new : $!";
my $seen=0;
while (<PLIN>) {
    if (/\t,NULL/ and $seen) {
       while (my $c = shift @ARGV){
	    $c =~ s|\\|\\\\|g;
	    $c =~ s|"|\\"|g;
            print PLOUT qq{\t,"$c"\n};
       }
    }
    $seen++ if /local_patches\[\]/;
    print PLOUT;
}
close PLOUT or die "Couldn't close filehandle writing to patchlevel.new : $!";
close PLIN or die "Couldn't close filehandle reading from patchlevel.h : $!";
close DATA; # needed to allow unlink to work win32.
unlink "patchlevel.bak" or warn "Couldn't unlink patchlevel.bak : $!"
  if -e "patchlevel.bak";
rename "patchlevel.h", "patchlevel.bak" or
  die "Couldn't rename patchlevel.h to patchlevel.bak : $!";
rename "patchlevel.new", "patchlevel.h" or
  die "Couldn't rename patchlevel.new to patchlevel.h : $!";
__END__

Please keep empty lines below so that context diffs of this file do
not ever collect the lines belonging to local_patches() into the same
hunk.

 */

#if !defined(PERL_PATCHLEVEL_H_IMPLICIT) && !defined(LOCAL_PATCH_COUNT)
#  if defined(PERL_IS_MINIPERL)
#    define PERL_PATCHNUM "UNKNOWN-miniperl"
#    define PERL_GIT_UNPUSHED_COMMITS /*leave-this-comment*/
#  elif defined(PERL_MICRO)
#    define PERL_PATCHNUM "UNKNOWN-microperl"
#    define PERL_GIT_UNPUSHED_COMMITS /*leave-this-comment*/
#  else
#include "git_version.h"
#  endif
static const char * const local_patches[] = {
	NULL
#ifdef PERL_GIT_UNCOMMITTED_CHANGES
	,"uncommitted-changes"
#endif
	PERL_GIT_UNPUSHED_COMMITS    	/* do not remove this line */
	,"Fedora Patch1: Removes date check, Fedora/RHEL specific"
	,"Fedora Patch3: support for libdir64"
	,"Fedora Patch4: use libresolv instead of libbind"
	,"Fedora Patch5: USE_MM_LD_RUN_PATH"
	,"Fedora Patch6: Skip hostname tests, due to builders not being network capable"
	,"Fedora Patch7: Dont run one io test due to random builder failures"
	,"Fedora Patch9: Fix find2perl to translate ? glob properly (RT#113054)"
	,"Fedora Patch10: Fix broken atof (RT#109318)"
	,"Fedora Patch13: Clear $@ before \"do\" I/O error (RT#113730)"
	,"Fedora Patch14: Do not truncate syscall() return value to 32 bits (RT#113980)"
	,"Fedora Patch15: Override the Pod::Simple::parse_file (CPANRT#77530)"
	,"Fedora Patch16: Do not leak with attribute on my variable (RT#114764)"
	,"Fedora Patch17: Allow operator after numeric keyword argument (RT#105924)"
	,"Fedora Patch18: Extend stack in File::Glob::glob, (RT#114984)"
	,"Fedora Patch19: Do not crash when vivifying $|"
	,"Fedora Patch20: Fix misparsing of maketext strings (CVE-2012-6329)"
	,"Fedora Patch21: Add NAME headings to CPAN modules (CPANRT#73396)"
	,"Fedora Patch22: Fix leaking tied hashes (RT#107000) [1]"
	,"Fedora Patch23: Fix leaking tied hashes (RT#107000) [2]"
	,"Fedora Patch24: Fix leaking tied hashes (RT#107000) [3]"
	,"Fedora Patch25: Fix dead lock in PerlIO after fork from thread (RT#106212)"
	,"Fedora Patch26: Make regexp safe in a signal handler (RT#114878)"
	,"Fedora Patch27: Update h2ph(1) documentation (RT#117647)"
	,"Fedora Patch28: Update pod2html(1) documentation (RT#117623)"
	,"Fedora Patch29: Document Math::BigInt::CalcEmu requires Math::BigInt (CPAN RT#85015)"
	,"RHEL Patch30: Use stronger algorithm needed for FIPS in t/op/crypt.t (RT#121591)"
	,"RHEL Patch31: Make *DBM_File desctructors thread-safe (RT#61912)"
	,"RHEL Patch32: Use stronger algorithm needed for FIPS in t/op/taint.t (RT#123338)"
	,"RHEL Patch33: Remove CPU-speed-sensitive test in Benchmark test"
	,"RHEL Patch34: Make File::Glob work with threads again"
	,"RHEL Patch35: Fix CRLF conversion in ASCII FTP upload (CPAN RT#41642)"
	,"RHEL Patch36: Do not leak the temp utf8 copy of namepv (CPAN RT#123786)"
	,"RHEL Patch37: Fix duplicating PerlIO::encoding when spawning threads (RT#31923)"
	,"RHEL Patch38: Add SSL support to Net::SMTP (CPAN RT#93823) [1]"
	,"RHEL Patch39: Add SSL support to Net::SMTP (CPAN RT#93823) [2]"
	,"RHEL Patch40: Add SSL support to Net::SMTP (CPAN RT#93823) [3]"
	,"RHEL Patch41: Add SSL support to Net::SMTP (CPAN RT#93823) [4]"
	,"RHEL Patch42: Do not overload \"..\" in Math::BigInt (CPAN RT#80182)"
	,"RHEL Patch43: Fix CVE-2018-18311 Integer overflow leading to buffer overflow"
	,"RHEL Patch44: Fix a spurious timeout in Net::FTP::close (CPAN RT#18504)"
	,NULL
};



/* Initial space prevents this variable from being inserted in config.sh  */
#  define	LOCAL_PATCH_COUNT	\
	((int)(sizeof(local_patches)/sizeof(local_patches[0])-2))

/* the old terms of reference, add them only when explicitly included */
#define PATCHLEVEL		PERL_VERSION
#undef  SUBVERSION		/* OS/390 has a SUBVERSION in a system header */
#define SUBVERSION		PERL_SUBVERSION
#endif
