###此脚本用于批量处理export导出的数据，解决数据量太大导致peex溢出的问题。
###将脚本与需要处理的csv文件放在同一个文件夹中，执行即可。执行的结果会自动生成一个文件夹report_$date下，并创建一个软链接report方便进入。每个文件的处理结果有两个文件，out.$FILE_NAME和out.sum.$FILE_NAME，第一个是所有LUN的数据，第二个是所有LUN的求和数据。
###请注意，每次执行时，会将当前文件夹中的tmp_*和out_*清空。
###SUSPECT是要抓取的信息比如hostgroup组或ldev号，支持一次查询多个条件，匹配使用egrep -i，所以大小写不敏感。不需要使用通配符，你可以把CL3-A*简单的写成CL3-A即可，你也可以按照正则表达式去书写条件，比如：
###SUSPECT="CL3-A.03|CL3-A.04" 
###FILE_NAME是要处理的性能数据文件，规则与SUSPECT相同，可以一次指定多个文件，脚本执行的第一步会把符合条件的文件都列出来。
###FILE_NAME="LU_IOPS|LU_Write_|LU_Response"


ulimit -n 81920

SUSPECT="CL"$1
FILE_NAME="LU_"

DATE=`date "+%Y%m%d_%H%M%S"`

if [ `ls -l out*  2>/dev/null |wc -l ` -gt 0 ]
  then
   rm out*  2>/dev/null
  fi


if [ `ls -l tmp*  2>/dev/null |wc -l ` -gt 0 ]
  then
   rm tmp* 2>/dev/null
fi

  ls -l |egrep -i $FILE_NAME |awk '{print $9}' >list_file_name

  echo "We will process the files as below:"
  cat list_file_name





for FILE in `strings list_file_name`
  do

   echo -e "\n##########################$FILE start!!##############################"
   echo "1. $FILE start to process!"


   dos2unix $FILE  2>/dev/null

   LINE_NUM=`grep -v "No." $FILE |awk -F'"' '{print $2}'|awk  'NR==1{max=$1;next}{max=max>$1?max:$1}END{print max}' `
   LINE_NUM=$[LINE_NUM+1]



   if [ `head -6 $FILE | grep -i csv | wc -l` -gt 0 ]
     then
      sed -i '1,6d' $FILE
   fi

   echo "2. $FILE Cross-cut to small files with $LINE_NUM lines!"

   split -l $LINE_NUM $FILE -d -a 5 tmp_line_

   echo "3. $FILE Vertical-cut to small files with single row!"

   if [ `ls -l tmp_line_* | wc -l ` -gt 1 ]
   then
   egrep -i $SUSPECT tmp_line_*|awk -F":" '{print $1}' >list_tmp_line
   else
   ls -l tmp_line_* | awk '{print $9}' >list_tmp_line
   fi

   for TMP_LINE in `strings list_tmp_line`
     do
      awk  -F","   '{for(i=1;i<=NF;i++) print $i > "tmp_row_""'"$TMP_LINE"'""_"i}' $TMP_LINE
     done

   rm tmp_line_*
   rm list_tmp_line

   echo "4. $FILE reform for $SUSPECT "





   for NUM in 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F
   
   do
   SUSPECT_NUM="$SUSPECT.$NUM"
   mkdir $SUSPECT_NUM
   
   if [ -f out.time ]
   then
      echo ""      
   else
      egrep -i time tmp_row_* |head -1|awk -F":" '{print "mv ",$1,"out.time"}' >list_tmp_row_$SUSPECT_NUM.sh
   fi
   

   egrep -i $SUSPECT_NUM tmp_row_*|awk -F":" '{print "mv ",$1,"'"$SUSPECT_NUM"'""/"}'      >>list_tmp_row_$SUSPECT_NUM.sh



   sh list_tmp_row_$SUSPECT_NUM.sh
   rm list_tmp_row_$SUSPECT_NUM.sh
   
   




   if [ `ls -l ./$SUSPECT_NUM/ |wc -l ` -gt 1 ]
     then
     SUSPECT_NAME=` egrep -i $SUSPECT_NUM ./$SUSPECT_NUM/* | head -1 | awk -F'"' '{print $2}' | cut -d"." -f 1-2 `     
     echo $SUSPECT_NAME
      paste -d"," ./$SUSPECT_NUM/tmp_row* >out.pre
      sed -i "s/-4/0/g" out.pre
      awk -F"," '{for (i=1; i<= NF; i++)  sum += $i; print sum; sum=0;}' out.pre >out.sum.pre.1
      awk 'NR==1{$1="'"$SUSPECT_NAME"'"}{print}' out.sum.pre.1 >out.sum.pre.2

      paste -d"," out.time out.pre >of.$FILE.$SUSPECT_NUM.csv 

   if [ -f out.sum.$FILE.$SUSPECT ]
     then
      mv out.sum.$FILE.$SUSPECT out.sum.pre.3
      paste -d","  out.sum.pre.3 out.sum.pre.2 >out.sum.$FILE.$SUSPECT
     else
      mv out.sum.pre.2 out.sum.$FILE.$SUSPECT 
   fi


     else
      echo "$SUSPECT_NUM not found in $FILE"
   fi
   
      
      

   

   
   rm -rf $SUSPECT_NUM
   rm -rf out.pre 
   rm -rf out.sum.pre.1 
   rm -rf out.sum.pre.2 
   rm -rf out.sum.pre.3 



   done
   
   rm tmp_row_*

   paste -d"," out.time out.sum.$FILE.$SUSPECT >of.SUM.$FILE.$SUSPECT.csv 
   
   rm -rf out.time
   rm -rf out.sum.$FILE.$SUSPECT
   
   
   echo "5. $FILE reformed and you can collect the output file --out.$FILE and out.sum.$FILE"

   if [ -x report_$DATE ]
     then
      mv of* report_$DATE
     else
      mkdir report_$DATE
      mv of* report_$DATE

      if [ -x report ]
       then
         rm report
         ln -s report_$DATE report
       else
         ln -s report_$DATE report
      fi

    fi

    echo "##########################$FILE completed!!###########################"

  done

rm list_file_name

echo -e "\n####All files completed!You can find the output files in report_$DATE#######"

