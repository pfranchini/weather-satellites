
file=audio/$1

if [ `wc -c <${file}.wav` -le 1000000 ]; then
    echo "Audio file ${file}.wav too small, probably wrong recording"
    exit
fi

rm -rf $file_res.wav

sox $file.wav -r 11025 ${file}_res.wav

/home/franchini/Satellite/wxtoimg/wxtoimg -v -e ZA -o ${file}_res.wav $file-ZA.png >& wxtoimg.log
#convert -rotate 180 $file-ZA.png $file-ZA.png

/home/franchini/Satellite/wxtoimg/wxtoimg -v -e HVC -o ${file}_res.wav $file-HVC.png
#convert -rotate 180 $file-HVC.png $file-HVC.png


#eog $file.png
