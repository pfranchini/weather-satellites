#!/bin/bash

#
# Usage: ./lprt.sh <path/meteor_audio_file> without ".wav"
#
# Work in progres...
#
# Tested on M2
# Not working on M22
#  implemented oqpsk from meteor_demod

####################
source config.cfg
####################

####################
#options="-equalize"
#options="-brightness-contrast 40x40"
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

# Decoder:
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

# composite:
if [[ -f "${file}.bmp" ]]; then
    convert ${file}.bmp ${file}.jpg &> /dev/null
    rm -f ${file}.bmp
    # check brightness
    brightness=`convert ${file}.jpg -colorspace Gray -format "%[fx:image.mean]" info:`
    if (( $(echo "$brightness > 0.07" |bc -l) )); then
	# rectify
	${rectify} ${file}.jpg
	convert ${file}-rectified.jpg ${options} ${file}-rectified.jpg
	mv ${file}-rectified.jpg ${file}.jpg
	touch -r ${file}.wav ${file}.jpg

	echo -e "\nComposite image created!"
    else
	# still does the rectification
	${rectify} ${file}.jpg
	convert ${file}-rectified.jpg ${options} ${file}-rectified.jpg
	mv ${file}-rectified.jpg ${file}.jpg
	# move in /deleted
	mv ${file}.jpg $output/meteor/deleted/
	echo -e "\nComposite image too dark, probably bad quality."
    fi

else
    echo -e "\nDecoded image not produced."
fi

# IR:
if [[ -f "${file}_IR.bmp" ]]; then
    convert ${file}_IR.bmp -negate -normalize ${file}_IR.jpg &> /dev/null
    rm -f ${file}_IR.bmp
    # check brightness
    brightness=`convert ${file}_IR.jpg -negate -colorspace Gray -format "%[fx:image.mean]" info:`
    if (( $(echo "$brightness > 0.07" |bc -l) )); then
	# rectify
	${rectify} ${file}_IR.jpg
	convert ${file}_IR-rectified.jpg ${options} ${file}_IR-rectified.jpg
	mv ${file}_IR-rectified.jpg ${file}_IR.jpg
	touch -r ${file}.wav ${file}_IR.jpg

	echo -e "\nIR image created!"
    else
	if [[ "$brightness" == "0" ]]; then
	    rm ${file}_IR.jpg
	    echo -e "\nIR image fully dark, probably channel off. Removed."
	else
	    # still does the rectification
	    ${rectify} ${file}_IR.jpg
	    convert ${file}_IR-rectified.jpg ${options} ${file}_IR-rectified.jpg
	    mv ${file}_IR-rectified.jpg ${file}_IR.jpg
	    # move in /deleted
	    mv ${file}_IR.jpg $output/meteor/deleted/
	    echo -e "\nIR image too dark, probably bad quality."
	fi
    fi
else
    echo -e "\nDecoded image not produced."
fi


rm -f ${file}_norm.wav
rm -f ${file}.qpsk
rm -f ${file}.dec
