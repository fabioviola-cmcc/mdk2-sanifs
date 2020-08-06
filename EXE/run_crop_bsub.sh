#!/bin/bash

source ./mdk2.conf
source ${MEDSLIK_EXE}/set_env.sh
JJ=$1

# Invoke medslik
MSCommand=./RUN_crop.sh
bsub -R "span[ptile=1] rusage[mem=50GB]" -Is -q s_medium -P 0372 -J ${JJ} $MEDSLIK_EXE/$MSCommand 
