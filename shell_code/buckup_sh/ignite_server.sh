sfmon@bj1ignbk01:/var/opt/ignite/scripts>cat ignite_server.sh
#!/usr/bin/sh  
export DATE=`date +"%Y%m%d%H%M%S"`
export FS=
DIRNAME=`dirname $0`
Logfile=$DIRNAME/log/Ignite_server.$DATE.log
umask 022

if [ ! -r $DIRNAME/host_list.txt ] ;then
        echo "The host_list.txt does not exist!"|tee -a $Logfile
        exit 1
fi

Avail1=`bdf|grep "otherfs01"|awk '{print $3}'`
Used1=`bdf|grep "otherfs01"|awk '{print $4}'`
Avail2=`bdf|grep "otherfs02"|awk '{print $3}'`
Used2=`bdf|grep "otherfs02"|awk '{print $4}'`

echo "    \n Please choose the filesystem(1 or 2):\n
           1. /export/otherfs01   available:$Avail1 Kb   used:$Used1\n
           2. /export/otherfs02   available:$Avail2 Kb   used:$Used2\n
           \c"
read Choice
case "$Choice" in
   1) FS=otherfs01 ;;
   2) FS=otherfs02 ;;
   *) echo "Invalid option"; exit 
esac

Num=`cat $DIRNAME/host_list.txt|grep -v '^#'|grep -v '^$'|wc -l`
if [ $Num -ne 0 ] ;then
        /usr/bin/cp /etc/hosts /etc/hosts.$DATE && echo "The /etc/hosts has already saved ! Time stamp is $DATE"|tee -a $Logfile
        /usr/bin/cp /etc/dfs/dfstab /etc/dfs/dfstab.$DATE && echo "The /etc/dfs/dfstab has already saved ! Time stamp is $DATE"|tee -a $Logfile
        echo "\n#Ignite server hosts  modified start $DATE">>/etc/hosts
        cat $DIRNAME/host_list.txt|grep -v '^$'|uniq|while  read Line
        do
            echo $Line|grep '^#'>/dev/null 2>&1
            if [ $? -eq 0 ] ;then
                echo "$Line">>/etc/hosts
                continue
            fi

            Hostname=`echo $Line|awk '{print $2}'` 
            cat /etc/hosts|grep -v '^#'|grep -w $Hostname >/dev/null 2>&1
            if [ $? -ne 0 ] ;then
                echo "$Line">>/etc/hosts && echo "$Line added to /etc/hosts "|tee -a $Logfile
                /usr/bin/mkdir -p /export/$FS/archives/$Hostname
                /usr/bin/chown bin:bin /export/$FS/archives/$Hostname
                echo "share -F nfs -o sec=sys,anon=2,rw=$Hostname /export/$FS/archives/$Hostname">>/etc/dfs/dfstab
                echo "$Hostname dir has already added to dfstab"|tee -a $Logfile
            else
                echo "$Line does not added ,please check the /etc/hosts and host_list file!"|tee -a $Logfile
           fi 
        done
        echo "#Ignite server hosts  modified end $DATE">>/etc/hosts 
        /usr/sbin/shareall -F nfs
        /usr/sbin/showmount -e |tee -a $Logfile 
        >$DIRNAME/host_list.txt
else
        echo "No ip address added, please check host_list file!"|tee -a $Logfile
fi
