#!/bin/bash

#
# This script must be executed from within a configured mpich testsuite
# directory. For example:
#
#   ../mpich/test/mpi/configure				\
#      --srcdir=`cd ../mpich/test/mpi && pwd`		\
#      --with-mpi=`cd ../../install && pwd`		\
#      --disable-spawn
#
# The maximum job time, 120 minutes, is specified however if the testsuite
# script complete before the timeout the job will end and only the portion
# of time used is charged to the project.

cmd=$_

if [ "x$COBALT_PARTNAME" == "x" ]; then
	pwd=`pwd`
	jobid=`qsub -A aurora_app -t 120 -n 32 --mode script $pwd/$cmd $*`

	echo
	echo "Running MPICH testsuite"
	echo "  `date`"
	echo
	echo "Waiting for job $jobid to start..."
	while ! `qstat $jobid | grep running 2>&1 >/dev/null`; do (sleep 10); done
	while [ ! -f $jobid.xml ]; do (sleep 10); done
	echo "  `date`"
	echo
	echo "Monitoring testsuite summary file..."
	echo "  `pwd`/$jobid.xml"
	echo
	while `qstat $jobid 2>&1 >/dev/null`; do (sleep 10 && echo -en "\r`grep STATUS $jobid.xml | grep pass | wc -l` / `grep STATUS $jobid.xml | wc -l` \t"); done
	echo
	echo "MPICH testuite complete"
	echo "  `date`"
	echo

else

	timeout=300
	ppn=2
	#sharedmemsize=32MB
	sharedmemsize=64MB

	while [[ $# > 1 ]]; do
		key=$1
		case $key in
			--timeout)
			timeout="$2"
			shift;;

			--ppn)
			ppn="$2"
			shift;;

			--sharedmemsize)
			sharedmemsize="$2"
			shift;;

			*)
				# unknown option
			;;
		esac
		shift
	done

	make testing MPITEST_PROGRAM_WRAPPER=" --block $COBALT_PARTNAME --timeout $timeout --ranks-per-node $ppn --verbose ibm.runjob=0 --verbose 0 --envs BG_SHAREDMEMSIZE=$sharedmemsize : " MPIEXEC=runjob SUMMARY_BASENAME=$COBALT_JOBID
fi

