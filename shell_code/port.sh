echo "1. Unzip all PFM data and move to diff DIR"

mkdir IOPS KBPS IKBPS

ls -l |grep Port |awk '{print $9}'  > list.txt

for i in `cat list.txt`
do
unzip $i



DATAS=`date +%s`


cp Port_dat/Port_IOPS.csv                ./IOPS/$i.IOPS.csv
cp Port_dat/Port_KBPS.csv                ./KBPS/$i.KBPS.csv
cp Port_dat/Port_Initiator_KBPS.csv                ./IKBPS/$i.IKBPS.csv

rm -rf Port_dat

done

echo "2. Process the IOPS of port"
cd IOPS 

dos2unix *.csv

if [ `head -6 *.csv | grep -i from | wc -l` -gt 0 ]
     then
      sed -i '1,6d' *.csv
fi

ls -l |grep IOPS |awk '{print $9}'|awk -F"-" '{print $1}' |sort|uniq >mculist.txt


for j in `cat mculist.txt`
do

echo "###$j ---connect the PFM files"
cat $j* >total.$j
rm  -rf $j*


echo "###$j ---delete No. and sort by time"
awk -F"," -v OFS="," '{$1="";print $0}' total.$j >total.$j.temp1
sed "s/time/0time/g" total.$j.temp1 >total.$j.temp2
sort -t "," -k1n total.$j.temp2 |uniq >total.$j.temp3

echo "###$j ---split time row and data row"
cut -d"," -f2 total.$j.temp3  >time.out
cut -d"," -f3- total.$j.temp3 >total.$j.temp4

echo "###$j ---split JNL-ID line and add MCU Serial_No."
head -1 total.$j.temp4 | sed 's/\"//g' >total.$j.temp5
awk -F","  -v OFS="," 'NR==1{for(i=1;i<=NF;i++) $i=""'"$j"'"-"$i}{print}' total.$j.temp5 >total.$j.temp6
sed -i  "1,1d"     total.$j.temp4         
sed  -i "s/-4/0/g" total.$j.temp4 

echo "###$j ---rebuild JNL-ID and PFM data" 
cat total.$j.temp6 total.$j.temp4    >total.$j

echo "###$j ---complete and clean"
rm -rf total.$j.temp*






done



paste -d"," time.out total.* > ../IOPS.total.csv

cd ..

rm -rf IOPS



echo "3. Process the KBPS of port"
cd KBPS

dos2unix *.csv

if [ `head -6 *.csv | grep -i from | wc -l` -gt 0 ]
     then
      sed -i '1,6d' *.csv
fi

ls -l |grep KBPS |awk '{print $9}'|awk -F"-" '{print $1}' |sort|uniq >mculist.txt


for j in `cat mculist.txt`
do

echo "###$j ---connect the PFM files"
cat $j* >total.$j
rm  -rf $j*


echo "###$j ---delete No. and sort by time"
awk -F"," -v OFS="," '{$1="";print $0}' total.$j >total.$j.temp1
sed "s/time/0time/g" total.$j.temp1 >total.$j.temp2
sort -t "," -k1n total.$j.temp2 |uniq >total.$j.temp3

echo "###$j ---split time row and data row"
cut -d"," -f2 total.$j.temp3  >time.out
cut -d"," -f3- total.$j.temp3 >total.$j.temp4

echo "###$j ---split JNL-ID line and add MCU Serial_No."
head -1 total.$j.temp4 | sed 's/\"//g' >total.$j.temp5
awk -F","  -v OFS="," 'NR==1{for(i=1;i<=NF;i++) $i=""'"$j"'"-"$i}{print}' total.$j.temp5 >total.$j.temp6
sed -i  "1,1d"     total.$j.temp4
sed  -i "s/-4/0/g" total.$j.temp4

echo "###$j ---rebuild JNL-ID and PFM data"
cat total.$j.temp6 total.$j.temp4    >total.$j

echo "###$j ---complete and clean"
rm -rf total.$j.temp*


done



paste -d"," time.out total.* > ../KBPS.total.csv

cd ..

rm -rf KBPS


echo "4. Process the KBPS of Initiator port"

cd IKBPS

dos2unix *.csv

if [ `head -6 *.csv | grep -i from | wc -l` -gt 0 ]
     then
      sed -i '1,6d' *.csv
fi

ls -l |grep IKBPS |awk '{print $9}'|awk -F"-" '{print $1}' |sort|uniq >mculist.txt


for j in `cat mculist.txt`
do

echo "###$j ---connect the PFM files"
cat $j* >total.$j
rm  -rf $j*


echo "###$j ---delete No. and sort by time"
awk -F"," -v OFS="," '{$1="";print $0}' total.$j >total.$j.temp1
sed "s/time/0time/g" total.$j.temp1 >total.$j.temp2
sort -t "," -k1n total.$j.temp2 |uniq >total.$j.temp3

echo "###$j ---split time row and data row"
cut -d"," -f2 total.$j.temp3  >time.out
cut -d"," -f3- total.$j.temp3 >total.$j.temp4

echo "###$j ---split JNL-ID line and add MCU Serial_No."
head -1 total.$j.temp4 | sed 's/\"//g' >total.$j.temp5
awk -F","  -v OFS="," 'NR==1{for(i=1;i<=NF;i++) $i=""'"$j"'"-"$i}{print}' total.$j.temp5 >total.$j.temp6
sed -i  "1,1d"     total.$j.temp4
sed  -i "s/-4/0/g" total.$j.temp4

echo "###$j ---rebuild JNL-ID and PFM data"
cat total.$j.temp6 total.$j.temp4    >total.$j

echo "###$j ---complete and clean"
rm -rf total.$j.temp*


done



paste -d"," time.out total.* > ../IKBPS.total.csv

cd ..

rm -rf IKBPS

