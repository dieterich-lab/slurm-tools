#!/bin/bash
#SBATCH -n 4
#SBATCH -J FOO
#SBATCH -p hugemem
#SBATCH -c 1
#SBATCH -d singleton
#SBATCH --nodelist=bioinf-node01
sleep 3999 
