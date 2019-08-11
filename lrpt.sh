# Working... to be finished and tested again

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
sox $file.wav ${file}_norm.wav gain -n

# Demodulate:                                                                                                                                                           
yes | $demod -B -o ${file}.qpsk ${file}_norm.wav    

# Decode:
$decoder ${file}.qpsk ${file} -cd -q

# Create image:
# only composite
$decoder ${file}.dec ${file} -r 65 -g 65 -b 64 -d -q
# three channels
# $decoder ${file}.dec ${file} -S -r 65 -g 65 -b 64 -d -q

if [[ -f "${file}.bmp" ]]; then
  convert ${file}.bmp ${file}.png
  rm -f ${file}.bmp
fi

rm -f ${file}_norm.wav
#rm -f ${file}.qpsk
#rm -f ${file}.dec
