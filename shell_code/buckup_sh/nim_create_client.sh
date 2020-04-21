sfmon@bj1recap01:/home/space02/software/nbu/script/nim_create> cat nim_create_client.sh
#!/bin/ksh
#$Header: nim_create_client.sh, v 1.0 2013/12/23 14:00 $
#
#bcopyright
#***********************************************************************
#* $ writen by HYP, 2013
#* NIM backup for old generation  system.
#***********************************************************************
#***********************************************************************
#* $ AIX OS backup on cloudy platform，running on nim client
#* $ usage : sh nim_create_client.sh MGTADDR  CLIENT
#***********************************************************************
#ecopyright
#
export script_dir=/mnt/mnt5/nbu/script/nim_create
export HOSTNAME=`hostname`
export LOG=/tmp/nim_create_$HOSTNAME.log
export DATE=`date +"%Y%m%d%H%M%S"`
export IPADD=$1
export ALIAS=$2
#export ALIAS=$(echo $2 |tr "[:upper:]" "[:lower:]"|sed -e 's/_//g')

hosts_modify()
{
cp  /etc/hosts  /etc/hosts.$DATE
echo "### NIM server $DATE modified start
#NIM Server
11.155.61.25   lpbj1nimbk01
11.155.61.26   lpbj1nimbk02
$IPADD $ALIAS
### NIM server $DATE modified end
" >> /etc/hosts
}

nim_install()
{

niminit -a master=lpbj1nimbk01 -a name=$ALIAS  -a connect=nimsh  >/dev/null 2>&1
NIMSH=`lssrc -s nimsh | grep nimsh | awk '{print $NF}'`
echo
echo "NIMSH status is $NIMSH"
echo
if [ "$NIMSH" == "active" ]
        then
        echo "*******************************************"
        echo
        echo "/etc/niminfo  configration list as follows:"
        cat /etc/niminfo  | grep NIM_NAME            | awk '{print $2}'
        cat /etc/niminfo  | grep NIM_HOSTNAME        | awk '{print $2}'
        cat /etc/niminfo  | grep NIM_MASTER_HOSTNAME | awk '{print $2}'
        echo
        echo "********************************************"
        else
        echo " Client $ALIAS nimsh status is not active,Please recheck!"
        exit $EXIT
fi


}

echo "---------Nim client install start---------------"
umask 022
touch /tmp/nim_create_$HOSTNAME.log
chmod 744 /tmp/nim_create_$HOSTNAME.log




    NET=$(netstat -in | grep "$IPADD"   | awk  '{print $1}' |cut -c 3-4)
default=$(netstat -rn | grep "default"  | awk  '{print $2}')
  ipadd=$(netstat -in | grep "$IPADD"   | awk  '{print $4}')


echo  "Clinet information confirms:"
echo
echo "NIM_CLIENT_ALIAS       :         $ALIAS"
echo "NIM_CLIENT_IP          :         $ipadd"
echo "NIM_client_NET         :         $NET"
echo "DEFAULT_ROUTE          :         $default"

cd /tmp
rm -f /tmp/$ALIAS.$NET
echo 1>/tmp/$ALIAS.$NET

if [ -f "/tmp/$ALIAS.$NET" ]
 then
ftp -n  <<!
open 11.155.61.25
user nimftp nimftp
bin
cd  /home/backupfile/nim_create/tmp
put  $ALIAS.$NET
close
by

!
fi

sleep 20

ls -al /etc/niminfo >/dev/null  2>&1
        if [ $? -eq 0 ]
        then
        stopsrc -s nimsh  >/dev/null 2>&1
        mv /etc/niminfo /etc/niminfo.bak
              hosts_modify  | tee -a  $LOG
              nim_install   | tee -a  $LOG
        else
              hosts_modify  | tee -a  $LOG
              nim_install   | tee -a  $LOG
        fi

