# MPICH CH4 over OFI Libfabric on Blue Gene /Q

This README contains instructions on how to download and build MPICH CH4 over OFI Libfabric on Blue Gene /Q.  Please note that the V1R2M4 driver is required.  See "BUILDING ON MIRA" below for specifics.

## Requirements

There are three github repositories with the relevant code.  The first of these is this github which is the build environment itself.

```
mkdir <build_env_root_dir>
cd  <build_env_root_dir>
git clone https://github.com/pkcoff/OFI-BGQ-BuildEnv.git
```

The old instructions had you cloning and building the libfabric git repo separately, however recently the
mpich embedded libfabric build has changed to treat libfabric as a submodule, so the libfabric gitrepo is
cloned for you within the mpich ofi netmode.  So now all you have to do is clone the pmodels mpich github
repo into this environment:

```
cd mpi
git clone https://github.com/pmodels/mpich.git
```

## Setup/Configure

Then run autoconf as follows:

```
cd <build_env_root_dir>/OFI-BGQ-BuildEnv
# add the --with-autotools in the Argonne machines due to downlevel autoconf default and put in your PATH
export PATH=/soft/buildtools/autotools/feb2015/bin:$PATH
./autogen.sh --with-autotools=/soft/buildtools/autotools/feb2015/bin
./configure
cd ofi/libfabric
./autogen.sh --with-autotools=/soft/buildtools/autotools/feb2015/bin
cd ../../mpi/mpich
./autogen.sh --with-autotools=/soft/buildtools/autotools/feb2015/bin
cd ..
vi simple_configure
# change : ${INSTALL_DIR:= to the install dir you want
```

### SPECIAL NOTE FOR BUILDING ON MIRA:
--------------------------------------------------------------------------------------------

If you are not compiling against V1R2M4 you might see an error like this:

    error: static declaration of 'Kernel_GetJobID' follows non-static declaration

Argonne's Mira machine, for example, is currently still at V1R2M2 and has not yet moved to V1R2M4.  As a workaround for now,
the V1R2M4 system files have been made available in `/soft/libraries/unsupported/V1R2M4-sys`.
To utilize them, you'll need to change the following 2 files:

 * config.site: change this:

    MPICHLIB_CPPFLAGS="-I/bgsys/drivers/ppcfloor/spi/include/kernel/cnk -I/bgsys/drivers/ppcfloor"

to this:

    MPICHLIB_CPPFLAGS="-I/soft/libraries/unsupported/V1R2M4-sys/spi/include/kernel/cnk -I/soft/libraries/unsupported/V1R2M4-sys"

* `ofi/libfabric/prov/bgq/configure.m4`: change this:

    bgq_driver=/bgsys/drivers/ppcfloor

to this:

    bgq_driver=/soft/libraries/unsupported/V1R2M4-sys
  
--------------------------------------------------------------------------------------------

The configure expects to find the source files for the bgq driver in `/bgsys/source` by default.
You need to make the source available somewhere that configure can access it because the spi
cnk source file `spi/src/kernel/cnk/memory_impl.c` is actually built and inlined to avoid the
necessity to link with libspi.a and to facilitate inlining.  If the source is in a different
location you can specify that by adding this parameter at the end of the simple_configure script:

    --with-bgq-src=<full path to source dir>

Both ofi manual and auto progress modes are implemented.  The default is manual which
means all progress is driven manually by mpich, auto progress spawns an ofi pthread that makes progress
without depending on mpich.  To build with auto progress change this in the simple_configure:

    --with-bgq-progress=manual

to this:

    --with-bgq-progress=auto

Additionally, the capatbiliy setting needs to be correctly toggled for manual/auto progress mode at compile time.
The default is manual, so to build in auto progress mode change this line in
mpi/mpich/src/mpid/ch4/netmod/ofi/ofi_capability_sets.h:

#define MPIDI_OFI_ENABLE_DATA_AUTO_PROGRESS_BGQ MPIDI_OFI_OFF

to this:

#define MPIDI_OFI_ENABLE_DATA_AUTO_PROGRESS_BGQ MPIDI_OFI_ON

and then change it back to again build in manual mode.

Both the basic and scalable mr modes are supported.  The default is now basic
as it allows for MPI_Put hardware accleration.  To build in scalable mode change this in the simple_configure:

    --with-bgq-mr=basic

to this:

    --with-bgq-mr=scalable

then for gnu 4.7.2 build:

```
cd <build_directory>
DEBUG build:
CONFIG_TOOLCHAIN=gnu4.7  CONFIG_FLAVOR=debug <build_env_root_dir>/ofi-bgq/mpi/simple_configure
OPT build:
CONFIG_TOOLCHAIN=gnu4.7  CONFIG_FLAVOR=optimized <build_env_root_dir>/ofi-bgq/mpi/simple_configure
```

## NOTE ON RECONFIGURING:

If you need to reconfigure for any reason (say you rebased to a new version of libfabric
and needed to autogen again) you must first completely delete everything in the build directory
otherwise you will run into build and runtime issues.

## Compiling

change to the `mpi/build` directory and then:

    make -j16 install

Look in <build_env_root_dir>/config.site for details on compilers and options.

## POTENTIAL GCC COMPILE FAILURE

NOTE: If you see a failure like this:

    <root dir>/OFI-BGQ-BuildEnv/mpi/mpich/src/mpid/ch4/netmod/ofi/libfabric/prov/bgq/src/fi_bgq_init.c:337:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token

It is happening because -I. is not the first include to the gcc compiler in your include path and an incorrect header file is being found and a macro is not being processed correctly.  This is probably due to a configuration setting in your shell and how gcc creates the include path.  If your shell is setting C_INCLUDE_PATH comment that out and it should resolve the issue.

## RUNTIME RESTRICTIONS:

Currently running on subblocks is NOT supported.  This is due to the additoinal complexity of the network
topology and calculating the correct physical destination in the address vector.  Depending on your job
manager this could be an issue unbeknownst to you.  If you experience a hang in the MPI_Init check the
job log for the actual runjob command that was executed, if you see a --corner / --shape parameter specified or
the RUNJOB_CORNER / RUNJOB_SHAPE environment variable set then you are running as a subblock.  One workaround is to
run in some sort of script mode where you can specify the runjob command directly, omitting the corner and shape.
The ofi auto-progress mode only works at 16 ppn and lower due to the need for the pthread and issues running at 32 ppn, furthermore performance is more likely detrimental vs manual at 32ppn.
If your app uses MPIX routines these are based on PAMI and will fail.  Contact Paul Coffman at pcoffman@anl.gov and you will be provided alternative code that uses the SPI layer directly instead.

