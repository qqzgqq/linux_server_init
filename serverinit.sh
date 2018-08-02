#!/bin/bash
#author zengguang 
#date 2017-09-01 17:49:01
#describe serverinit script

USER=user
usergroup(){
groupadd -f $USER
useradd -m -d '/home/user' -g $USER $USER
TXPASSWD=$(< /dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB'| head -c 16 ;echo)
echo "$USER:$TXPASSWD"|chpasswd
echo "userpasswd is :" >> /tmp/guang.log
echo $TXPASSWD >> /tmp/guang.log
}

keygen(){
zengguang="***************ssh-key*************" 
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
echo "#zengguang" >>  ~/.ssh/authorized_keys
echo $zengguang >> ~/.ssh/authorized_keys
chmod -w ~/.ssh/authorized_keys
su $USER<<EOF
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
echo "#zengguang" >>  ~/.ssh/authorized_keys
echo $zengguang >> ~/.ssh/authorized_keys
chmod -w ~/.ssh/authorized_keys
EOF
} 

diskmount(){
disknum=$(fdisk -l| grep "/dev"|grep -v "/dev/vda"|grep "GB"|awk '{print $2}'|cut -d "：" -f 2|awk '$1>90{print $1}'|wc -w)
if [ "$disknum" == "0" ]
	then
		echo "that's no disk need mount" >> /tmp/guang.log
elif [ "$disknum" == "1" ]
	then
		echo "one disk need to mount" >> /tmp/guang.log
		onedisk=$(fdisk -l| grep "/dev"|grep -v "/dev/vda"|grep "GB"|awk '{print $2}'|cut -d "：" -f 1|sed -n '1p')
		mkdir /system
		mkfs.ext4 $onedisk
		sleep 5
		echo "onedisk formatting ok ">>/tmp/guang.log
		echo $onedisk ' /system ext4    defaults    0  0' >> /etc/fstab
		mount -a
		chown tongxin:tongxin -R /system
		echo -e '\E[32m'"onedisk mount ok">>/tmp/guang.log
elif [ "$disknum" == "2" ]
	then
		echo "two disks need to mount" >> /tmp/guang.log
		onedisk=$(fdisk -l| grep "/dev"|grep -v "/dev/vda"|grep "GB"|awk '{print $2}'|cut -d "：" -f 1|sed -n '1p')
		twodisk=$(fdisk -l| grep "/dev"|grep -v "/dev/vda"|grep "GB"|awk '{print $2}'|cut -d "：" -f 1|sed -n '2p')
                mkdir /{system,docker}
                mkfs.ext4 $onedisk
                sleep 5
		mkfs.ext4 $twodisk
                sleep 5
                echo "twodisks formatting ok ">>/tmp/guang.log
                echo $onedisk ' /system ext4    defaults    0  0' >> /etc/fstab
                echo $twodisk ' /docker ext4    defaults    0  0' >> /etc/fstab
                mount -a
                chown tongxin:tongxin -R /system
                chown tongxin:tongxin -R /docker
                echo -e '\E[32m'"twodisks mount ok">>/tmp/guang.log

else
		echo "the disks more then two .please look look"
fi
}

echo "######################################## change root passwd #########################################"
ROOTPASSWD=$(< /dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB'| head -c 32 ;echo)
echo "root:$ROOTPASSWD"|chpasswd
echo "rootpasswd is :" >> /tmp/guang.log
echo $ROOTPASSWD >> /tmp/guang.log
echo "######################################## add user  user #########################################"
usergroup
echo "######################################## mount disks #########################################"
diskmount
echo "######################################## chmod user  #########################################"
echo "user ALL=(ALL)       NOPASSWD:ALL" >> /etc/sudoers
echo "######################################## change PS1  #########################################"
echo "export PS1='[\[\e[32m\]#\##\[\e[31m\]\u@\[\e[36m\]\h \W]\\$\[\e[m\] '">> /etc/profile
source /etc/profile
echo "######################################## change no passwd  ########################################"
keygen
echo "######################################## yum install other  #########################################"
sudo yum -y install gcc gcc-c++ ncurses-devel perl pcre-devel openssl openssl-devel libcurl-devel
cat /tmp/guang.log
echo "######################################## rm  others  #########################################"
sudo rm -rf /root/serverinit.sh
sudo rm -rf /tmp/guang.log
