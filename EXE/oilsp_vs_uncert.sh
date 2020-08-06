#!/bin/bash
time=`date`
echo "START TIME = $time"
userName=`whoami`
export NCARG_USRRESFILE=$MEDSLIK/.hluresfile
source witoil/selector.sh
if [ "$SELECTOR" == "witoil" ];then
  cd $MEDSLIK
  pwd
  echo "Starting model for simulation number $Id_Dir !!!"
  echo "srun -p medslik -J $Id_Dir ${MEDSLIK}/medslik_II.sh > algo.out 2>algo.err....."
  srun -p medslik -J $Id_Dir ${MEDSLIK}/medslik_II.sh > algo.out 2>algo.err
  srun_exit=$?
  if [ ${srun_exit} -ne 0 ];then
    echo "Process medslik_II.sh exit whit code ${srun_exit}"
    exit "${srun_exit}"
  fi
else
  count=1
  ncl -nQ ${MEDSLIK}/uncertainty.cross.hexagon.ncl | while read LINE; do
    if [ ! "$LINE" == "" ];then
      # numfiles=$(echo "(${sim_length}/24)+1" | bc)
      mkdir witoil${count}
      cp -rf witoil/* witoil${count}/
#      START_LAT=`echo $LINE | awk '{printf $2}'`
#      echo "export START_LAT=${START_LAT}" >> witoil${count}/env.sh
      LAT_DEGREE=`echo $LINE | awk '{printf $2}'`
      echo "export LAT_DEGREE=$LAT_DEGREE" >> witoil${count}/env.sh
      lineNum=`cat witoil${count}/medslik_inputfile.txt |grep -n "lat_degree=" | awk 'BEGIN {FS=":"} {print $1}'`
      sed -e "${lineNum}s/.*/lat_degree=${LAT_DEGREE}/" witoil${count}/medslik_inputfile.txt > witoil${count}/medslik_inputfile.txt.tmp
      LAT_MINUTES=`echo $LINE | awk '{printf $3}'`
      echo "export LAT_MINUTES=$LAT_MINUTES" >> witoil${count}/env.sh
      lineNum=`cat witoil${count}/medslik_inputfile.txt.tmp |grep -n "lat_minutes=" | awk 'BEGIN {FS=":"} {print $1}'`
      sed -e "${lineNum}s/.*/lat_minutes=${LAT_MINUTES}/" witoil${count}/medslik_inputfile.txt.tmp > witoil${count}/medslik_inputfile.txt
#      START_LON=`echo $LINE | awk '{printf $2}'`
#      echo "export START_LON=${START_LON}" >> witoil${count}/env.sh
      LON_DEGREE=`echo $LINE | awk '{printf $5}'`
      echo "export LON_DEGREE=$LON_DEGREE" >> witoil${count}/env.sh
      lineNum=`cat witoil${count}/medslik_inputfile.txt |grep -n "lon_degree=" | awk 'BEGIN {FS=":"} {print $1}'`
      sed -e "${lineNum}s/.*/lon_degree=${LON_DEGREE}/" witoil${count}/medslik_inputfile.txt > witoil${count}/medslik_inputfile.txt.tmp
      LON_MINUTES=`echo $LINE | awk '{printf $6}'`
      echo "export LON_MINUTES=$LON_MINUTES" >> witoil${count}/env.sh
      lineNum=`cat witoil${count}/medslik_inputfile.txt.tmp |grep -n "lon_minutes=" | awk 'BEGIN {FS=":"} {print $1}'`
      sed -e "${lineNum}s/.*/lon_minutes=${LON_MINUTES}/" witoil${count}/medslik_inputfile.txt.tmp > witoil${count}/medslik_inputfile.txt
      rm witoil${count}/medslik_inputfile.txt.tmp
      cd witoil${count}
      srun -p medslik -J ${Id_Dir} ./medslik_II.sh witoil${count} > algo.out 2>algo.err &
      cd ..
      count=$((${count}+1))
    fi
  done 
  cd witoil
  srun -p medslik -J $Id_Dir ${MEDSLIK}/medslik_II.sh witoil > algo.out 2>algo.err &
  cd ..
#  sleep 10
  count=0
 echo "IDDIR= $Id_Dir"
  while true; do
    jobActives=`squeue|grep "$Id_Dir" |wc -l` #`scontrol show job|grep Partition=afs |wc -l`
    echo "Active runs = $jobActives. Time in seconds = $count"
    if [ $jobActives -eq 0 ];then
       echo -e "At time: `date` all medslik simulation $Id_Dir finished"
       break
    else
         count=`expr ${count} + 5`
         sleep 5
    fi
    if [ $count -gt 3600 ];then
        echo -e "Something is going wrong with simulation. I'm stoping it! `date`"
        scancel -J $Id_Dir
        exit 2
    fi
  done
  POINTNUM=""
  min_lon="180"
  max_lon="-180"
  min_lat="90"
  max_lat="-90"
  ok_num=0
  for i in $( ls *.ok* 2> /dev/null ) ; do
    FileName=$(basename $i)
    if [ $FileName == "witoil.ok" ];then
       num=0
       min_lon_tmp=`cat witoil/medslik.tmp|awk '(NR == 2) {print $1}'`
       max_lon_tmp=`cat witoil/medslik.tmp|awk '(NR == 2) {print $2}'`
       min_lat_tmp=`cat witoil/medslik.tmp|awk '(NR == 3) {print $1}'`
       max_lat_tmp=`cat witoil/medslik.tmp|awk '(NR == 3) {print $2}'`
    else
      num=${FileName:6:1}
       min_lon_tmp=`cat witoil${num}/medslik.tmp|awk '(NR == 2) {print $1}'`
       max_lon_tmp=`cat witoil${num}/medslik.tmp|awk '(NR == 2) {print $2}'`
       min_lat_tmp=`cat witoil${num}/medslik.tmp|awk '(NR == 3) {print $1}'`
       max_lat_tmp=`cat witoil${num}/medslik.tmp|awk '(NR == 3) {print $2}'`
    fi
    min_lon=`echo "${min_lon}\n${min_lon_tmp}"`
    max_lon=`echo "${max_lon}\n${max_lon_tmp}"`
    min_lat=`echo "${min_lat}\n${min_lat_tmp}"`
    max_lat=`echo "${max_lat}\n${max_lat_tmp}"`
    POINTNUM="${POINTNUM}${num}"
    ok_num=`expr ${ok_num} + 1`
  done
  min_lon=$(echo -e "${min_lon}" | sort -g | head -n1)
  max_lon=$(echo -e "${max_lon}" | sort -g | tail -n1)
  min_lat=$(echo -e "${min_lat}" | sort -g | head -n1)
  max_lat=$(echo -e "${max_lat}" | sort -g | tail -n1)
#min_lon=$(echo "${min_lon}-3" | bc)
#max_lon=$(echo "${max_lon}+3" | bc)
#min_lat=$(echo "$min_lat{}-3" | bc)
#max_lat=$(echo "${max_lat}+3" | bc)
  echo "export min_lon=${min_lon}">>witoil/env.sh
  echo "export max_lon=${max_lon}">>witoil/env.sh
  echo "export min_lat=${min_lat}">>witoil/env.sh
  echo "export max_lat=${max_lat}">>witoil/env.sh
  export POINTNUM=${POINTNUM}
  echo "export POINTNUM=${POINTNUM}">>witoil/env.sh
  mkdir witoil/output/json/${Id_Dir}
  cd witoil/uncertainty_plots
  source ../env.sh
#  exit ${ok_num}
  # qui gestici il caso ok_num=0

##  if times(itime).eq.0 then
#    scorners = ""+res_base@mpMinLonF+" "+res_base@mpMinLatF+" "+res_base@mpMaxLonF+" "+res_base@mpMaxLatF
#  ;  asciiwrite(PLOT_DIR+"corners.txt",scorners)
#    print(scorners)
#    quota = tostring(tochar(34))
#    MinMaxjson =""+quota+"output"+quota+": [ { "+quota+"MinLon"+quota+": "+res_base@mpMinLonF+" , "+quota+"MinLat"+quota+": "+res_base@mpMinLatF+" , "+quota+"MaxLon"+quota+": "+res_base@mpMaxLonF+" , "+quota+"MaxLat"+quota+": "+res_base@mpMaxLatF+" } ]"
#    asciiwrite(PLOT_DIR+"scorners.json",MinMaxjson)
#  end if


#  srun -p medslik -J $Id_Dir ncl -nQ TASK=\"scenario1\" uncertainty.map.ncl
#  ncl -nQ TASK=\"scenario1\" uncertainty.map.ncl
  srun -p medslik -J $Id_Dir /users/home/tessa_gpfs1/opt/ncl-6.1.2/bin/ncl -nQ TASK=\"scenario1\" uncertainty.map.ncl # > algo.out 2>algo.err
fi
