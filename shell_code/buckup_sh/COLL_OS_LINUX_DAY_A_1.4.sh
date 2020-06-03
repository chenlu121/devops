donesfmon@bj1emc01:/home/ap/opscloud/bin/COLL_OS_LINUX_DAY_A_1.4/linux>cat COLL_config_linux.sh
#!/bin/ksh
################Script Note########################
#FileName:COLL_config_linux.sh
#Function:System Information Collect   
################Version Definition####################
VERSION="1.0"                       #version
MODIFIED_TIME="20190412"            #modify time
DEPLOY_UNION="COMMON"               #deploy union
EDITER_MAIL="wangning1.zh@ccb.com"  #email
################################################

#----Define Paramater----
outpath="/home/ap/opscloud/result/collect/LINUX"
if [ ! -d $outpath ]; then
        mkdir -p $outpath
fi

#----Define Key Value Title----
kv_title()
{
echo '#HEADER DEFINE START'
echo 'DATA_TYPE_DEFAULT="String"'
echo 'DATA_TYPE_STRING=""'
echo 'DATA_TYPE_INTEGER=""'
echo 'DATA_TYPE_FLOAT=""'
echo 'COLL_SPLIT_KEYWORLD="="'
echo '#HEADER DEFINE END'
}

#----Define Table Title----
tb_title()
{
echo '#HEADER DEFINE START'
echo 'DATA_TYPE_DEFAULT="String"'
echo 'DATA_TYPE_STRING=""'
echo 'DATA_TYPE_INTEGER=""'
echo 'DATA_TYPE_FLOAT=""'
echo 'COLL_SPLIT_KEYWORLD="||"'
echo '#HEADER DEFINE END'
}

#----Define Base Collect----
base_info()
{
kv_title
echo OsType=`/bin/uname`
echo HostName=`/bin/hostname`
echo Version=`cat /etc/redhat-release`
echo Model=`/usr/sbin/dmidecode -t1 | grep -i "Product Name" | awk -F: '{print $2}'|awk 'gsub(/^ *| *$/,"")'`
echo SerialNumber=`/usr/sbin/dmidecode -t1 | grep -i "Serial Number" | awk -F: '{print $2}'|awk 'gsub(/^ *| *$/,"")'`
echo CpuPhysicalNum=`cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l`
echo CpuLogicalNum=`cat /proc/cpuinfo | grep "processor" | wc -l`
echo Memory=`/usr/bin/free -m |grep Mem |awk '{print $2"MB"}'`
echo UpTime=`/usr/bin/uptime |awk '{print $3$4}'|sed 's/,//'`
echo RunLevel=`/sbin/runlevel | awk '{print $2}'`
echo TimeZone=`cat /etc/sysconfig/clock |grep ZONE|awk -F "\"" '{print $2}'`
echo ProcessorType=`cat /proc/cpuinfo |grep "model name"|uniq |awk -F": " '{print $2}'`
}

#----Define Swap Collect----
swap_info()
{
tb_title
echo 'Device||Size'
swap_size=`/usr/bin/free -m |grep Swap|awk '{print $2"MB"}'`
swap_dev=`cat /proc/swaps |grep -v Filename|awk '{print $1}'`
echo "$swap_dev||$swap_size"
}

#----Define SysPara Collect----
sysctl_info()
{
kv_title
sysctl -a |sed 's/\./_/g' |sed 's/ = /=/g'
}

#----Define Route Collect----
route_info()
{
tb_title
echo 'Destination||Gateway||Mask||Interface'
netstat -rn |grep -Ew 'UG|UGH' |awk '{print $1"||"$2"||"$3"||"$8}'
}

#----Define ulimit Collect----
limit_info()
{
tb_title
echo "User||type||item||value"
cat /etc/security/limits.conf |grep -Ev "^#|^$" |awk '{print $1"||"$2"||"$3"||"$4}'

}

#----Define Hosts Collect----
hosts_info()
{
tb_title
echo 'IP||Hostname||Alias'
cat /etc/hosts|grep -Ev "^#|::1|^$" |awk '{print $1"||"$2"||"$3}'
}

#----Define FS Collect----
fstab_info()
{
tb_title
echo 'FileSystem||MountPoint||Type||Option||Dump||Pass'
cat /etc/fstab |grep -Ev '^#|^$' |awk '{print $1"||"$2"||"$3"||"$4"||"$5"||"$6}' 
}

#----Define mounted Filesystems Collect----
mount_info()
{
tb_title
echo 'Filesystem||Mountpoint||FStype||Option'
mount |awk '{print $1"||"$3"||"$5"||"$6}'
}

#----Define Ip Collect----
ip_info()
{
tb_title
echo "Interface||Netaddr||Netmask||Speed||Link detected||MAC"

for nic_name in `ifconfig |grep -E "eth|bond|enp|ens" |grep -v ether |awk '{print $1}' |sed 's/:$//g'`
do
    speed=`/sbin/ethtool $nic_name |grep Speed |awk '{print $2}'`
    stat=`/sbin/ethtool $nic_name |grep "Link detected" |awk '{print $3}'`

    if [ `cat /etc/redhat-release  |awk '{print $7}'|awk -F. '{print $1}'` -eq "7" ]
    then
        ip_addr=`/sbin/ifconfig $nic_name  |grep "inet" |awk '{print $2}'`
        net_mask=`/sbin/ifconfig $nic_name  |grep "inet" |awk '{print $4}'`
    else
        ip_addr=`/sbin/ifconfig $nic_name  |grep "inet addr"|sed 's/:/ /g' |awk '{print $3}'`
        net_mask=`/sbin/ifconfig $nic_name  |grep "inet addr"|sed 's/:/ /g' |awk '{print $7}'`
    fi

    if [ `/usr/sbin/dmidecode  |grep VMware |wc -l` -gt "0" ]
    then
        nic_mac=`cat /sys/class/net/$nic_name/address`
    else
        if [ `cat /etc/redhat-release  |awk '{print $7}'|awk -F. '{print $1}'` -eq "7" ]
        then
            nic_mac=`/sbin/ethtool -P $nic_name |awk '{print $3}'`
        else
            if [ `cat /etc/redhat-release  |awk '{print $7}'|awk -F. '{print $1}'` -eq "5" ]
            then
                nic_mac=`cat /var/log/dmesg |grep $nic_name |grep -E "node addr|MAC address" |awk '{print $NF}' |sed 's/\(..\)\(..\)\(..\)\(..\)\(..\)/\1:\2:\3:\4:\5:/'`
            else
                dr_ver=`/sbin/ethtool -i $nic_name |grep driver |awk '{print $2}'`
                if [ "$dr_ver" == "ixgbe" -o "$dr_ver" == "igb" ]
                then
                    nic_mac=`/sbin/ethtool -P $nic_name |awk '{print $3}'`
                else
                    nic_mac=`cat /var/log/dmesg |grep $nic_name |grep -E "node addr|MAC address" |awk '{print $NF}'`
                fi
            fi
        fi
    fi
    echo "$nic_name||$ip_addr||$net_mask||$speed||$stat||$nic_mac"
done
}

#----Define Group Collect----
group_info()
{
tb_title
echo 'Group||Password||GID||Users'
cat  /etc/group |awk -F ":" '{print $1"||"$2"||"$3"||"$4}'
}

#----Define User Collect----
user_info()
{
tb_title
echo 'User||Password||UID||PGid||Information||Home_Directory||Shell'
cat  /etc/passwd |awk -F ":" '{print $1"||"$2"||"$3"||"$4"||"$5"||"$6"||"$7}'
}


#----Define HBA Collect----
hba_info()
{
tb_title
echo 'Adapter||WWPN||Stat||Speed||Firmware'
systool -v -c fc_host|grep -Ew 'Class Device =|port_name|port_state|speed|symbolic_name'|awk -F '=' '{print $NF"||"}'|xargs -n 5|sed -e 's/|| /||/g' -e 's/||$//g'
}

#----Define Multpath Version collect----
multpath_info()
{
kv_title
if [ -f /sbin/powermt ]
then
    echo Multipath_version=`/sbin/powermt version |awk '{print $1" "$7 $8 $9}'`
elif [ -f /opt/DynamicLinkManager/bin/dlnkmgr ]
then
    echo Multipath_version=`/opt/DynamicLinkManager/bin/dlnkmgr view -sys |grep "HDLM Version" |awk '{print $1" "$4}'`
elif [ -f /usr/sbin/upadmin ]
then
    echo Multipath_version=HUAWEI `/usr/sbin/upadmin show version |grep "Software Version" |awk '{print $4}'`
else
    echo Multipath_version="N/A"
fi
}

#----Define NTP Status----
ntp_stat()
{
tb_title
echo 'Parameter||Value||Option'
cat /etc/ntp.conf |grep -Ev '^#|^$' |awk '{print $1"||"$2"||"$3}'
}

#----Define VG Collect----
vg_info()
{
tb_title
echo "VG||VG UUID||Max LV||Cur LV||Max PV||Cur PV||VG Size||VG Free||PE Size||Total PE||Free PE||PV"
vgs -o vg_name,vg_uuid,max_lv,lv_count,max_pv,pv_count,vg_size,vg_free,vg_extent_size,vg_extent_count,vg_free_count,pv_name --separator \|\| |sed '1d'
}

#----Define PV Collect----
pv_info()
{
tb_title
echo "PV||PV UUID||VG||PV Size||PV Free||PV Used||Total PE||Allocated PE"
pvs -o pv_name,pv_uuid,vg_name,pv_size,pv_free,pv_used,pv_pe_count,pv_pe_alloc_count --separator \|\| |sed '1d'
}

#----Define LV Collect----
lv_info()
{
tb_title
echo "Path||LV||VG||LV UUID||Attr||LV Size"
lvs -o lv_path,lv_name,vg_name,lv_uuid,lv_attr,lv_size --separator \|\| |sed '1d'
}

#----Define Chkconfig Collect----
chk_info()
{
tb_title
echo 'service||runlevel0||runlevel1||runlevel2||runlevel3||runlevel4||runlevel5||runlevel6'
chkconfig --list |awk '{print $1"||"$2"||"$3"||"$4"||"$5"||"$6"||"$7"||"$8}'
}

dns_info()
{
tb_title
echo 'Parameter||Value'
cat /etc/resolv.conf |grep -v "^#"|grep "^nameserver" |awk '{print $1"||"$2}'
}

soft_info()
{
tb_title
echo "Software||Version||Release"
#rpm -qa |grep openssh-server |xargs -i rpm -qi {}  |awk '{print $3}'|head -3|xargs |sed 's/ /||/g'
#rpm -qa |grep openssl|grep -v devel |xargs -i rpm -qi {}|awk '{print $3}'|head -3|xargs |sed 's/ /||/g'
rpm -qi openssh-server |awk '{print $3}'|head -3|xargs |sed 's/ /||/g'
rpm -qi openssl |awk '{print $3}'|head -3|xargs |sed 's/ /||/g'
}

bond_info()
{
tb_title
echo "Bonding Name||Adapter Names||Bonding Mode||LACP Rate"
if [ `ls -l /sys/class/net |grep bond |wc -l` -gt 0 ]
then
  for bond_name in `ls /sys/class/net |xargs -n 1 |grep bond |grep -v master`
  do
    adapter_name=`cat /proc/net/bonding/$bond_name |grep "Slave Interface" |awk '{print $3}'  |xargs`
    bond_mode=`cat /proc/net/bonding/$bond_name |grep "Bonding Mode" |awk -F ":" '{print $2}' |sed 's/^[[:space:]]*//g'`
    lacp_rate=`cat /proc/net/bonding/$bond_name |grep "LACP rate" |awk '{print $3}'`
    echo "$bond_name||$adapter_name||$bond_mode||$lacp_rate"
  done
fi
}

#----Define Options----
if [ $# -eq 0 ]
then
    base_info >$outpath/COLL_KV_linux_basicinfo_basicinfo_`hostname`_0.txt
    swap_info >$outpath/COLL_TB_linux_swap_swapinfo_`hostname`_0.txt
    sysctl_info >$outpath/COLL_KV_linux_sysctl_sysctlinfo_`hostname`_0.txt
    route_info >$outpath/COLL_TB_linux_route_routeinfo_`hostname`_0.txt
    limit_info >$outpath/COLL_TB_linux_limit_limitinfo_`hostname`_0.txt
    hosts_info >$outpath/COLL_TB_linux_hosts_hostsinfo_`hostname`_0.txt
    fstab_info >$outpath/COLL_TB_linux_filesystem_fstabinfo_`hostname`_0.txt
    mount_info >$outpath/COLL_TB_linux_filesystem_mountinfo_`hostname`_0.txt
    ip_info >$outpath/COLL_TB_linux_ip_ipinfo_`hostname`_0.txt
    group_info >$outpath/COLL_TB_linux_group_groupinfo_`hostname`_0.txt
    user_info >$outpath/COLL_TB_linux_user_userinfo_`hostname`_0.txt
    hba_info >$outpath/COLL_TB_linux_hba_hbainfo_`hostname`_0.txt
    multpath_info >$outpath/COLL_KV_linux_multipath_mpver_`hostname`_0.txt
    ntp_stat >$outpath/COLL_TB_linux_ntp_ntpinfo_`hostname`_0.txt
    vg_info >$outpath/COLL_TB_linux_lvminfo_vginfo_`hostname`_0.txt
    pv_info >$outpath/COLL_TB_linux_lvminfo_pvinfo_`hostname`_0.txt
    lv_info >$outpath/COLL_TB_linux_lvminfo_lvinfo_`hostname`_0.txt
    chk_info >$outpath/COLL_TB_linux_chkconfig_chkinfo_`hostname`_0.txt
    dns_info >$outpath/COLL_TB_linux_dns_dnsinfo_`hostname`_0.txt
    soft_info >$outpath/COLL_TB_linux_softinfo_softinfo_`hostname`_0.txt
    bond_info >$outpath/COLL_TB_linux_bondinfo_bondinfo_`hostname`_0.txt
fi

while [ $# -ne 0 ]
do
    case "$1" in 
      basicinfo)
         base_info >$outpath/COLL_KV_linux_basicinfo_basicinfo_`hostname`_0.txt
        ;;
      swapinfo)
         swap_info >$outpath/COLL_TB_linux_swap_swapinfo_`hostname`_0.txt
        ;;
      sysctlinfo)
         sysctl_info >$outpath/COLL_KV_linux_sysctl_sysctlinfo_`hostname`_0.txt
        ;;
      routeinfo)
         route_info >$outpath/COLL_TB_linux_route_routeinfo_`hostname`_0.txt
        ;;
      limitinfo)
         limit_info >$outpath/COLL_TB_linux_limit_limitinfo_`hostname`_0.txt
        ;;
      hostsinfo)
         hosts_info >$outpath/COLL_TB_linux_hosts_hostsinfo_`hostname`_0.txt
        ;;    
      fstabinfo)
         fs_info >$outpath/COLL_TB_linux_filesystem_fstabinfo_`hostname`_0.txt
        ;;
      mountinfo)
         mount_info >$outpath/COLL_TB_linux_filesystem_mountinfo_`hostname`_0.txt
        ;;
      ipinfo)
         ip_info >$outpath/COLL_TB_linux_ip_ipinfo_`hostname`_0.txt
        ;;
      groupinfo)
         group_info >$outpath/COLL_TB_linux_group_groupinfo_`hostname`_0.txt
        ;;
      userinfo)
         user_info >$outpath/COLL_TB_linux_user_userinfo_`hostname`_0.txt
        ;;
      hbainfo)
         hba_info >$outpath/COLL_TB_linux_hba_hbainfo_`hostname`_0.txt
        ;;
      mpver)
         multpath_info >$outpath/COLL_KV_linux_multipath_mpver_`hostname`_0.txt
        ;;
      ntpinfo)
         ntp_stat >$outpath/COLL_TB_linux_ntp_ntpinfo_`hostname`_0.txt
        ;;
      vginfo)
         vg_info >$outpath/COLL_TB_linux_lvminfo_vginfo_`hostname`_0.txt
        ;;
      pvinfo)
         pv_info >$outpath/COLL_TB_linux_lvminfo_pvinfo_`hostname`_0.txt
        ;;
      lvinfo)
         lv_info >$outpath/COLL_TB_linux_lvminfo_lvinfo_`hostname`_0.txt
        ;;
      chkinfo)
         chk_info >$outpath/COLL_TB_linux_chkconfig_chkinfo_`hostname`_0.txt
        ;;
      dnsinfo)
         dns_info >$outpath/COLL_TB_linux_dns_dnsinfo_`hostname`_0.txt
        ;;
      softinfo)
         soft_info >$outpath/COLL_TB_linux_softinfo_softinfo_`hostname`_0.txt
        ;;
      bondinfo)
         bond_info >$outpath/COLL_TB_linux_bondinfo_bondinfo_`hostname`_0.txt
        ;;
      *)
        echo "Usage:basicinfo|swapinfo|sysctlinfo|routeinfo|limitinfo|hostsinfo|fstabinfo|mountinfo|ipinfo|groupinfo|userinfo|hbainfo|mpver|ntpinfo|vginfo|pvinfo|lvinfo|chkinfo|dnsinfo|softinfo|bondinfo"
        ;;
    esac
    shift
