#!/bin/bash
#author zengguang 
#date 2017-09-04 14:29:10
#describe init server
hosttime=hosts_$(date +%F)
USER=root
PASSWD=*******
DIR=`pwd`


read -p "please input will init servers number :" numserver
pdnum=$(echo $numserver|grep "[0-9]")
send(){
mv /usr/local/etc/ansible/hosts /usr/local/etc/ansible/$hosttime
for ((a=1;a<=$numserver;a++))
do
	echo "[zgtest$a]" >> /usr/local/etc/ansible/hosts
	read -p "please input will init $a server ipaddress :" newserver
	echo $newserver ansible_ssh_user=$USER  ansible_ssh_pass=$PASSWD >> /usr/local/etc/ansible/hosts
done
}
send2(){
echo "########################################COPY START#########################################"
ansible all -m copy -a "src=$DIR/serverinit.sh dest=/root"
echo "########################################CHMOD START#########################################"
ansible all -m command -a "chmod 755 /root/serverinit.sh"
echo "########################################SERVERINIT START#########################################"
ansible all -m command -a "sh /root/serverinit.sh"
}
if [ -z $numserver ]
	then 
		echo "your input the init server number is 0"
		exit 0
elif [ -z $pdnum ]
	then 
		echo "your input is not num"
		exit 1 
else 	
		send
		send2
fi
