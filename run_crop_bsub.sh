#!/bin/bash
wdir=/work/opa/witoil-dev/mdk2-sanifs/EXE
source ${wdir}/set_env.sh
JJ=$1

# Invoke medslik
MSHome=/work/opa/witoil-dev/mdk2-sanifs/EXE
MSCommand=./RUN_crop.sh
bsub -n 5 -R "span[ptile=1] rusage[mem=50GB]" -Is -q s_short -P 0372 -J ${JJ} $MSHome/$MSCommand 
