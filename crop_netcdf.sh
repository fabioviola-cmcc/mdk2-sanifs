#!/bin/bash

# read command line arguments
LATVAR=$1
LONVAR=$2
LATSPILL_DEG=$3
LATSPILL_MIN=$4
LONSPILL_DEG=$5
LONSPILL_MIN=$6
NCFILE=$7
CROPPED=$8
XPOINTS=$9
YPOINTS=$10

LATSPILL=$(echo $LATSPILL_DEG + $LATSPILL_MIN/60 | bc -l)
LONSPILL=$(echo $LONSPILL_DEG + $LONSPILL_MIN/60 | bc -l)
 
# get the whole set of latitude and longitude coordinates
LATITUDES=( $(h5dump -d $LATVAR $NCFILE  | grep -v -e "[a-zA-Z]" | tr -s " " | cut -d " " -f 3- | egrep "[[:digit:]]*\.*[[:digit:]]*" -o | sort -n) )
LONGITUDES=( $(h5dump -d $LONVAR $NCFILE | grep -v -e "[a-zA-Z]" | tr -s " " | cut -d " " -f 3- | egrep "[[:digit:]]*\.*[[:digit:]]*" -o | sort -n) )

# check the index for lat spill point
LATSPILLINDEX=0
LATFOUND=0
for LAT in ${LATITUDES[@]}; do

    # increment the counter
    ((LATSPILLINDEX=LATSPILLINDEX+1))

    # check if element is found
    if [[ $LATSPILL = ${LATITUDES[$LATSPILLINDEX]} ]] ; then
	LATFOUND=1
	break
    elif [[ $LATSPILL > ${LATITUDES[$LATSPILLINDEX]} && $LATSPILL < ${LATITUDES[$LATSPILLINDEX+1]} ]]; then

	# find the closest value
	DIFF1=$(echo $LATSPILL-${LATITUDES[$LATSPILLINDEX]} | bc -l)
	DIFF2=$(echo ${LATITUDES[$LATSPILLINDEX+1]}-$LATSPILL | bc -l)

	if [[ $DIFF1 > $DIFF2 ]]; then
	   ((LATSPILLINDEX=LATSPILLINDEX+1))
	fi
	
	LATFOUND=1
	break	
    fi
done

# check the index for lon spill point
LONSPILLINDEX=0
LONFOUND=0
for LON in ${LONGITUDES[@]}; do

    # increment the counter
    ((LONSPILLINDEX=LONSPILLINDEX+1))

    # check if element is found
    if [[ $LONSPILL = ${LONGITUDES[$LONSPILLINDEX]} ]] ; then
	LONFOUND=1
	break
    elif [[ $LONSPILL > ${LONGITUDES[$LONSPILLINDEX]} && $LONSPILL < ${LONGITUDES[$LONSPILLINDEX+1]} ]] ; then

	# find the closest value
	DIFF1=$(echo $LONSPILL-${LONGITUDES[$LONSPILLINDEX]} | bc -l)
	DIFF2=$(echo ${LONGITUDES[$LONSPILLINDEX+1]}-$LONSPILL | bc -l)

	if [[ $DIFF1 > $DIFF2 ]]; then
	    ((LONSPILLINDEX=LONSPILLINDEX+1))
	fi
	
	LONFOUND=1
	break
    fi

done

# extract the subset of latitudes and longitudes
if [ $((YPOINTS%2)) -eq 0 ]; then
    ((START_LAT_INDEX=LATSPILLINDEX - YPOINTS/2 + 1))
    ((END_LAT_INDEX=LATSPILLINDEX+YPOINTS/2))
else
    ((START_LAT_INDEX=LATSPILLINDEX - YPOINTS/2))
    ((END_LAT_INDEX=LATSPILLINDEX+YPOINTS/2))
fi

if [ $((XPOINTS%2)) -eq 0 ]; then
    ((START_LON_INDEX=LONSPILLINDEX - XPOINTS/2 + 1))
    ((END_LON_INDEX=LONSPILLINDEX+XPOINTS/2))
else
    ((START_LON_INDEX=LONSPILLINDEX - XPOINTS/2))
    ((END_LON_INDEX=LONSPILLINDEX+XPOINTS/2))
fi

# crop the list of latitude and longitude coordinates around the bb
echo "[crop_netcdf.sh] -- Cropping..."
ncks -d $LATVAR,$START_LAT_INDEX,$END_LAT_INDEX -d $LONVAR,$START_LON_INDEX,$END_LON_INDEX $NCFILE -o $CROPPED
