#! /bin/bash
#SBATCH -N2
#SBATCH -o otherout-%j.otherout
#SBATCH -e error-%j
env | sort
#sleep 99
