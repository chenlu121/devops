#!/bin/bash
#警告：切勿在没有配置 Docker YUM 源的情况下直接使用 yum 命令安装 Docker
#docker安装前提条件：1，centos版本需要7或更高版本，2、centos-extra仓库需要处于启用状态
#建议：使用overlay2存储驱动
#echo "docker安装前提条件：1，centos版本需要7或更高版本，2、centos-extra仓库需要处于启用状态，建议：使用overlay2存储驱动"
echo "1. 检查用户docker是否已创建"
check_results=`groups docker | grep "docker"`
echo "执行groups docker指令: $check_results"

if [[ $check_results =~ "docker" ]];
then
   echo "用户组docker已存在. "
else
   echo "用户组docker不存在，接下来创建docker用户及用户组"
   groupadd docker
   useradd -r -g docker docker
   echo "用户及用户组docker创建完成"
fi


#检查是否有旧版本docker，如果有则卸载
echo "2.检查是否有旧版本docke,有则删除"
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
#2.docker 安装
echo "3.设置参数,配置仓库文件"
sudo yum install –y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "4.开始安装docker社区版19.03.8"
sudo yum install docker-ce-19.03.8

echo "5.启动Docker并加入开机启动项"
sudo systemctl start docker
sudo systemctl enable docker

echo "6.普通用户docker加入docker用户组"
sudo usermod -aG docker docker

echo "7.查看版本验证安装测试"
docker version
check_results=`docker run hello-world | grep "Hello from Docker!"`
if [[ $check_results =~ "Hello from Docker!" ]];
then
   echo "Docker成功安装 "
else
   echo "docker安装出现异常，请检查"
fi
