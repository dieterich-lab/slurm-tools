#! /bin/bash

# in case of questions or bugs, please contact: o.schroeder@science-computing.de
#
#
# INPUTDATEN:

INPUTFILE=$1
PARALLEL=$2

if [ x${INPUTFILE} = x ] || [ ${INPUTFILE} = '-h' ]
then 
	echo "Usage: $0 <INPUTFILE> <DEGFREE OF PARALLELISM>"
	exit 0
fi

if [ x${PARALLEL} = x  ] || [ ${PARALLEL} -lt 1 ]
then
	echo "Default parallelism: 1"
	PARALLEL=1	
fi

#
# from the input file:
OUTPUTDIR=$(grep OUTPUT_DIR ${INPUTFILE} | perl -ne 's/#.*//; @components = split /\s*=\s*/; print $components[1]')
TOPHATCPUS=$(grep CPUS ${INPUTFILE} | perl -ne 's/#.*//; @components = split /\s*=\s*/; print $components[1]')
NUMOFSAMPLES=$(cat ${INPUTFILE} | perl -ne 'print if (/^\s*SAMPLE[\d]+{/);'  | wc -l)
SAMPLESIZE=$(grep INPUT_FILE ${INPUTFILE}  | awk -F= '{print $2}' | xargs ls -la | awk '{print $5}' | sort -n | tail -n ${PARALLEL} | perl -ne 'BEGIN{$sum=0} $sum+=$_; END{print $sum;}')

#
# derived quantities

COVERAGETASKS=$(echo "3.5*"${NUMOFSAMPLES} | bc | awk -F. '{print $1}')
MEMREQUEST=$(echo "1+10*"${SAMPLESIZE}"/(1024*1024)" | bc -l| awk -F. '{print $1}' )

#
# internal
JOBNAME=POPPI$(date +%s)
DEFAULTPARTITION=$(sinfo | perl -ne 'if (/^([\w]+)\*/) {print "$1\n"}' | uniq)
CPUS_ON_DEFAULT_PARTITION=$(sinfo -p ${DEFAULTPARTITION} -o "%c" -h)

#
# coverage should not use more slots than are available in the default partition ON ONE NODE

if [ ${CPUS_ON_DEFAULT_PARTITION} -lt ${COVERAGETASKS} ]
then
	COVERAGETASKS=${CPUS_ON_DEFAULT_PARTITION}
fi

#
#
POPPIDIR=/software/PoppiSourceforge/proteinoccupancyprofiling-code
POPPIBINDIR=/software/PoppiSourceforge/proteinoccupancyprofiling-code/bin
TOPHATDIR=/software/tophat-2.0.9.Linux_x86_64/
BOWTIEDIR=/software/bowtie2-2.1.0
SAMTOOLS=/software/samtools-0.1.19:/software/samtools-0.1.19/bcftools
PICARDDIR=/software/picard-tools-1.105
BEDTOOLS=/software/bedtools-2.17.0/bin


export PATH=${PATH}:${POPPIDIR}:${POPPIBINDIR}:${TOPHATDIR}:${BOWTIEDIR}:${SAMTOOLS}:${PICARDDIR}:${BEDTOOLS}

echo "OUTDIR: " $OUTPUTDIR
echo "TOPHAT CPUs: " ${TOPHATCPUS}
echo "NUMOFSAMPLES: " ${NUMOFSAMPLES}
echo "COVERAGETASKS: " ${COVERAGETASKS}

cd ${POPPIDIR}
poppi ${INPUTFILE}

cd ${OUTPUTDIR}

#----
cat<<STEP1 > step1.sh
#! /bin/bash
echo "STEP 1"
make -j ${PARALLEL} -C reads
#make -C reads
STEP1

#---
cat<<STEP2 > step2.sh
#! /bin/bash
echo "STEP 2"
make -C mapping
STEP2

#---
cat<<STEP3 > step3.sh
#! /bin/bash
echo "STEP 3"
make -j ${COVERAGETASKS} -C coverage
make -j ${COVERAGETASKS} -C TC_conversion
STEP3

#---

cat<<STEP4 > step4.sh
#! /bin/bash
echo "STEP 4"
make -C statistics
make -C plots
make -C html
STEP4

#---
cat<<STEP5 > step5.sh
#! /bin/bash
echo "STEP 5"
rm -Rf ${OUTPUTDIR}/tmp/*
STEP5

chmod u+x step*.sh

JOBID1=$(sbatch -J ${JOBNAME} -N1 --mem=${MEMREQUEST} -p himem,hugemem --parsable --mail-type=FAIL ./step1.sh  )
JOBID2=$(sbatch -J ${JOBNAME} -N1 -n ${TOPHATCPUS} --parsable --mail-type=FAIL -d afterok:${JOBID1} ./step2.sh )
JOBID3=$(sbatch -J ${JOBNAME} -N1 -n ${COVERAGETASKS} --parsable --mail-type=FAIL -d afterok:${JOBID2} ./step3.sh )
JOBID4=$(sbatch -J ${JOBNAME} -N1 --parsable --mail-type=FAIL -d afterok:${JOBID3} ./step4.sh )
JOBID5=$(sbatch -J ${JOBNAME} -N1 --parsable --mail-type=FAIL,END -d afterok:${JOBID4} ./step5.sh )


echo "JobIDs " ${JOBID1} ${JOBID2} ${JOBID3} ${JOBID4} ${JOBID5} 
echo "scancel -n ${JOBNAME} -t PENDING"
