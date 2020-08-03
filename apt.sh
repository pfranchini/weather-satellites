#!/bin/bash

######################
source config.cfg
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

#direction=`less wxtoimg.log  | grep Direction | awk '{print $2}'`

# IR:
$wxdir/wxtoimg -m ${file}-map.png -k "%N" -k "%d/%m/%Y - %H:%M UTC" -k "fontsize=14 %D %E %z" -k "fontsize=14 IR" -b -e histeq -c -o ${file}_res.wav ${file}-IR.png &> IR.log
touch -r ${file}.wav ${file}-IR.png
cat IR.log
error=`cat IR.log | grep -i "warning"`
if  [ ! -z "$error" ]; then
    mv ${file}-IR.png $output/noaa/deleted/
    echo ${file} $error >> errors.log
fi

# check if there is a visible channel and not only two IR
##visible=`cat IR.log | grep -i "visible"`
##if  [ ! -z "$visible" ]; then

    # VIS:
    $wxdir/wxtoimg -m ${file}-map.png -k "%N" -k "%d/%m/%Y - %H:%M UTC" -k "fontsize=14 %D %E %z" -k "fontsize=14 HVC" -e HVC -c -y low -o ${file}_res.wav ${file}-HVC.png &> HVC.log
    touch -r ${file}.wav ${file}-HVC.png
    cat HVC.log
    error=`cat HVC.log | grep -i "warning"`
    if  [ ! -z "$error" ]; then
	mv ${file}-HVC.png $output/noaa/deleted/
	echo ${file} $error >> errors.log
    fi

    $wxdir/wxtoimg -m ${file}-map.png -k "%N" -k "%d/%m/%Y - %H:%M UTC" -k "fontsize=14 %D %E %z" -k "fontsize=14 MSA-precip" -e MSA-precip -c -y low -o ${file}_res.wav ${file}-MSA-precip.png &> MSA-precip.log
    touch -r ${file}.wav ${file}-MSA-precip.png
    cat MSA-precip.log
    error=`cat MSA-precip.log | grep -i "warning"`
    if  [ ! -z "$error" ]; then
	mv ${file}-MSA-precip.png $output/noaa/deleted/
	echo ${file} $error >> errors.log
    fi

    $wxdir/wxtoimg -m ${file}-map.png -k "%N" -k "%d/%m/%Y - %H:%M UTC" -k "fontsize=14 %D %E %z" -k "fontsize=14 HVCT" -e HVCT -c -y low -o ${file}_res.wav ${file}-HVCT.png &> HVCT.log
    touch -r ${file}.wav ${file}-HVCT.png
    cat HVCT.log 
    error=`cat HVCT.log | grep -i "warning"`
    if  [ ! -z "$error" ]; then
	mv ${file}-HVCT.png $output/noaa/deleted/
	echo ${file} $error >> errors.log
    fi

    # MSA:
    $wxdir/wxtoimg -m ${file}-map.png -k "%N" -k "%d/%m/%Y - %H:%M UTC" -k "fontsize=14 %D %E %z" -k "fontsize=14 MSA" -e MSA -c -y low -o ${file}_res.wav ${file}-MSA.png &> MSA.log
    touch -r ${file}.wav ${file}-MSA.png
    cat MSA.log
    error=`cat MSA.log | grep -i "warning"`
    if  [ ! -z "$error" ]; then
	mv ${file}-MSA.png $output/noaa/deleted/
	echo ${file} $error >> errors.log
    fi

##else
##    echo "Only 2 IR channels, no visible present"
##fi

# clean up
rm -rf ${file}-map.png
rm -rf ${file}_res.wav
rm -rf wxtoimg.log
rm -rf IR.log
rm -rf HVC.log
rm -rf HVCT.log
rm -rf MSA.log
rm -rf MSA-precip.log

#if [[ "$direction" == "southbound" ]]; then
#   echo "Rotate: "
#   convert -rotate 180 $file-IR.png $file-IR.png
#   convert -rotate 180 $file-HVC.png $file-HVC.png
#fi

#convert -rotate 180 ${file}-map.png ${file}-map.png

#convert -rotate 180 $file.png $file.png
#eog $file.png
