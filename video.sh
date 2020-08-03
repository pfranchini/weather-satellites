#!/bin/bash

#==================================================================
#
# Usage: ./video.sh <list_of_files.wav>
#  e.g.: ./video.sh noaa/20200711-*.wav noaa/20200712-*.wav
#
#==================================================================

##################
source config.cfg
##################

function apt_proj {

    rm -f rm $file-proj.png

    file=$1   # full path without extension
    filename=`basename $file` # filename used to extract variables for the map
    
    # coordinates
    latitude=`sed '2q;d' $where`
    longitude=`sed '3q;d' $where`
    
    #echo "($latitude, $longitude)"
    
    echo -e "\n\033[1m$file\033[0m"
    
    if [ ! -f "${file}.wav" ]; then
	echo "Wrong audio file name... exit"
	return
    fi
    
    if [ `wc -c <${file}.wav` -le 1000000 ]; then
	echo "Audio file ${file}.wav too small, probably wrong recording"
	return
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
    
    # IR for projection:
    $wxdir/wxtoimg -m ${file}-map.png -b -c -e histeq -H const -y full -o ${file}_res.wav $file-IR-proj.png &> proj.log
    #$wxdir/wxtoimg -m ${file}-map.png -b -c -H const -y full -o ${file}_res.wav $file-IR-proj.png &> proj.log
    cat proj.log
    error=`cat proj.log | grep -i "warning"`
    if  [ -n "$error" ]; then
	mv $file-IR-proj.png $output/noaa/deleted/
	echo $file $error >> errors.log
    else
	$wxdir/wxproj -p mercator -k "%d/%m/%Y - %H:%M UTC" -Q 100 -b 55,30,-5,25 -A 50% -N -v -o $file-IR-proj.png $file-proj.png &> wxproj.log
	error_proj=`cat wxproj.log | grep -i "warning"`
	if  [ -n "$error_proj" ]; then
	    rm $file-proj.png
	    echo "Image not used for the video"
	fi
	rm -f $file-IR-proj.png
    fi
    
    
    # clean up
    rm -rf ${file}-map.png
    rm -rf ${file}_res.wav
    rm -rf wxtoimg.log
    rm -rf wxproj.log
    rm -rf proj.log

}

#==================================================================
#
# Main program:

input_list="$@"

echo $input_list

for file in $input_list; do
    
    file=$(echo "$file" | cut -f 1 -d '.')
    apt_proj $file
    if [[ -e $file-proj.png ]]; then
	output_list="$output_list $file-proj.png"
    fi

done

output_file="video_"`date +%Y%m%d-%H%M%S`".mp4"

# GIF
#convert -delay 100 -loop 0 $output $output_file

# MP4
cat $output_list | ffmpeg -y -f image2pipe -framerate 2 -i - $output_file

echo "Output: "$output_file
