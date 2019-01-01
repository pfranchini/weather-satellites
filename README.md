# weather-satellites

Automatic scheduling and processing for polar weather satellites passages (NOAA, METEOR) in bash scripts.

- Works for APT for NOAA 15, 18, 19 (and sometime in the future for LRPT METEOR M2)
- List the passages for the current day above a minimum elevation
- Submit jobs on the 'at' queue for each passage
- Each job records the audio of the passages (rtl_fm), resample it (sox) and produce VISIBLE and IR pictures with a map overlay (wxtoimg, wxmap)
- Passages with audio too small are not processed (something wrong happened during the recording)
- Images that trigger some warnings of wxtoimg are moved into a deleted/ folder (usually the visible channel was off or the S/N was too low)
- A recording in progress prevents any other recording scheduled, so there is not a check of eventual overlaps

Paolo Franchini 2019 - pfranchini@gmail.com


Setup:
=====

Various prerequisites:
---------------------
yum install gcc
yum install ncurses-devel
yum install rtl-sdr
yum install sox
yum install ImageMagick
yum install at

mkdir ~/Satellite

Predict:
-------
git clone https://github.com/kd2bd/predict/ ~/Satellite/predict
cd Satellite/predict
su ./configure
echo "alias predict='~/Satellite/predict/predict -q ~/Satellite/code/ravenna.qth -t ~/Satellite/code/weather.tle'" >> ~/.bashrc

Scripts:
-------
git clone https://github.com/pfranchini/weather-satellites.git ~/Satellite/code

APT decoder:
-----------
cd ~/Satellite
wget https://wxtoimgrestored.xyz/downloads/wxtoimg-linux64-2.10.11-1.tar.gz
tar xvf wxtoimg-linux64-2.10.11-1.tar.gz -C wxtoimg/
ln -s usr/local/bin/wxtoimg wxtoimg/wxtoimg
-->register from https://wxtoimgrestored.xyz


Usage:
=====

cd ~/Satellite/code
./schedule.sh

or as a cronjob, i.e.:

01 00 * * * /home/franchini/Satellite/code/schedule.sh

Log in: recordings.log
Output in: ~/Satellite/code/audio/
