
cd audio
for filename in `ls *.wav | sed -e 's/\..*$//' | grep -v res`; do

    echo "./apt.sh $filename" >> ../job

done

cd ..
bash job
rm job
