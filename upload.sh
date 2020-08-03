#!/bin/bash
HOST=ftp.paolofranchini.altervista.org
USER=paolofranchini
PASS=
TARGETFOLDER_NOAA='weather/noaa/'
SOURCEFOLDER_NOAA='/home/franchini/Satellite/code/noaa/'
TARGETFOLDER_METEOR='weather/meteor/'
SOURCEFOLDER_METEOR='/home/franchini/Satellite/code/meteor/'

lftp -f "
set ssl:verify-certificate no
open $HOST
user $USER $PASS

mirror --reverse --delete --verbose -r -I *.png $SOURCEFOLDER_NOAA $TARGETFOLDER_NOAA
mirror --reverse --delete --verbose -r -I *.jpg $SOURCEFOLDER_METEOR $TARGETFOLDER_METEOR
"

#bye

