# Working... to be finished and tested again
# implemented oqpsk from meteor_demod

####################
source config.cfg
####################

file=$1
echo -e "\n\033[1m$file\033[0m"

if [ `wc -c <${file}.wav` -le 1000000 ]; then
    echo "Audio file ${file}.wav too small, probably wrong recording"
    exit
fi

# Normalise:
#sox ${file}.wav ${file}_norm.wav channels 1 gain -n
sox ${file}.wav ${file}_norm.wav gain -n

# Demodulate:                                                                                                                                                           
if [[ ${file: -2} == "M2" ]]; then
    yes | $demod -B -o ${file}.qpsk ${file}_norm.wav    
else
    yes | $demod -B -m oqpsk -o ${file}.qpsk ${file}_norm.wav
fi
touch -r ${file}.wav ${file}.qpsk

# Decode:
#$decoder ${file}.qpsk ${file} -cd -q
#touch -r ${file}.wav ${file}.dec

# Create image:
# only composite

#$decoder ${file}.dec ${file} -r 65 -g 65 -b 64 -d -q
/home/franchini/Satellite/METEOR/meteor_decode_dev/src/meteor_decode -q -d -a 65,65,64 -o ${file}.png ${file}.qpsk

if [[ -f "${file}.png" ]]; then
    touch -r ${file}.wav ${file}.png
    echo -e "\nImage created!"
fi

rm -f ${file}_norm.wav
#rm -f ${file}.qpsk
#rm -f ${file}.dec
