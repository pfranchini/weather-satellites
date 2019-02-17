# weather-satellites

Automatic scheduling and processing for polar weather satellites passages (NOAA, METEOR) in bash scripts.

- Works for APT for NOAA 15, 18, 19
- First working attempts for LRPT METEOR M2
- List the passages for the current day above a minimum elevation
- Submit jobs on the 'at' queue for each passage
- Each NOOA's job records the audio of the passages (rtl_fm), resample it (sox) and produce VISIBLE and IR pictures with a map overlay (wxtoimg, wxmap)
- Each METEOR's job records the raw data of the passages (rtl_fm), demodulate it (demod), decode (decod) it and produce an RGB picture
- NOAA's passages with audio file too small are not processed (something wrong happened during the recording)
- NOAA's images that trigger some warnings of wxtoimg are moved into a deleted/ folder (usually the visible channel was off or the S/N was too low)
- A recording in progress prevents any other recording scheduled, so there is not a check of eventual overlaps
- Each time the scheduler starts cleans the 'at' queue and all the running 'rlt_fm' jobs that might be stuck in the system

Paolo Franchini 2019 - pfranchini@gmail.com

Setup:
=====

Various prerequisites:
---------------------
```
yum install gcc
yum install ncurses-devel
yum install rtl-sdr
yum install sox
(yum install ImageMagick)
yum install at

mkdir ~/Satellite
```

Predict:
-------
```
git clone https://github.com/kd2bd/predict/ ~/Satellite/predict
cd Satellite/predict
su ./configure
echo "alias predict='~/Satellite/predict/predict -q ~/Satellite/code/ravenna.qth -t ~/Satellite/code/weather.tle'" >> ~/.bashrc
```

Scripts:
-------
```
git clone https://github.com/pfranchini/weather-satellites.git ~/Satellite/code
```

APT decoder:
-----------
```
cd ~/Satellite
wget https://wxtoimgrestored.xyz/downloads/wxtoimg-linux64-2.10.11-1.tar.gz
tar xvf wxtoimg-linux64-2.10.11-1.tar.gz -C wxtoimg/
ln -s usr/local/bin/wxtoimg wxtoimg/wxtoimg
```
-->register from https://wxtoimgrestored.xyz

LRPT:
----

Usage:
=====
```
cd ~/Satellite/code
```
Edit config.cfg
```
./schedule.sh
```
or as a cronjob to be run every day early morning, i.e.:

```
01 00 * * * ~/Satellite/code/schedule.sh
```

Logs in: recordings.log, errors.log, jobs.log
Output as speficied in config.cfg




