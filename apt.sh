
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

rm -rf $file.png
rm -rf $file_res.wav
sox $file.wav -r 11025 ${file}_res.wav

/home/franchini/Satellite/wxtoimg/usr/local/bin/wxmap -a -T "$satellite" -H $tle -p 0 -l 0 -o $start ${file}-map.png &> wxtoimg.log
cat wxtoimg.log

direction=`less wxtoimg.log  | grep Direction | awk '{print $2}'`

/home/franchini/Satellite/wxtoimg/wxtoimg -m ${file}-map.png -e ZA  -c -o ${file}_res.wav $file-ZA.png &> ZA.log
cat ZA.log
error=`cat ZA.log | grep -i "warning"`
if  [ ! -z "$error" ]; then
    rm -rf $file-ZA.png
    #echo $file $error >> errors.log
fi

/home/franchini/Satellite/wxtoimg/wxtoimg -m ${file}-map.png -e HVC -c -y low -o ${file}_res.wav $file-HVC.png &> HVC.log
cat HVC.log
error=`cat HVC.log | grep -i "warning"`
if  [ ! -z "$error" ]; then
    rm -rf $file-HVC.png
    #echo $file $error >> errors.log                                                                                                                                        
fi

rm -rf ${file}-map.png

#if [[ "$direction" == "southbound" ]]; then
#   echo "Rotate: "
#   convert -rotate 180 $file-ZA.png $file-ZA.png
#   convert -rotate 180 $file-HVC.png $file-HVC.png
#fi

#convert -rotate 180 ${file}-map.png ${file}-map.png

rm wxtoimg.log

#rm ${file}-map.png
#convert -rotate 180 $file.png $file.png
#eog $file.png
