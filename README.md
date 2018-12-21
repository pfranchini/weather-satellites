# weather-satellites

Weather satellites (NOAA, METEOR) scripts.

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
