
file=audio/$1

rm -rf $file.png
rm -rf $file_res.wav
sox $file.wav -r 11025 ${file}_res.wav
/home/franchini/Satellite/wxtoimg/wxtoimg -e HVC ${file}_res.wav $file.png
convert -rotate 180 $file.png $file.png
#eog $file.png
