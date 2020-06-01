#! /bin/bash

raidcom_login()
{
/usr/bin/expect << EOF
set timeout 10
spawn raidcom -login
expect "User*"
send "$1\r"
expect "Password*"
send "$2\r"
expect eof
EOF

timeout 5 raidcom get resource >/dev/null 2>&1
if [ $? -eq 0 ]
then
        echo $(date +%Y-%m-%d_%H:%M:%S) Information: $HORCMINST Login successful!
else
        raidcom -logout
        exit 1
fi
}

info_collect()
{
echo -e "sn_of_stg mcode_version cache_size_gb" >> $WORKDIR/output/${stg_sn}_orig.sys.info.txt
raidqry -lm -f |grep -v Serial| awk '{print substr($6,length($6)-4,5),$7,(int($8/1024/128)+1)*128}' >> $WORKDIR/output/${stg_sn}_orig.sys.

echo -e "sn_of_stg port port_attr port_fabric port_conn port_wwn" >> $WORKDIR/output/${stg_sn}_orig.fport.info.txt
raidcom get port -IH${stg_sn} |grep -v Serial|awk '{print substr($10,length($10)-4,5),$1,$3,$6,$7,$11}' >> $WORKDIR/output/${stg_sn}_orig.

echo -e "sn_of_stg port login_wwn" >> $WORKDIR/output/${stg_sn}_orig.fport.conn.info.txt
raidcom get port -IH${stg_sn} |grep -v Serial|awk '{print $1}'|while read line
do
raidcom get port -port $line -IH${stg_sn} |grep ^C|awk '{print substr($3,length($3)-4,5),$1,$2}' >> $WORKDIR/output/${stg_sn}_orig.fport.c
done

echo -e "sn_of_stg pool_name pool_type pool_id pool_cap_gb" >> $WORKDIR/output/${stg_sn}_orig.pool.total.detail.txt
raidcom get pool -key basic -IH${stg_sn} |grep -v Seq|awk '{print substr($13,length($13)-4,5),$23,$22,int($1),$7/1024}' >> $WORKDIR/output
xt

echo -e "sn_of_stg member_ldev pool_name raid_level raid_type phy_disk_type rg_cap_gb raid_group" \
>>$WORKDIR/output/${stg_sn}_orig.nativeldevinpool.info.txt
echo -e "sn_of_stg vvol_name vvol_cap_gb of_pool num_of_path host_grp" \
>>$WORKDIR/output/${stg_sn}_orig.virtulvol.info.txt
echo -e "sn_of_stg pool_name mapped_gb" \
>>$WORKDIR/output/${stg_sn}_orig.mapped.cap.detail.txt

raidcom get pool -key basic -IH${stg_sn} |grep -v Seq| awk '{print int($1),$23,$7/1024}' |while read poolid poolname poolgb
do
raidcom get ldev -ldev_list pool -pool_id $poolid -key parity_grp -fx -IH${stg_sn} |grep -v Serial|awk -v poolname=$poolname \
'{print substr($1,length($1)-4,5),$2,poolname,$7,$8,$9,int($10/1024/1024/2),$12}'  \
>>$WORKDIR/output/${stg_sn}_orig.nativeldevinpool.info.txt

raidcom get ldev -ldev_list mapped -pool_id $poolid -key front_end -fx -IH${stg_sn} |grep -v Serial|awk -v poolname=$poolname \
'{printf("%s %s %.2f %s %d", substr($1,length($1)-4,5),$2,$6/1024/1024/2,poolname,$9)}{split($NF,a,":");print " ",a[3]}' \
>>$WORKDIR/output/${stg_sn}_orig.$poolname.mapped.vvol.detail.txt

cat $WORKDIR/output/${stg_sn}_orig.$poolname.mapped.vvol.detail.txt |awk -v S=${stg_sn} -v P=${poolname} 'BEGIN{total=0}{total+=$3}END{pri
nt S,P,total}' \
>>$WORKDIR/output/${stg_sn}_orig.mapped.cap.detail.txt

raidcom get ldev -ldev_list unmapped -pool_id $poolid -key front_end -fx -IH${stg_sn} |grep -v Serial|awk -v poolname=$poolname \
'{printf("%s %s %.2f %s %d %s\n", substr($1,length($1)-4,5),$2,$6/1024/1024/2,poolname,$9,"NA")}' \
>>$WORKDIR/output/${stg_sn}_orig.$poolname.unmapped.vvol.detail.txt

cat $WORKDIR/output/${stg_sn}_orig.$poolname.*.vvol.detail.txt |sort -k 2 >> $WORKDIR/output/${stg_sn}_orig.virtulvol.info.txt

done
