#!/bin/bash

######################################################################
#
# Reprocess all the NOAAs audio files (in case of chnges of
# settings in apt.sh)
#
# Usage: ./apt_reprocess.sh <directory_path_where_noaa_audios_are>
#
######################################################################

dir=`pwd`
rm -rf $dir/job

for filename in `ls $1/*.wav | sed -e 's/\..*$//' | grep -v res`; do

    echo "./apt.sh $filename" >> $dir/job

done

cd $dir
bash job
rm job
