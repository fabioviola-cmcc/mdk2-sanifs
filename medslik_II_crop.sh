#!/bin/sh
#-----------------------------------------------------------------------------------
#  MEDSLIK-II_1.01 
#  oil spill fate and transport model 
#-----------------------------------------------------------------------------------
#  medslik_II.sh
#  This script coordinates the model run
#-----------------------------------------------------------------------------------
#  Copyright (C) <2012>
#  This program was originally written
#  by Robin Lardner and George Zodiatis.
#  Subsequent additions and modifications
#  have been made by Michela De Dominicis. 
#----------------------------------------------------------------------------------
#  The development of the MEDSLIK-II model is supported by a formal agreement
#  Memorandum of Agreement for the Operation and Continued Development of MEDSLIK-II
#  signed by the following institutions:
#  INGV - Istituto Nazionale di Geofisica e Vulcanologia
#  OC-UCY - Oceanography Center at the University of Cyprus
#  CNR-IAMC - Consiglio Nazionale delle Ricerche – Istituto per 
#  lo Studio dell’Ambiente Marino Costiero
#  CMCC - Centro Euro-Mediterraneo sui Cambiamenti Climatici
# 
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-----------------------------------------------------------------------------------

APPNAME=$(basename $0)

echo "[$APPNAME] -- Removing temporary files..."
rm -f *.rso
rm -f medslik5.inp
rm -f medslik.tmp
rm -f output/*.fte
rm -f flag*.tmp
rm -f tmp*.tmp
rm -f oil_file.txt
rm -f initial*.txt

HOME_MEDSLIK=/work/opa/witoil-dev/mdk2-sanifs/
F_DATA=/work/opa/witoil-dev/mdk2-sanifs/DATA/

echo "[$APPNAME] -- Reading medslik_inputfile.txt"
source medslik_inputfile.txt

#FOR ITCG SYSTEM ONLY#
#age=0
#grid_size=150.0
#SAT_DATA=NO
#namefileGML=
#N_OS=
#####################

echo "[$APPNAME] -- Invoking read_oil_data.py"
python read_oil_data.py $OIL "$OIL_TYPE" 

###############################################################################
#0.                               OPTIONS
###############################################################################
if [ "$ContourSlick" == "YES" ] || [ "$SAT_DATA" == "YES" ]; then 
    isat=1; else  
    isat=0
fi 

###############################################################################
#1.                               CURRENTS AND WINDS
###############################################################################
if [ "$MODEL" == "REL" ]
then
    currents=74
    region=medf
fi 

if [ "$WIND" == "SKIRON" ]
then
    wind=5
fi 

step_output=001       # DO NOT CHANGE IT! in hours, 3 character example: 001
output_name=out       # DO NOT CHANGE IT! 3 letters, example:out


if [ $isat -eq 0 ] || [ "$ContourSlick" == "YES" ]
then
    restart=0
    #hrestart=0
    day=$day                   # 2 character example: 07
    month=$month               # 2 character example: 08
    year=$year                 # 2 character example: 08
    hour=$hour                 # 2 character example: 09
    minutes=$minutes           # 2 character example: 05
    duration=$duration         # in hours, 4 character example: 0024
    lat_degree=$lat_degree     # degrees, 2 character example: 06
    lat_minutes=$lat_minutes   # minutes, example: 06.62
    lon_degree=$lon_degree     # degrees, 2 character example: 06
    lon_minutes=$lon_minutes   # minutes, example: 06.62
    spillrate=$spillrate       # in tons/hours, example: 000055.00
    spillvolume=$spillvolume   # in tons example: 000055.00
fi
iage=$age

echo "[$APPNAME] -- Simulation date and time: $year/$month/$day $hour:$minutes"
echo "[$APPNAME] -- Spill location $lat_degree deg $lat_minutes min, $lon_degree deg $lon_minutes min"
echo "[$APPNAME] -- Simulation duration: $duration"

###############################################################################
#2.                  READ CONTOUR from the input file
###############################################################################
if [ "$ContourSlick" == "YES" ]
then
    echo '20'$year'/'$month'/'$day' '$hour':'$minutes >> initial.txt
    p=0
    N=1
    while [ $N -le $NSlick ]
    do

	var_name=$`echo '{#S'$N'lon[*]}'`
	apply_count="element_count=$var_name"
	eval $apply_count

	index=1 
	while [ "$index" -le "$element_count" ]
	do  
	    var_name_lon=$`echo '{S'$N'lon[$index]}'`
	    apply_name_lon="Slon[$index]=$var_name_lon"
	    eval $apply_name_lon

	    var_name_lat=$`echo '{S'$N'lat[$index]}'`
	    apply_name_lat="Slat[$index]=$var_name_lat"
	    eval $apply_name_lat

	    echo ${Slat[$index]} ${Slon[$index]} >> initial0.txt
	    index=`expr  $index + 1` 
	    p=`expr $p + 1`

	done
	N=`expr $N + 1`
	p=`expr $p + 1`
	echo ${Slat[1]} ${Slon[1]} >> initial0.txt
    done  
    echo $p'        Number of data points' >> initial.txt
    echo '  lat     lon' >> initial.txt
    cat initial0.txt>>initial.txt
fi
rm -f initial0.txt

################################################################################
#3.                   READ INPUT DATA FROM SATELLITE DATA 
################################################################################
if [ "$SAT_DATA" == "YES" ]
then

    python source/ReadSatData_EMSA.py $namefileGML $N_OS


    myFile="medslik_sat.inp"
    count=0
    for var in `cat $myFile` ; do
	count=`expr $count + 1`
	if [ $count -eq 2 ]; then  day=$var; fi
	if [ $count -eq 4 ]; then  month=$var; fi
	if [ $count -eq 6 ]; then  year=$var; fi
	if [ $count -eq 8 ]; then  hour=$var; fi
	if [ $count -eq 10 ]; then  minutes=$var; fi
	if [ $count -eq 12 ]; then  lat_degree=$var; fi
	if [ $count -eq 14 ]; then  lat_minutes=$var; fi
	if [ $count -eq 16 ]; then  lon_degree=$var; fi
	if [ $count -eq 18 ]; then  lon_minutes=$var; fi
	if [ $count -eq 20 ]; then  spillrate=$var; fi
	if [ $count -eq 22 ]; then  duration=$var; fi
	if [ $count -eq 24 ]; then  output_name=$var; fi
	if [ $count -eq 26 ]; then  step_output=$var; fi

    done
fi
################################################################################
#4. SAVE INPUT DATA 
################################################################################

echo "[$APPNAME] -- Saving input data..."

if [ $iage -eq 24 ]
then
    Day_24=20$year$month$day
    Day_0=`./jday $Day_24 -1`
    year=`echo $Day_0 |cut -c3-4`
    month=`echo $Day_0 |cut -c5-6`
    day=`echo $Day_0 |cut -c7-8`
    sim_length=`expr $sim_length + 24`  
fi
if [ $iage -eq 48 ]
then
    Day_24=20$year$month$day
    Day_0=`./jday $Day_24 -2`
    year=`echo $Day_0 |cut -c3-4`
    month=`echo $Day_0 |cut -c5-6`
    day=`echo $Day_0 |cut -c7-8`
    sim_length=`expr $sim_length + 48`
fi


multiple=01 #number of sumperimposed spills

#NUMBER OF FILES NEEDED 

numfiles=`expr $sim_length / 24 + 1`
int1=`expr $numfiles \* 24`
int2=`expr $sim_length / 1`


numfiles=$numfiles

if [ $iage -eq 24 ]
then
    numfiles=`expr $numfiles + 1`     
fi


#INITIAL DATE

FCStart1=20$year$month$day
FcStart1=$FCStart1
FcStart1=`echo $FcStart1 |cut -c1-8`


cp source/medslikYYYY.inp medslik0.inp
sed -e "s/giorno/$day/"\
    -e "s/mese/$month/"\
    -e "s/anno/$year/"\
    -e "s/ora/$hour/"\
    -e "s/minuti/$minutes/"\
    -e "s/durata/$duration/"\
    -e "s/lat_gradi/$lat_degree/"\
    -e "s/lat_primi/$lat_minutes/"\
    -e "s/lon_gradi/$lon_degree/"\
    -e "s/lon_primi/$lon_minutes/"\
    -e "s/nome/$output_name/"\
    -e "s/lunghezza/$sim_length/"\
    -e "s/step/$step_output/"\
    -e "s/eta/$iage/"\
    -e "s/sat/$isat/"\
    -e "s/portata/$spillrate/"\
    -e "s/regione/$region/"\
    -e "s/correnti/$currents/"\
    -e "s/vento/$wind/"\
    -e "s/multi/$multiple/"\
    -e "s/riinizio/$restart/"\
    -e "s/griglia/$grid_size/"\
    -e "s/numero_files/$numfiles/"\
    medslik0.inp>medslik1.inp
rm medslik0.inp

sed -n '1,18 p' medslik1.inp >medslik5.inp
cat oil_file.txt>>medslik5.inp
sed -n '27,31 p' medslik1.inp >medslik0.inp
cat medslik0.inp>>medslik5.inp
rm medslik[01].inp

#####################################################################
#5. PRE-PROCESSING OF CURRENTS & WIND FILES NEEDED FOR SIMULATION
#####################################################################

if  [ $currents = 74 ]
then
    dir='H3k'
    U='vozocrtx'
    V='vomecrty'
    T='votemper'
    model='RELOCATABLE'
    pre_name='MDK_ocean_'
    tail_name=''
fi

fcst_data=fcst_data
FD=$F_DATA/$fcst_data/$dir
rm -f tmp*.tmp

n=0
loop=$numfiles 

while [ $n != $loop ]; do
    n=`expr $n + 1`
    nn=`expr $n - 1`
    Datafc=`./jday $FcStart1 +$nn`
    DataFC=`echo $Datafc |cut -c3-8`
    DataFc=$DataFC
    echo "[$APPNAME] -- Checking currents for date $DataFc"
    DataFc_out=${DataFc}


    ###############################################################################
    #
    # NEW CODE BY FABIO TO CROP ORIGINAL DATA
    #
    ###############################################################################

    FILES_TO_CROP=()

    if [ $currents = 74 ]
    then
	if [ -f $FD/FULL_$pre_name${DataFc}$tail_name'_U.nc' ]
	then
	    
	    # define the file names
	    CROPPED=$FD/$pre_name${DataFc}$tail_name'_U.nc'
	    FULL=$FD/FULL_$pre_name${DataFc}$tail_name'_U.nc'

	    # debug print
	    echo "[$APPNAME] -- Cropping file $FULL"
	    
	    # crop the file
	    rm -f $CROPPED
	    sh crop_netcdf.sh nav_lat nav_lon $lat_degree $lat_minutes $lon_degree $lon_minutes $FULL $CROPPED 500 500

	    # create the link to the cropped file
	    ln -s $CROPPED $FD/${DataFc}'_U.nc' -f    
	    echo "${DataFc}_U.nc 1" >> tmp1.tmp
	    
	else
	    echo "${DataFc}_U.nc 0" >> tmp1.tmp
	    echo "[$APPNAME] -- For this run you need the file" FULL_$pre_name${DataFc}$tail_name'_U.nc'
	fi

	if [ -f $FD/FULL_$pre_name${DataFc}$tail_name'_V.nc' ]
	then
	    
	    # define the file names
	    CROPPED=$FD/$pre_name${DataFc}$tail_name'_V.nc'
	    FULL=$FD/FULL_$pre_name${DataFc}$tail_name'_V.nc'

	    # debug print
	    echo "[$APPNAME] -- Cropping file $FULL"
	    
	    # crop the file
	    rm -f $CROPPED
	    sh crop_netcdf.sh nav_lat nav_lon $lat_degree $lat_minutes $lon_degree $lon_minutes $FULL $CROPPED 500 500

	    # create the link to the cropped file
	    ln -s $CROPPED $FD/${DataFc}'_V.nc' -f    
	    echo "${DataFc}_V.nc 1" >> tmp1.tmp

	else
	    echo "${DataFc}_V.nc 0" >> tmp1.tmp
	    echo "[$APPNAME] -- For this run you need the file" FULL_$pre_name${DataFc}$tail_name'_V.nc'
	fi

	if [ -f $FD/FULL_$pre_name${DataFc}$tail_name'_T.nc' ]
	then
	    
	    # define the file names
	    CROPPED=$FD/$pre_name${DataFc}$tail_name'_T.nc'
	    FULL=$FD/FULL_$pre_name${DataFc}$tail_name'_T.nc'

	    # debug print
	    echo "[$APPNAME] -- Cropping file $FULL"
	    
	    # crop the file
	    rm -f $CROPPED
	    sh crop_netcdf.sh nav_lat nav_lon $lat_degree $lat_minutes $lon_degree $lon_minutes $FULL $CROPPED 500 500

	    # create the link to the cropped file
	    ln -s $CROPPED $FD/${DataFc}'_T.nc' -f    
	    echo "${DataFc}_T.nc 1" >> tmp1.tmp

	else
	    echo "${DataFc}_T.nc 0" >> tmp1.tmp
	    echo "[$APPNAME] -- For this run you need the file FULL_" $pre_name${DataFc}$tail_name "_T.nc"
	fi


    fi

    # debug print
    echo "[$APPNAME] -- Cropping completed for date $year/$month/$day"

    if [ $wind != 01 ]
    then

	dir_wind='SK1'
	FD_wind_in=$F_DATA/$fcst_data/$dir_wind
	FD_wind=$F_DATA/$fcst_data/$dir_wind
	Datafc=$Datafc

	DataFC=`echo $Datafc |cut -c3-8`
	DataFc=$DataFC

	###############################################################################
	#
	# NEW CODE BY FABIO TO CROP ORIGINAL DATA
	#
	###############################################################################

	# if [ $wind = 5 ]
	# then	    
	#     Data_wind="20"${DataFc}
	#     File_wind="sk1_"${DataFc}".sk1"
	    
	#     # set file names
	#     FULL=$FD_wind_in/FULL_${Data_wind}.nc
	#     CROPPED=$FD_wind_in/${Data_wind}.nc
	    
	#     echo "[$APPNAME] -- Checking winds $Data_wind"
	#     if [ -f $FULL ]
	#     then
	# 	echo "${File_wind} 1" >> tmp2.tmp
	# 	echo "[$APPNAME] -- $FULL : File exists"

	# 	# crop
	# 	echo "[$APPNAME] -- Cropping wind file $FULL ..."
	# 	sh crop_netcdf.sh lat lon $lat_degree $lat_minutes $lon_degree $lon_minutes $FULL $CROPPED 200 200
		
	#     else
	# 	echo "${File_wind} 0" >> tmp2.tmp
	# 	echo "[$APPNAME] -- For this run you need the file $FULL"
	#     fi
	# fi

	if [ $wind = 5 ]
	then
	    Data_wind="20"${DataFc}
	    File_wind="sk1_"${DataFc}".sk1"
	    echo "[$APPNAME] -- Checking winds $Data_wind"
	    if [ -f $FD_wind_in/${Data_wind}.nc ]
	    then
		echo "${File_wind} 1" >> tmp2.tmp
		echo "[$APPNAME] -- $FD_wind_in/${Data_wind}.nc : File exists" 
	    else
		echo "${File_wind} 0" >> tmp2.tmp
		echo "[$APPNAME] -- For this run you need the file" ${Data_wind}.nc
	    fi
	fi

    fi

done


cat tmp1.tmp>>medslik5.inp
echo $numfiles >> medslik5.inp

cat tmp2.tmp>>medslik5.inp
cat medslik_multi.tmp>>medslik5.inp 

#############################################################
#6. AREA SELECTION (MIN/MAX Longitudes & Latitudes)
#############################################################
cp source/medslikYYYY.tmp medslik0.tmp
sed -e "s/regione/$region/"\
    -e "s/correnti/$currents/"\
    -e "s/vento/$wind/"\
    medslik0.tmp>medslik1.tmp
rm medslik0.tmp


./lat_lon.exe
mv medslik1.tmp medslik.tmp

echo $numfiles >> medslik.tmp

numfiles_tmp=`expr $numfiles + 1`

n=0
while [ $n != $numfiles_tmp ]; do
    n=`expr $n + 1`
    nn=`expr $n - 1`
    Datafc=`./jday $FcStart1 +$nn`
    DataFC=`echo $Datafc |cut -c3-8`
    DataFc=$DataFC
    echo ${DataFc}24 >> medslik.tmp
done

if [ $currents = 74 ] 
then
    numfiles_tmp=`expr $numfiles + 1`
    echo $numfiles_tmp >> medslik.tmp 
    n=0
    while [ $n != $numfiles_tmp ]; do
	n=`expr $n + 1`
	nn=`expr $n - 1`
	Datafc=`./jday $FcStart1 +$nn`
	DataFC=`echo $Datafc |cut -c3-8`
	DataFc=$DataFC
	echo ${Datafc} >> medslik.tmp
    done
fi


echo " 0" >> medslik.tmp 


tr -d "\015" < medslik5.inp > medslik52.inp
cp medslik52.inp medslik5.inp
rm medslik52.inp

tr -d "\015" < medslik.tmp > medslik2.tmp
cp medslik2.tmp medslik.tmp
rm medslik2.tmp

#######################################################################
# CREATE OUTPUT DIRECTORY 
#######################################################################

DIR_output=$model'_20'$year'_'$month'_'$day'_'$hour$minutes'_'$SIM_NAME
echo "[$APPNAME] -- Creating output directory output/$DIR_output"
mkdir output/$DIR_output
mkdir output/$DIR_output/MET
mkdir output/$DIR_output/OCE

#######################################################################
#7. EXTRACT CURRENTS, WIND AND SST DATA
#####################################################################

echo "[$APPNAME] -- Invoking Extract_II.exe..."
./Extract_II.exe $F_DATA

######################################################################
#8. RUN 
#####################################################################

echo "[$APPNAME] -- Invoking medslik_II.exe... Running simulation!"
./medslik_II.exe

#####################################################################
#9. ARCHIVE OUTPUT FILES
#####################################################################

echo "[$APPNAME] -- Archiving output files..."
rm tmp*.tmp
cp medslik5.inp  output/$DIR_output
cp medslik5.par  output/$DIR_output
cp medslik.tmp output/$DIR_output
cp initial.txt output/$DIR_output
cp medslik_inputfile.txt output/$DIR_output
mv output/*.tot output/$DIR_output
mv output/*.fte output/$DIR_output
mv output/*.cst output/$DIR_output
mv spill_properties.nc output/$DIR_output


mv obs* output/$DIR_output

echo "[$APPNAME] -- Saving wind .sk1 files..."
if  [ $wind = 5 ]
then
    mv fcst_data/SK1/*.* output/$DIR_output/MET
fi

echo "[$APPNAME] -- Saving currents .rel files..."
if  [ $currents = 74 ]
then
    mv fcst_data/H3k/*.* output/$DIR_output/OCE
fi
