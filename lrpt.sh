# Work in progres...
#
# Tested on M2
# Not working on M22
#  implemented oqpsk from meteor_demod

####################
source config.cfg
####################

file=$1
echo -e "\n\033[1m$file\033[0m"

if [ ! -f "${file}.wav" ]; then
    echo "Wrong audio file name... exit"
    exit
fi

if [ `wc -c <${file}.wav` -le 1000000 ]; then
    echo "Audio file ${file}.wav too small, probably wrong recording"
    exit
fi

# Normalise:
#sox ${file}.wav ${file}_norm.wav channels 1 gain -n
sox ${file}.wav ${file}_norm.wav gain -n

# Demodulate:                                                                                                                                                           
if [[ ${file: -2} == "M2" ]]; then
    yes | $demod -B -m qpsk  -o ${file}.qpsk ${file}_norm.wav    
else
    
    yes | $demod -B -b 50 -m oqpsk -o ${file}.qpsk ${file}_norm.wav 
fi
touch -r ${file}.wav ${file}.qpsk

# Decode:
if [[ ${file: -2} == "M2" ]]; then
    $decoder ${file}.qpsk ${file} -cd -q
else
    $decoder ${file}.qpsk ${file} -diff -cd -q  # -int for 80KHz ??
fi
touch -r ${file}.wav ${file}.dec

# Create image:
# composite only
$decoder ${file}.dec ${file} -r 65 -g 65 -b 64 -d -q
# three channels
#$decoder ${file}.dec ${file} -S -r 65 -g 65 -b 64 -d -q     
# IR
$decoder ${file}.dec ${file}_IR -r 68 -g 68 -b 68 -d -q

if [[ -f "${file}.bmp" ]]; then
    convert ${file}.bmp ${file}.png &> /dev/null
    rm -f ${file}.bmp
    touch -r ${file}.wav ${file}.png
    # check brightness
    brightness=`convert ${file}.png -colorspace Gray -format "%[fx:image.mean]" info:`
    if (( $(echo "$brightness > 0.09" |bc -l) )); then
	echo -e "\nComposite image created!"
    else
	mv ${file}.png $output/meteor/deleted/
	echo -e "\nComposite image too dark, probably bad quality."
    fi
	
fi

if [[ -f "${file}_IR.bmp" ]]; then
    convert ${file}_IR.bmp -negate -normalize ${file}_IR.png &> /dev/null
    rm -f ${file}_IR.bmp
    touch -r ${file}.wav ${file}_IR.png
    # check brightness
    brightness=`convert ${file}_IR.png -negate -colorspace Gray -format "%[fx:image.mean]" info:`
    if (( $(echo "$brightness > 0.09" |bc -l) )); then
	echo -e "\nIR image created!"
    else
	mv ${file}_IR.png $output/meteor/deleted/
	echo -e "\nIR image too dark, probably bad quality."
    fi
fi


rm -f ${file}_norm.wav
rm -f ${file}.qpsk
rm -f ${file}.dec
