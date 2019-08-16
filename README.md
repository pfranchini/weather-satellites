# Weather satellites code for Linux

Automatic scheduling and processing for polar weather satellites passages (NOAA, METEOR) in bash scripts.

- Works for APT for NOAA 15, 18, 19
- First working attempts for LRPT METEOR M2 and METEOR M2-2
- Added TLE name/frequency/demod options for upcoming LRPT METEOR M2-2
- List the passages for the current day above a minimum elevation
- Submit jobs on the 'at' queue for each passage
- Each NOOA's job records the audio of the passages (rtl_fm), resample it (sox) and produce VISIBLE and IR pictures with a map overlay (wxtoimg, wxmap)
- Each METEOR's job records the raw data of the passages (rtl_fm), demodulate it (demod), decode (decod) it and produce an RGB picture
- NOAA's passages with audio file too small are not processed (something wrong happened during the recording)
- NOAA's images that trigger some warnings of wxtoimg are moved into a deleted/ folder (usually the visible channel was off or the S/N was too low)
- A recording in progress prevents any other recording scheduled, so there is not a check of eventual overlaps
- A METEOR passage will stop any other running acquisition (that will be normally processed)
- Each time the scheduler starts cleans the 'at' queue and all the running 'rlt_fm' jobs that might be stuck in the system
- Single config file (but still some other hardcoded parameters)
- Tested only on Fedora

Paolo Franchini 2019 - pfranchini@gmail.com

Setup:
=====

Various prerequisites:
---------------------
```
yum install gcc ncurses-devel rtl-sdr sox at git
yum install ImageMagick
(yum install gqrx)

mkdir ~/Satellite
```

Scripts:
-------
```
git clone https://github.com/pfranchini/weather-satellites.git ~/Satellite/code
```

Predict:
-------
```
git clone https://github.com/kd2bd/predict/ ~/Satellite/predict
cd ~/Satellite/predict
su
./configure
echo "alias predict='~/Satellite/predict/predict -q ~/Satellite/code/acton.qth -t ~/Satellite/code/weather.tle'" >> ~/.bashrc
```

APT decoder:
-----------
```
cd ~/Satellite
wget https://wxtoimgrestored.xyz/downloads/wxtoimg-linux64-2.10.11-1.tar.gz
mkdir ~/Satellite/wxtoimg
tar xvf wxtoimg-linux64-2.10.11-1.tar.gz -C ~/Satellite/wxtoimg/
ln -s ~/Satellite/wxtoimg/usr/local/bin/wxtoimg ~/Satellite/wxtoimg/wxtoimg
```
Register WXtoImg as in https://wxtoimgrestored.xyz

LRPT demodulator:
----------------
```
git clone https://github.com/dbdexter-dev/meteor_demod ~/Satellite/meteor_demod
cd ~/Satellite/meteor_demod
make
su
make install
```

LRPT decoder:
------------
```
git clone https://github.com/artlav/meteor_decoder ~/Satellite/meteor_decoder
su
yum install fpc
cd ~/Satellite/meteor_decoder
./build_medet.sh
```

Usage:
=====
```
cd ~/Satellite/code
```
edit config.cfg.
You can manually run the script
```
./schedule.sh
```
or as a cronjob to be run every day early morning, i.e.:

```
01 00 * * * cd ~/Satellite/code; ~/Satellite/code/schedule.sh
```

Logs in: recordings.log, errors.log, jobs.log.

Output images (png files) as speficied in config.cfg.

More:
====
In order to reprocess a bunch of audio files
```
./apt_reprocess.sh <directory_path_where_noaa_audios_are>  
./lrpt_reprocess.sh <directory_path_where_meteor_audios_are>  
```

