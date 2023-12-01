# Weather satellites code for Linux

Automatic scheduling and processing for polar weather satellites passages (NOAA, METEOR) in bash scripts using third party software.

- Works for APT of NOAA 15, 18, 19
- Works for LRPT of METEORs
- Added METEOR-M2 3
- (First working attempts for LRPT METEOR M2-2 (added TLE name/frequency/demod options) - satellite not available)

- List the passages for the current day above a minimum elevation using Predict
- Submit jobs on the linux 'at' queue for each passage
- Each NOOA's job records the audio of the passages (rtl_fm), resamples it (sox) and produces, if possible several VISIBLE and IR pictures with a map overlay (wxtoimg, wxmap)
- Each METEOR's job records the raw data of the passages (rtl_fm), demodulates it (demod), decodes (decode) it and produces a composite VISIBLE and IR pictures
- NOAA's passages with audio file too small are not processed (something wrong happened during the recording)
- NOAA's images that trigger some warnings of wxtoimg are moved into a deleted/ folder (usually the S/N was too low)
- NOAA's visible images are produced only if the visible channel is active, otherwise only the combined IR is produced
- METEOR's IR image is produced together with the composite one if both channels are active
- METEOR's images with low brightness are moved into the deleted/ folder (usually was a bad acquisition or late evening)
- A recording in progress prevents any other recording scheduled, so there is not a check of eventual overlaps
- A METEOR passage will stop any other running acquisition (that will be normally processed)
- Each time the scheduler starts cleans the 'at' queue and all the running 'rlt_fm' jobs that might be stuck in the system
- Single config file (but still some other hardcoded parameters for the recordings) with minimal sets of checks of it
- Rectify implemented for METEOR's images
- Included script to produce an animation from Mercator projections
- Tested on Fedora and on Raspberry Pi

Paolo Franchini 2022 - pfranchini@gmail.com

Setup:
=====

Various prerequisites:
---------------------
Create a directory for the scripts and for the output images in your home directory:
```
mkdir ~/Satellite
```
Install the followings as superuser. For Fedora-like
```
yum install gcc ncurses-devel rtl-sdr sox at bc git make cmake
yum install ImageMagick
yum install fpc
yum install libjpeg*
(yum install gqrx)
(yum install ffmpeg)
```
or for Ubuntu-like distos (e.g. Raspberry Pi OS):
```
apt install gcc libncurses5-dev rtl-sdr sox at bc git make cmake
apt install imagemagick
apt install fpc
apt install libjpeg-dev
(apt install gqrx-sdr)
(apt install ffmpeg)
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
sudo ./configure
(echo "alias predict='~/Satellite/predict/predict -q ~/Satellite/code/<location>.qth -t ~/Satellite/code/weather.tle'" >> ~/.bashrc)
```

APT decoder:
-----------
```
cd ~/Satellite
wget https://wxtoimgrestored.xyz/downloads-src/wxtoimg-linux64-2.10.11-1.tar.gz
mkdir ~/Satellite/wxtoimg
tar xvf wxtoimg-linux64-2.10.11-1.tar.gz -C ~/Satellite/wxtoimg/
ln -s ~/Satellite/wxtoimg/usr/local/bin/wxtoimg ~/Satellite/wxtoimg/wxtoimg
```
or for Raspberry Pi
```
wget https://wxtoimgrestored.xyz/beta/wxtoimg-armhf-2.11.2-beta.deb
sudo apt install ./wxtoimg-armhf-2.11.2-beta.deb
```
Register WXtoImg as in https://wxtoimgrestored.xyz/downloads

Update TLE/Keplers:
```
wget -O ~/Satellite/wxtoimg/usr/local/lib/wx/tle/weather.txt http://celestrak.org/NORAD/elements/weather.txt
```
or
```
sudo wget -O /usr/local/lib/wx/tle/weather.txt http://celestrak.org/NORAD/elements/weather.txt
```



LRPT demodulator:
----------------
```
git clone https://github.com/dbdexter-dev/meteor_demod ~/Satellite/meteor_demod
cd ~/Satellite/meteor_demod
make
sudo make install
```

LRPT decoder:
------------
```
git clone https://github.com/artlav/meteor_decoder ~/Satellite/meteor_decoder
cd ~/Satellite/meteor_decoder
source build_medet.sh
```

Rectify:
-------
```
cd ~/Satellite/
wget http://www.5b4az.org/pkg/lrpt/rectify-jpg-0.3.tar.bz2
tar xvf rectify-jpg-0.3.tar.bz2
cd rectify-jpeg-0.3
gcc rectify-jpg.c -lm -ljpeg -o rectify-jpg
```


Usage:
=====
```
cd ~/Satellite/code
```
create your own location file `.qth` and edit `config.cfg` with all the paths and other options.
Now you can manually run the script
```
./schedule.sh
```
or as a cronjob to be run every day early morning, i.e. (the `cd` is mandatory):
```
01 00 * * * cd ~/Satellite/code; ~/Satellite/code/schedule.sh
```

Logs in: `recordings.log`, `errors.log`, `jobs.log`.

Output images (png and jpg files) as speficied in `config.cfg`.

More:
====
In order to reprocess a bunch of existing audio files
```
./apt_reprocess.sh <directory_path_where_noaa_audios_are>  
./lrpt_reprocess.sh <directory_path_where_meteor_audios_are>  
```
it would preserve the original time stamp of the wave file.

Animation (beta version):
========================
In order to create a MP4 video using Mercator projections for a cropped IR passage (the coordinates are hard coded)
```
./video.sh <list_of_files.wav>
```
e.g.
```
./video.sh noaa/20200711-*.wav noaa/20200712-*.wav
```
