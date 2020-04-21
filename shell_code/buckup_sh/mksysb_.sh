sfmon@bj1nimbk01:/export/script> cat mksysb_.sh 
export CLIENT=
export SERVER=master
export FS=
export TMPFILE=/export/log/return/${CLIENT}.tmp
export LOGFILE=/export/log/${CLIENT}.log
export RETURN=/export/log/return/${CLIENT}.RETURN
lsnim -t mksysb|grep $CLIENT|awk '{print $1}'|awk 'BEGIN{FS="_"} {print $NF}' >$TMPFILE
if [ `cat $TMPFILE|wc -l` -ge 2 ] 
then
        ODATE=`date +"%Y%m%d%H%M%S"`
        for i in `cat $TMPFILE`
                do 
                if [ $ODATE -gt $i ]
                then 
                        ODATE=$i
                fi
                done
        nim -o remove mksysb_${CLIENT}_$ODATE
        rm /export/$FS/mksysb_${CLIENT}_$ODATE
fi
export DATE=`date +"%Y%m%d%H%M%S"`
echo "================$CLIENT SYSTEM BACKUP BIGIN at `date`==============" |tee -a $LOGFILE 
(nim -Fo define -t mksysb -a mksysb_flags=p -a server=$SERVER -a source=$CLIENT -a mk_image=yes -a location=/export/$FS/mksysb_${CLIENT}_$DATE  mksysb_${CLIENT}_$DATE;echo $? >$RETURN)|tee -a $LOGFILE

MK_RETURN=`cat $RETURN`
if [ $MK_RETURN -eq 0 ]
then 
        MK_RESULT=successfully
else
        MK_RESULT=failed
fi

echo "================$CLIENT SYSTEM BACKUP End  ${MK_RESULT}  at `date`==============" |tee -a $LOGFILE
exit $MK_RETURN
sfmon@bj1nimbk01:/export/script> cat  mksysb_lptcn2.sh
export CLIENT=lptcn2
export SERVER=master
export FS=otherfs02
export TMPFILE=/export/log/return/${CLIENT}.tmp
export LOGFILE=/export/log/${CLIENT}.log
export RETURN=/export/log/return/${CLIENT}.RETURN
lsnim -t mksysb|grep $CLIENT|awk '{print $1}'|awk 'BEGIN{FS="_"} {print $NF}' >$TMPFILE
if [ `cat $TMPFILE|wc -l` -ge 2 ] 
then
        ODATE=`date +"%Y%m%d%H%M%S"`
        for i in `cat $TMPFILE`
                do 
                if [ $ODATE -gt $i ]
                then 
                        ODATE=$i
                fi
                done
        nim -o remove mksysb_${CLIENT}_$ODATE
        rm /export/$FS/mksysb_${CLIENT}_$ODATE
fi
export DATE=`date +"%Y%m%d%H%M%S"`
echo "================$CLIENT SYSTEM BACKUP BIGIN at `date`==============" |tee -a $LOGFILE 
(nim -Fo define -t mksysb -a server=$SERVER -a source=$CLIENT -a mk_image=yes -a location=/export/$FS/mksysb_${CLIENT}_$DATE  mksysb_${CLIENT}_$DATE;echo $? >$RETURN)|tee -a $LOGFILE

MK_RETURN=`cat $RETURN`
if [ $MK_RETURN -eq 0 ]
then 
        MK_RESULT=successfully
else
        MK_RESULT=failed
fi

echo "================$CLIENT SYSTEM BACKUP End  ${MK_RESULT}  at `date`==============" |tee -a $LOGFILE
exit $MK_RETURN