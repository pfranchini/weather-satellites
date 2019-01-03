# To be finished and tested

file=$1
option=$2

if [ `wc -c <${file}.wav` -le 1000000 ]; then
    echo "Audio file ${file}.wav too small, probably wrong recording"
    exit
fi

#rm

# Normalise:
#sox $file.wav ${file}_norm.wav gain -n

# Demodulate:                                                                                                                                                           
#yes | /home/franchini/Satellite/METEOR/meteor_demod/meteor_demod -o ${file}.qpsk ${file}_norm.wav    

# Decode:
#/home/franchini/Satellite/METEOR/meteor_decoder/medet ${file}.qpsk ${file} -cd

# Create image:
#/home/franchini/Satellite/METEOR/meteor_decoder/medet ${file}.dec ${file} -r 65 -g 65 -b 64 -d
/home/franchini/Satellite/METEOR/meteor_decoder/medet ${file}.dec ${file}_all -S -r 65 -g 65 -b 64 -d

