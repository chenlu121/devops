sfmon@bj1nimbk01:/home/backupfile/nim_create >cat nim_create_master.sh
#!/bin/ksh
#$Header: nim_create_server.sh, v 1.0 2013/12/17 14:00 $
#
#bcopyright
#***********************************************************************
#* $ writen by HYP, 2013
#* NIM backup for old generation  system.
#***********************************************************************
#ecopyright
#
export DIR=/home/backupfile/nim_create
export LOG=$DIR/nim_create.log
export MT_FS=otherfs02
export DATE=$(date +"%Y%m%d%H%M%S")

hosts_check() {
        #针对替换主机，更换IP地址的，请先下线旧主机
        echo "###################################################################"
        echo "### NIM hosts checkup starting  at  $DATE"
        echo
        grep -v "#" $DIR/hosts.txt | grep -v '^$' >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                cat $DIR/hosts.txt | uniq | grep -v "#" | grep -v '^$' | awk '{print $2}' | while read LINE; do
                        IP=$(cat $DIR/hosts.txt | uniq | grep -v "#" | grep -w $LINE | awk '{print $1}')
                        cat /etc/hosts | grep -v "#" | grep -w $LINE >/dev/null 2>&1
                        if [ $? -eq 0 ]; then
                                cat /etc/hosts | grep -v "#" | grep -w $LINE | grep "$IP" >/dev/null 2>&1
                                if [ $? -eq 1 ]; then
                                        echo "Hostname $LINE  have different ip address,please check file:$DIR/hosts.txt"
                                        echo "Please offline the old hostname first:$LINE"
                                else
                                        echo "Hostname $LINE alreadly exits in file: /etc/hosts,please check again!"
                                fi

                        fi
                done
                echo "Hosts checkup completely"
                echo "### NIM  hosts check up ended at $DATE"
                echo
                echo "###################################################################"
        else
                echo " File $DIR/hosts.txt is NULL,hosts will not be modified."
                exit 2
        fi
}

hosts_modify() {

        echo "###################################################################"
        echo "--------NIM server hosts  modified starting at $DATE---------------"
        cp /etc/hosts /etc/hosts.$DATE
        cat $DIR/hosts.txt >>/etc/hosts
        echo "### NIM server hosts  modified end at  $DATE"
        echo "--------NIM server hosts  modified ended at $DATE--------------"

}

add_network() {
        IEEE_ENT=
        while getopts n:t:a:s:c:o:i:g: option; do
                case $option in
                n) NAME=$OPTARG ;;
                t) TYPE=$OPTARG ;;
                a) NETADDR=$OPTARG ;;
                s) SNM=$OPTARG ;;
                g) GATEWAY=$OPTARG ;;
                o) OTHER_NET=$OPTARG ;;
                i) IEEE_ENT=$OPTARG ;;
                c) COMMENTS="$OPTARG" ;;
                esac
        done
        echo $*
        nim -o define -t ${TYPE} -a net_addr=${NETADDR} -a snm=${SNM} ${OTHER_NET:+-a other_net_type1=$OTHER_NET} ${GATEWAY:+-a routing1="default ${GATEWAY}"} ${IEEE_ENT:+ - a ieee_ent=yes} ${COMMENTS:+-a comments="${COMMENTS}"} $NAME
        return $?
}
#add_network -n 'net_192_168_1' -t 'ent' -i '' -a '192.168.1.0' -s '255.255.255.0'

add_route() {
        while getopts o:O:d:D:F: option; do
                case $option in
                o) ORIGIN=$OPTARG ;;
                O) OGATEWAY=$OPTARG ;;
                d) DEST=$OPTARG ;;
                D) DGATEWAY=$OPTARG ;;
                F) FORCE=yes ;;
                esac
        done

        SEQNO=$(lsnim -A routing $ORIGIN)
        nim -o change ${FORCE:+-a force=yes} -a routing$SEQNO="$DEST $OGATEWAY $DGATEWAY" $ORIGIN
        return $?
}
#add_route -o 'net_11_159_79' -O '11.159.79.254' -d 'net_11_155_61' -D '11.155.61.254'

network_define() {
        id | awk '{print $1}' | grep root >/dev/null 2>&1
        if [ $? -ne 0 ]; then
                echo "Please use root to execute!"
                exit 0
        fi
        echo
        echo
        echo "----------NIM install start at $DATE----------------"
        umask 022
        #Check or define  Network Route
        echo "Check and  define network:"
        grep -v "#" $DIR/hosts.txt | grep -v ^$ | awk '{print $1}' | cut -d. -f 1,2,3 | sort -u | while read line; do
                NETWORK=$(echo $line | sed "s/\./_/g")
                lsnim -l net_$NETWORK >/dev/null 2>&1
                if [ $? -ne 0 ]; then
                        IPS=$(echo $NETWORK | sed "s/_/\./g")
                        IPS1=$(echo $IPS".0")
                        add_network -n net_$NETWORK -t ent -i '' -a $IPS1 -s '255.255.255.0' >/dev/null 2>&1
                        if [ $? -ne 0 ]; then
                                echo "network net_$NETWORK add_network failed,Please check again!"
                        else
                                echo "New network define success:net_$NETWORK"

                                add_route -o net_$NETWORK -O $IPS.254 -d net_11_155_61 -D 11.155.61.254 >/dev/null 2>&1
                                DROUTE=$(lsnim -l net_$NETWORK | grep routing | awk '{print $NF}')
                                OROUTE=$(echo $IPS".254")
                                if [ "$DROUTE" = "$OROUTE" ]; then
                                        echo "New route add scccess: $OROUTE"
                                else
                                        echo "network net_$NETWORK add_route failed,Please check again!"
                                        echo
                                fi
                        fi
                else
                        echo "network net_$NETWORK aleadly have define,Skip!"
                fi
        done
}

nim_config() {
        #nim client install,loopup new hostname
        cd /home/backupfile/nim_create
        i=1
        while (($i < 10000)); do
                NUM=$(ls $DIR/tmp | wc -l | awk '{print $NF}')
                if [ $NUM -ne 0 ]; then
                        ls $DIR/tmp | while read NAME; do
                                ALIAS=$(ls $DIR/tmp | grep $NAME | uniq | cut -d . -f1)
                                ENT=$(ls $DIR/tmp | grep $NAME | uniq | cut -d . -f2)
                                GATWAY=$(grep $ALIAS $DIR/hosts.txt | awk '{print $1}' | uniq | awk -F. '{print $1,$2,$3}' | sed "s/ /\_/g")
                                echo
                                echo "Current hostsname           : $ALIAS"
                                echo "Currnet hosts Network Name  : $ENT  "
                                echo "Current hosts's  gatway     : $GATWAY"
                                echo
                                lsnim | grep $ALIAS >/dev/null 2>&1
                                if [ $? -eq 1 ]; then
                                        nim -o define -t standalone -a if1="net_$GATWAY $ALIAS 0 ent$ENT" -a connect=nimsh $ALIAS >/dev/null 2>&1
                                        lsnim -l $ALIAS >/dev/null 2>&1
                                        if [ $? -eq 0 ]; then
                                                sed -e 's/lpbj1nimbk02/'$ALIAS'/g' -e 's/otherfs01/'${MT_FS}'/g' /export/script/standard/define_mksysb.sh >/export/script/mksysb_$ALIAS.sh
                                                chmod 744 /export/script/mksysb_$ALIAS.sh
                                                touch /export/log/$ALIAS.log
                                                chmod 744 /export/log/$ALIAS.log
                                                rm -f $DIR/tmp/$NAME
                                        else
                                                echo "Host $ALIAS define failed"
                                                rm -f $DIR/tmp/$NAME
                                                break
                                        fi
                                else
                                        echo "Host $ALIAS aleadly exist in NIM, skip it "
                                        rm $DIR/tmp/$NAME
                                fi
                        done
                fi
                sleep 10
        done
}

nim_install() {
        echo "the following IP ADDRESS will be added to file:/etc/hosts:"
        cat $DIR/hosts.txt

        while :; do
                echo "Press Y to confirm the info, or Press N to exit the info:"
                read C_temp
                case $C_temp in
                Y)
                        echo "nim install start"
                        break
                        ;;
                N) exit 0 ;;
                *) echo "Input error, please try again" ;;
                esac
        done

        hosts_modify | tee -a $LOG

        network_define | tee -a $LOG
        nim_config | tee -a $LOG

}

echo "----------------------------------------------------------------"
echo "Please update $DIR/hosts.txt, First !"
echo "----------------------------------------------------------------"
while :; do
        echo
        echo "Nim install  selection:"
        echo "1. nim check"
        echo "2. nim install"
        echo "Please input the selection number:"
        read N_DOMAIN
        case $N_DOMAIN in
        1)
                hosts_check
                break
                ;;
        2)
                nim_install
                break
                ;;
        *) echo "Input error, please try again" ;;
        esac
done

hosts_check
hosts_modify | tee -a $LOG

network_define | tee -a $LOG
nim_config | tee -a $LOG
