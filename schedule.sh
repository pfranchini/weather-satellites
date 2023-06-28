#!/bin/bash

####################
source config.cfg
####################

cd $dir

# Check the config.cfg file
if [ ! -f $where ]; then
    echo "Location file does not exist. Check config.cfg"
fi
if [ ! -d $dir ]; then
    echo "Wrong code directory. Check config.cfg"
fi
if [ ! -f $predict ]; then
    echo "predict wrong path. Check config.cfg"
fi
if [ ! -f $demod ]; then
    echo "Meteor demodulator wrong path. Check config.cfg"
fi
if [ ! -f $decoder ]; then
    echo "Meteor decoder wrong path. Check config.cfg"
fi
if [ ! -d $wxdir ]; then
    echo "WxToImg wrong path. Check config.cfg"
fi
which rtl_fm > /dev/null
if [ "$?" -ne "0" ]; then
    echo "rtl_fm is not present"
fi

rm -fr passages.*

# Update Satellites Information
echo -e "\nUpdate satellites information..."
wget -qr https://www.celestrak.com/NORAD/elements/weather.txt -O weather.txt
if [ "$?" -eq "0" ]; then
    grep "NOAA 15" weather.txt -A 2 > weather.tle
    grep "NOAA 18" weather.txt -A 2 >> weather.tle
    grep "NOAA 19" weather.txt -A 2 >> weather.tle
    grep "METEOR-M 2" weather.txt -A 2 >> weather.tle
    grep "METEOR-M2 2" weather.txt -A 2 >> weather.tle
    grep "METEOR-M2 3" weather.txt -A 2 >> weather.tle
    echo "...done"
else
    echo "...no network"
fi
rm -rf weather.txt

echo -e "\nLocation:" `head -n1 $where`
echo -e "\nSatellites: ${SATELLITES[@]}"
echo -e "\nMinimum elevation:" $min_el

today=`date +'%Y%m%d'`

for sat in "${SATELLITES[@]}"; do

    time=`date +%s`

    while [ `date -d @$time +%Y%m%d` -eq "$today" ]; do

	max_el=0
	max_el=`$predict -q $where -t weather.tle -p "${sat}" "$time" | awk '{if($5>max){max=$5}}END{print max}'`
	if [[ -n "$max_el" ]] && [[ "$max_el" -gt "$min_el" ]]; then

	    # Acquisition of Signal - Lost of Signal
	    AOS=`$predict -q $where -t weather.tle -p "${sat}" "$time" | head -1 | awk '{print $1 " " $3 " " $4}'`
	    LOS=`$predict -q $where -t weather.tle -p "${sat}" "$time" | tail -1 | awk '{print $1 " " $3 " " $4}'`

	    # Day of the passage
	    day=`$predict -q $where -t weather.tle -p "${sat}" "$time" | head -1 | awk '{print $1}'`

	    # saves only the passages in the current day
	    if [ `date --date=@${day} +%Y%m%d` -eq "$today" ]; then
		echo -e $AOS " " $LOS " " $sat "\t" $max_el >> passages.tmp
	    fi

	fi

	end_time=`$predict -q $where -t weather.tle -p "${sat}" "$time" | tail -1 | awk '{print $1}'`

	time=$[$end_time+60]

    done

done

if [ -f passages.tmp ]; then

    echo -e "\nStart              Stop               Satellite   Max El"
    echo    "========================================================="

    sort passages.tmp | uniq > passages.txt
    rm passages.tmp

    # Kill any 'rtl_fm' that might be still running (any midnight passage??)
    pkill -9 rtl_fm

    # Remove old 'at' jobs
    for i in `atq | awk '{print $1}'`; do atrm $i; done

    # Submit new jobs
    while read line; do

	echo "$line" | awk '{print $2 " " $3 "   " $5 " " $6 "   " $7 "" $8 "\t  " $9}'

	# pass the unix time
	sat=`echo $line | awk '{print $7 " " $8}'`
	start=`echo $line | awk '{print $1}'`
	stop=`echo $line | awk '{print $4}'`
	elevation=`echo $line | awk '{print $9}'`

	source submit_job.sh $sat $start $stop $elevation

    done < passages.txt

    less recordings.log | sort | uniq > recordings.tmp
    mv recordings.tmp recordings.log

    echo -e "\n--------------------\n" >> passages.txt
    cat ${where} >> passages.txt
    df -h ${dir} >> passages.txt

    echo -e "\nJobs queued:" `atq | wc -l` "\n"

else
    echo -e "\nNo passages for today"
fi

echo " "

