#! /bin/bash

#
# in case of questions or bugs, please contact: o.schroeder@science-computing.de

JOBNAME="SILLY"$(date +%s)
SLEEPTIME=3
MINTASKS=4
MAXTASKS=8
run_EXECUTABLE="./silly.sh"
#set -x



for i in $(seq ${MINTASKS} ${MAXTASKS})
do
    JOBID[$i]=$(sbatch --parsable -J ${JOBNAME} -n $i -H ${run_EXECUTABLE})
done

while [ 1 ]
do
	for i in $(seq ${MINTASKS} ${MAXTASKS} | sort -n -r)
		do
			echo "considering $i slots"
			scontrol release ${JOBID[$i]}
			sleep ${SLEEPTIME} 
			if [ "R" = $(squeue --noheader -o "%t" --jobs ${JOBID[$i]}) ]
			then
				scancel -n ${JOBNAME} -t "PENDING"
				exit 0
			fi
			scontrol hold ${JOBID[$i]}
		done
done


