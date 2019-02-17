
######################
source config.cfg
#dir=/home/franchini/Satellite/code
#output=/home/franchini/Satellite/code
#wxdir=/home/franchini/Satellite/wxtoimg/usr/local/bin/
#####################


file=$1   # full path
filename=`basename $file` # filename used to extract variables for the map

echo -e "\n\033[1m$file\033[0m"

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

#$wxdir/usr/local/bin/wxmap -L 44.422/12.224/0.0 -l 1 -c L:blue -c C:blue -c S:blue -c g:dark-cyan -a -T "$satellite" -H $tle -p 0 -l 0 -o $start ${file}-map.png &> wxtoimg.log  
$wxdir/wxmap -c g:dark-cyan -a -T "$satellite" -H $tle -p 0 -l 0 -o $start ${file}-map.png &> wxtoimg.log
cat wxtoimg.log

#direction=`less wxtoimg.log  | grep Direction | awk '{print $2}'`

# IR:
$wxdir/wxtoimg -m ${file}-map.png -k "%N" -k "%d/%m/%Y - %H:%M UTC" -k "fontsize=14 %D %E %z" -k "fontsize=14 IR" -b -e histeq -c -o ${file}_res.wav $file-IR.png &> IR.log
cat IR.log
error=`cat IR.log | grep -i "warning"`
if  [ ! -z "$error" ]; then
    mv $file-IR.png $output/noaa/deleted/
    echo $file $error >> errors.log
fi

# VIS:
$wxdir/wxtoimg -m ${file}-map.png -k "%N" -k "%d/%m/%Y - %H:%M UTC" -k "fontsize=14 %D %E %z" -k "fontsize=14 HVC" -e HVC -c -y low -o ${file}_res.wav $file-HVC.png &> HVC.log
cat HVC.log
error=`cat HVC.log | grep -i "warning"`
if  [ ! -z "$error" ]; then
    mv $file-HVC.png $output/noaa/deleted/
    echo $file $error >> errors.log
fi

$wxdir/wxtoimg -m ${file}-map.png -k "%N" -k "%d/%m/%Y - %H:%M UTC" -k "fontsize=14 %D %E %z" -k "fontsize=14 HVCT" -e HVCT -c -y low -o ${file}_res.wav $file-HVCT.png &> HVCT.log
cat HVCT.log 
error=`cat HVCT.log | grep -i "warning"`
if  [ ! -z "$error" ]; then
    mv $file-HVCT.png $output/noaa/deleted/
    echo $file $error >> errors.log
fi

# Clean up
rm -rf ${file}-map.png
rm -rf ${file}_res.wav
rm -rf  wxtoimg.log
rm -rf IR.log
rm -rf HVC.log
rm -rf HVCT.log

#if [[ "$direction" == "southbound" ]]; then
#   echo "Rotate: "
#   convert -rotate 180 $file-IR.png $file-IR.png
#   convert -rotate 180 $file-HVC.png $file-HVC.png
#fi

#convert -rotate 180 ${file}-map.png ${file}-map.png

#rm ${file}-map.png
#convert -rotate 180 $file.png $file.png
#eog $file.png
