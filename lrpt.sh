# Working... to be finished and tested

#demod=/home/franchini/Satellite/METEOR/meteor_demod/meteor_demod
#decoder=/home/franchini/Satellite/METEOR/meteor_decoder/medet

source config.cfg

file=$1

if [ `wc -c <${file}.wav` -le 1000000 ]; then
    echo "Audio file ${file}.wav too small, probably wrong recording"
    exit
fi

#rm

# Normalise:
sox $file.wav ${file}_norm.wav gain -n

# Demodulate:                                                                                                                                                           
yes | $demod -B -o ${file}.qpsk ${file}.wav    

# Decode:
$decoder ${file}.qpsk ${file} -cd -q

# Create image:
# only composite $decoder ${file}.dec ${file} -r 65 -g 65 -b 64 -d -q
$decoder ${file}.dec ${file} -S -r 65 -g 65 -b 64 -d -q

