#!/bin/bash
PBS_SCRIPT=$HOME/masque_submission.sh

#Check arguments
if [ $# -ne 7  ]
then
    echo "Usage: $0 <amplicon_file> <output_dir> <contaminants> <project-name> <nb_cpu> <email> <queue>"
    echo "contaminants: danio,human,mouse,mosquito,phi (add contaminants separated by comma)"
    echo "nb_cpu: max is 12 on bic"
    echo "qos: name of your team"
    exit
fi

mkdir -p $2

amplicon=$(readlink -e "$1")
outdir=$(readlink -e "$2")

SCRIPTPATH=$(dirname "${BASH_SOURCE[0]}")

echo """#!/bin/bash
#$ -S /bin/bash
#$ -M $6
#$ -m bea
#$ -q $7
#$ -N "masque_$4"
#$ -pe thread $5
#$ -l mem_total=50G
source /local/gensoft2/adm/etc/profile.d/modules.sh
module purge
export PATH=/pasteur/projets/Matrix/metagenomics/python-lib/bin:$PATH
export PYTHONPATH=/pasteur/projets/Matrix/metagenomics/python-lib/lib/python2.7/site-packages:$PYTHONPATH
module add Python/2.7.8 FastTree/2.1.8 FLASH/1.2.11 fasta mafft/7.149 bowtie2/2.2.9 blast+/2.2.40 AlienTrimmer/0.4.0 fastqc/0.11.5 rdp_classifier/2.12 BMGE/1.12 openmpi/2.0.1 IQ-TREE/1.5.1

/bin/bash $SCRIPTPATH/masque.sh -a $amplicon -o $outdir/ -t $5 -n $4 -c $3  &> $outdir/${4}_stat_process.txt || exit 1

exit 0
""">$PBS_SCRIPT
PBSID=`qsub $PBS_SCRIPT`
echo "Submission PBS :> JOBID = $PBSID"
