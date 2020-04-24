root@bj1recap01:/home/space02/software/nbu/script >cat HPUX_ignite.sh
#!/bin/ksh
#$Header: HPUX_ignite.sh, v 1.0 2013/9/5 20:58 $
#
#bcopyright
#***********************************************************************
#* $ writen by yhb, 2013
#***********************************************************************
#ecopyright
#
#
#-----------------------------------------------------------------------
export DATE=$(date +"%Y%m%d%H%M%S")
export ALIAS=
export IPADDR=
export FS=

bk_flag() {
        echo
        echo "########################################################################"
        echo
}

info() {
        echo
        echo "-------------------------------------------------------------------"
        echo
        echo "$1"
        echo
        echo "-------------------------------------------------------------------"
        echo
}

line() {
        echo "------------------------------------------------"
}

OS_backup() {
        case $OS in
        HP-UX)
                mkdir -p /var/opt/ignite/scripts
                echo "umask 022
export ALIAS=$ALIAS
export FS=$FS
export LOGFILE=/var/opt/ignite/scripts/ignite_\${ALIAS}.log
export RETURN=/var/opt/ignite/scripts/\${ALIAS}.return
(/opt/ignite/bin/make_net_recovery -A -s npbj1ignbk01 -a npbj1ignbk01:/export/\$FS/archives/\$ALIAS -x inc_entire=vg00;echo \$? >\$RETURN)|tee -a \$LOGFILE
RSTAT=\`cat \$RETURN\`
 if [ \$RSTAT -eq 2 ]
        then
                RSTAT=0
        fi
exit \$RSTAT" >/var/opt/ignite/scripts/ignite.sh

                chmod 744 /var/opt/ignite/scripts/*.sh

                IGNITE_OLD_VERSION_LIST=$(swlist | grep -i ignite | awk '{print $1}' | uniq)
                for IGNITE_OLD_VERSION in $IGNITE_OLD_VERSION_LIST; do
                        /usr/sbin/swremove $IGNITE_OLD_VERSION
                done
                RET=$?
                if [ $RET -ne 0 ]; then
                        info "The IGNITE_OLD_VERSION can not be swremoved,please use command "swlist" to check it first"
                        exit 3
                else
                        info "SWREMOVE OF IGNITE_OLD_VERSION complete!"
                fi

                printf "begin install ignite of version 7.11.444"

                /usr/sbin/swinstall -x mount_all_filesystems=false -s npbj1ignbk01:/var/opt/ignite/depots/recovery_cmds "*"

                RET=$?
                if [ $RET -ne 0 ]; then
                        info "The IGNITE with version 7.11.44 can not be swinstalled,please use command "swlist" to check it"
                        exit 3
                else
                        info "SWINSTALL of ignite with version 7.11.444 complete!Check it by yourself"
                        echo $(swlist | grep -i ignite)
                fi
                ;;
        esac
}

export OS=$(uname -s)

echo "Please input the  Client alias:"
echo
read ALIAS
echo

echo "Please input the  Client ip addr:"
echo
read IPADDR
echo

echo "    \n Please choose the filesystem(1 or 2):\n
           1. /export/otherfs01   \n
           2. /export/otherfs02   \n
           \c"
read Choice
case "$Choice" in
1) FS=otherfs01 ;;
2) FS=otherfs02 ;;
*)
        echo "Invalid option"
        exit
        ;;
esac

echo "Edit hosts file"
cp /etc/hosts /etc/hosts.$DATE
echo "### BKMS server $DATE modified start
11.155.61.27 npbj1ignbk01
11.155.61.28 npbj1ignbk02
$IPADDR $ALIAS
### BKMS server $DATE modified end
" >>/etc/hosts

OS_backup
