
file=audio/$1

if [ `wc -c <${file}.wav` -le 1000000 ]; then
    echo "Audio file ${file}.wav too small, probably wrong recording"
    exit
fi

rm -rf $file_res.wav

# Resample and Decode:                                                                                                                                                  
echo "sox -r 192000 -e signed -b 16 -c 2 audio/${filename}.raw audio/${filename}.wav" >> job.txt
echo "sox audio/${filename}.wav audio/${filename}_res.wav rate 140000" >> job.txt

at $at_start -f job.txt
rm job.txt

# Demodulate:                                                                                                                                                           
#/home/franchini/Satellite/METEOR/meteor_demod/meteor_demod -q -s 140000 -o ${filename}.wav ${filename}.bin                                                             

# Decode:                                                                                                                                                               
#/home/franchini/Satellite/METEOR/meteor_decoder/medet ${filename}.wav ${filename}.png    

#eog $file.png
