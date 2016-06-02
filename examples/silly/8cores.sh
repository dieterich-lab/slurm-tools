#!/bin/bash
#SBATCH -n 8
#SBATCH -J FOO
#SBATCH -p hugemem
#SBATCH -c 1
#SBATCH -d singleton
#SBATCH --nodelist=bioinf-node01
#SBATCH -N 1
sleep 3999 
