#!/bin/bash

######################
source config.cfg
######################

enhancement() {

    option=$1
    name=$2
    
    echo -e ${option}":"
    $wxdir/wxtoimg -m ${file}-map.png -k "%N" -k "%d/%m/%Y - %H:%M UTC" -k "fontsize=14 %D %E %z" -k "fontsize=14 ${option}" -e ${option} -c -y low -o ${file}_res.wav ${file}-${name}.png &> ${name}.log
    touch -r ${file}.wav ${file}-${name}.png
    cat ${name}.log

    # Remove a wrong enhancement for missed channel
    error=`cat ${name}.log | grep -i "warning: enhancement ignored"`
    if  [ ! -z "$error" ]; then
	rm ${file}-${name}.png
	echo ${file} $error >> errors.log
    else
	# Preserve in /deleted any other warning
	error=`cat ${name}.log | grep -i "warning"`
	if  [ ! -z "$error" ]; then
            mv ${file}-${name}.png $output/noaa/deleted/
            echo ${file} $error >> errors.log
	fi
    fi
    
    rm -rf ${name}.log

}

enhancement_IR() {

    option=$1
    name=$2
    
    echo -e ${option}":"
$wxdir/wxtoimg -m ${file}-map.png -k "%N" -k "%d/%m/%Y - %H:%M UTC" -k "fontsize=14 %D %E %z" -k "fontsize=14 ${name}" -b -e ${option} -c -o ${file}_res.wav ${file}-${name}.png &> ${name}.log

    touch -r ${file}.wav ${file}-${name}.png
    cat ${name}.log

    # Remove a wrong enhancement for missed channel
    error=`cat ${name}.log | grep -i "warning: enhancement ignored"`
    if  [ ! -z "$error" ]; then
	rm ${file}-${name}.png
	echo ${file} $error >> errors.log
    else
	# Preserve in /deleted any other warning
	error=`cat ${name}.log | grep -i "warning"`
	if  [ ! -z "$error" ]; then
            mv ${file}-${name}.png $output/noaa/deleted/
            echo ${file} $error >> errors.log
	fi
    fi
    
    rm -rf ${name}.log

}

######################

file=$1   # full path without extension
filename=`basename ${file}` # filename used to extract variables for the map

echo -e "\n\033[1m${file}\033[0m"

if [ ! -f "${file}.wav" ]; then
    echo "Wrong audio file name... exit"
    exit
fi

if [ `wc -c <${file}.wav` -le 1000000 ]; then
    echo "Audio file ${file}.wav too small, probably wrong recording"
    exit
fi

# variables for the map
satellite=`echo $filename | awk -F_ '{print $2}'`
satellite=`echo "NOAA" ${satellite:4:2}`
start=`echo $filename | awk -F_ '{print $filename}'`
start=`echo ${start:0:8} ${start:9:2}:${start:11:2}:${start:13:2}`
start=`date -d "${start}" +%s`

tle=$dir/weather.tle

# resampling
rm -rf ${file}.png
rm -rf ${file}_res.wav
sox ${file}.wav -r 11025 ${file}_res.wav
touch -r ${file}.wav ${file}_res.wav

# map to overlay
$wxdir/wxmap -c g:dark-cyan -c C:light-green -a -T "$satellite" -H $tle -p 0 -l 1 -o $start ${file}-map.png &> wxtoimg.log
cat wxtoimg.log

# IR:
enhancement_IR histeq IR

# VIS:
enhancement HVC HVC
enhancement MSA MSA
enhancement MSA-precip MSA-precip
enhancement HVCT HVCT

# clean up
rm -rf ${file}-map.png
rm -rf ${file}_res.wav
rm -rf wxtoimg.log


#direction=`less wxtoimg.log  | grep Direction | awk '{print $2}'`
#if [[ "$direction" == "southbound" ]]; then
#   echo "Rotate: "
#   convert -rotate 180 $file-IR.png $file-IR.png
#   convert -rotate 180 $file-HVC.png $file-HVC.png
#fi

#convert -rotate 180 ${file}-map.png ${file}-map.png

#convert -rotate 180 $file.png $file.png
#eog $file.png
