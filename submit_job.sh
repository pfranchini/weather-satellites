#!/bin/bash

sat="$1$2"
start=$3
stop=$4
specie=$1
elevation=$5

filename=`date --date=@${start} +%Y%m%d-%H%M%S`_${sat}
rectime=$[$stop-$start]
at_start=`date --date=@${start} +%H:%M`

if [ "$sat" == "NOAA15" ]; then
   #frequency=137.620
    frequency=137.614
    sampling=60
fi
if [ "$sat"  == "NOAA18" ]; then
   #frequency=137.9125
    frequency=137.906
    sampling=60
fi
if [ "$sat" == "NOAA19" ]; then
   #frequency=137.100
    frequency=137.092
    sampling=60
fi
if [ "$sat" == "METEOR-M2" ]; then
    frequency=137.900 
fi

# Logging:
echo `date --date=@${start} +%Y%m%d-%H%M%S` $sat $elevation>> recordings.log

# -s it the bandwidth

# Submit satellite:
if [ "$specie" == "NOAA" ]; then
    # Record: (-p 0.0, 55.0 ppm ????)
    echo "timeout $rectime rtl_fm  -f ${frequency}M -s ${sampling}k  -g 45 -p 0.0 -E wav -E deemp -F 9 - | sox -t raw -e signed -c 1 -b 16 -r ${sampling}k - audio/${filename}.wav"  > job.txt 
    #echo "timeout $rectime rtl_fm  -f ${frequency}M -s 60k  -g 45 -E wav - | sox -t raw -e signed -c 1 -b 16 -r 60k - ${filename}.wav" # > job.txt
    #echo "timeout $rectime rtl_fm  -f ${frequency}M -s 60k  -g 45 -p 55 -E wav -E deemp -F 9 - | sox -t raw - ${filename}.wav rate 11025" # > job.txt

    # Resample and Decode:
    echo "/bin/bash apt.sh ${filename}" >> job.txt

    # Submission:
    at $at_start -f job.txt
    rm job.txt



fi

if [ "$specie" == "METEOR-M" ]; then
    # Record:
    echo "timeout $rectime rtl_sdr -f ${frequency}M -s 140k -g 28 -d 0 -p 1 -b 8 audio/${filename}.bin"  > job.txt 
    at $at_start -f job.txt  
    rm job.txt
    
    # Demodulate:
    #/home/franchini/Satellite/METEOR/meteor_demod/meteor_demod -q -s 140000 -o ${filename}.wav ${filename}.bin
    
    # Decode:
    #/home/franchini/Satellite/METEOR/meteor_decoder/medet ${filename}.wav ${filename}.png


    # rtl_fm -M raw -s 140000 -f 137.9M -E dc -g <gain> -p <ppm> 
    # rtl_fm -f 137.9M -s 140k -M raw -g <gain> -p <ppm> <output .wav file    
fi





    
