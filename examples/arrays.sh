#!/bin/bash

#SBATCH -a 1-10
#SBATCH -o slurm-%a.out
#SBATCH -e slurm-%a.err


INFO="#############################################
### Job array example - templer@age.mpg.de
### date $(date)
### hostname $(hostname)
### array ID ${SLURM_ARRAY_ID}
### task ID  ${SLURM_ARRAY_TASK_ID}
#############################################"

echo -e "$INFO" 1>&2

### Notes:
# If you use a heredoc*, escape SLURM (and other) variables (e.g. \${SLURM...})
# so that the variable is not resolved while forwarding the content!
# *) This is a heredoc (drop the leading ' #', copy to console and run):

# sbatch << EOF
# #!/bin/bash
# #SBATCH -a 1-10
# echo No escape: ${SLURM_ARRAY_TASK_ID}
# echo Escape:    \${SLURM_ARRAY_TASK_ID}
# EOF
