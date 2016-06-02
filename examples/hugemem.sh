#! /bin/bash
#SBATCH -n4
#SBATCH --tasks-per-node=2
#SBATCH -p hugemem
env | sort
sleep 99
