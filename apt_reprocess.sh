##################
#
# Usage: ./apt_reprocess.sh <directory_path_where_nooa_audios_are>
#
##################

dir=`pwd`
rm -rf $dir/job

for filename in `ls $1/*.wav | sed -e 's/\..*$//' | grep -v res`; do

    echo "./apt.sh $filename" >> $dir/job

done

cd $dir
bash job
rm job
