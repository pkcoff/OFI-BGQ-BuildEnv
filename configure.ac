
AC_PREREQ([2.63])
AC_INIT([FULL-PACKAGE-NAME], [VERSION], [BUG-REPORT-ADDRESS])
AC_CONFIG_MACRO_DIR([autoconf-archive/m4])
AM_INIT_AUTOMAKE([foreign subdir-objects])
AC_CONFIG_SRCDIR([ofi])
AC_CONFIG_FILES([ofi/simple_configure mpi/simple_configure])
dnl AM_CONFIG_HEADER(config.h)

AC_CONFIG_FILES([Makefile])

dnl : ${CFLAGS="-O3"}
dnl : ${CXXFLAGS="-O3"}

dnl Checks for programs.
dnl AC_PROG_CC
dnl AC_PROG_CXX


LIBFABRIC_SRCDIR=$ac_abs_confdir/ofi/libfabric
AC_ARG_WITH([libfabric],
	AC_HELP_STRING([--with-libfabric=PATH],
		[specify path to libfabric source directory; default=$LIBFABRIC_SRCDIR])],
	[LIBFABRIC_SRCDIR=$with_libfabric])
AC_SUBST(libfabric_srcdir, [$LIBFABRIC_SRCDIR])

MPICH_SRCDIR=$ac_abs_confdir/mpi/mpich
AC_ARG_WITH([mpich],
	AC_HELP_STRING([--with-mpich=PATH],
		[specify path to mpich source directory; default=$MPICH_SRCDIR])],
	[MPICH_SRCDIR=$with_mpich])
AC_SUBST(mpich_srcdir, [$MPICH_SRCDIR])

AC_SUBST(ac_abs_confdir, [$ac_abs_confdir])

AC_OUTPUT


