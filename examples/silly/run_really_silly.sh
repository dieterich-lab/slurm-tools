#! /bin/bash

#
# in case of questions or bugs, please contact: o.schroeder@science-computing.de

set -x


for i in in $(seq 4 8)
do
    JOBID[$i]=$(sbatch --parsable -J SILLY -n $i -H ./silly.sh)
done

while [ 1 ]
do
	for i in $(seq 4 8 | sort -n -r)
		do
			echo "considering $i slots"
			scontrol release ${JOBID[$i]}
			sleep 15
			if [ "R" = $(squeue --noheader -o "%t" --jobs ${JOBID[$i]}) ]
			then
				for j in $(seq 4 8 | sort -n -r)
				do
					if [ $j -ne $i ]
					then
						scancel ${JOBID[$j]}
					fi
				done
				exit 0
			fi
			scontrol hold ${JOBID[$i]}
		done
done


