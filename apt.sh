
file=audio/$1
echo -e "\n\033[1m$file\033[0m"

if [ `wc -c <${file}.wav` -le 1000000 ]; then
    echo "Audio file ${file}.wav too small, probably wrong recording"
    exit
fi

# variables for the map
satellite=`echo $1 | awk -F_ '{print $2}'`
satellite=`echo "NOAA" ${satellite:4:2}`
start=`echo $1 | awk -F_ '{print $1}'`
start=`echo ${start:0:8} ${start:9:2}:${start:11:2}:${start:13:2}`
start=`date -d "${start}" +%s`

tle=/home/franchini/Satellite/code/weather.tle

# resampling
rm -rf $file.png
rm -rf $file_res.wav
sox $file.wav -r 11025 ${file}_res.wav
touch -d @`stat -c %Y $file.wav` ${file}_res.wav

#/home/franchini/Satellite/wxtoimg/usr/local/bin/wxmap -L 44.422/12.224/0.0 -l 1 -c L:blue -c C:blue -c S:blue -c g:dark-cyan -a -T "$satellite" -H $tle -p 0 -l 0 -o $start ${file}-map.png &> wxtoimg.log  
/home/franchini/Satellite/wxtoimg/usr/local/bin/wxmap -c g:dark-cyan -a -T "$satellite" -H $tle -p 0 -l 0 -o $start ${file}-map.png &> wxtoimg.log
cat wxtoimg.log

#direction=`less wxtoimg.log  | grep Direction | awk '{print $2}'`

# IR:
/home/franchini/Satellite/wxtoimg/wxtoimg -m ${file}-map.png -b -e histeq -c -o ${file}_res.wav $file-IR.png &> IR.log
cat IR.log
error=`cat IR.log | grep -i "warning"`
if  [ ! -z "$error" ]; then
    mv $file-IR.png audio/deleted/
    echo $file $error >> errors.log
fi

# VIS:
/home/franchini/Satellite/wxtoimg/wxtoimg -m ${file}-map.png -e HVC -c -y low -o ${file}_res.wav $file-HVC.png &> HVC.log
cat HVC.log
error=`cat HVC.log | grep -i "warning"`
if  [ ! -z "$error" ]; then
    mv $file-HVC.png audio/deleted/
    echo $file $error >> errors.log
fi

/home/franchini/Satellite/wxtoimg/wxtoimg -m ${file}-map.png -e HVCT -c -y low -o ${file}_res.wav $file-HVCT.png &> HVCT.log
cat HVCT.log
error=`cat HVCT.log | grep -i "warning"`
if  [ ! -z "$error" ]; then
    mv $file-HVCT.png audio/deleted/
    echo $file $error >> errors.log
fi
    
rm -rf ${file}-map.png

#if [[ "$direction" == "southbound" ]]; then
#   echo "Rotate: "
#   convert -rotate 180 $file-IR.png $file-IR.png
#   convert -rotate 180 $file-HVC.png $file-HVC.png
#fi

#convert -rotate 180 ${file}-map.png ${file}-map.png

rm wxtoimg.log
rm IR.log
rm HVC.log
rm HVCT.log

#rm ${file}-map.png
#convert -rotate 180 $file.png $file.png
#eog $file.png
