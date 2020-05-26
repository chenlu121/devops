
# Centos7 安装 Jupyter notebook
# 1、安装环境
## CentOS7.6+python.3.7.4+openssl1.1.1c+Jupyter notebook
# 2、安装
## 由于python3.7以后的版本需要OpenSSL1.0.2版本或1.1以上的版本，否则无法使用pip3安装模块
* 1）安装OpenSSL（这里使用的为1.1c版本）
  
`yum -y install gcc make perl libffi-devel zlib* openssl-devel sqlite-devel`

`wget https://www.openssl.org/source/openssl-1.1.1e.tar.gz`

`tar xvf openssl-1.1.1e.tar.gz`

`cd openssl-1.1.1e`

`./config --prefix=/usr/local/openssl no-zlib`

`make && make install`

`mv /usr/bin/openssl /usr/bin/openssl.bak`
`mv /usr/include/openssl/ /usr/include/openssl.bak`
`ln -s /usr/local/openssl/include/openssl /usr/include/openssl`
`ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/local/lib/libssl.so`
`ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl`
`echo "/usr/local/openssl/lib" >> /etc/ld.so.conf`
`ldconfig -v ` [^1]
`openssl version -a  `

[^1]:ldconfig是一个动态链接库管理命令，为了让动态链接库为系统所共享,还需运行动态链接库的管理命令–ldconfig。 ldconfig 命令的用途,主要是在默认搜寻目录(/lib和/usr/lib)以及动态库配置文件/etc/ld.so.conf内所列的目录下,搜索出可共享的动态 链接库(格式如前介绍,lib*.so*),进而创建出动态装入程序(ld.so)所需的连接和缓存文件.缓存文件默认为 /etc/ld.so.cache,此文件保存已排好序的动态链接库名字列表.
* 2）安装Python3.7.4
`wget https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tgz`
tar xvf Python-3.8.2.tgz
cd Python-3.8.2
./configure --prefix=/usr/local/python3 --with-openssl=/usr/local/openssl
make && make install
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
vi ~/.bash_profile //修改配置文件
    PATH=$PATH:$HOME/bin:/usr/local/python3/bin
source ~/.bash_profile //配置刷新
python3 -V  
pip3 -V
python3 -m pip install --upgrade pip -i https://pypi.doubanio.com/simple/
python3 -m pip install jupyter -i https://pypi.doubanio.com/simple/
firewall-cmd --zone=public --add-port=8888/tcp --permanent  //开放防火墙8888端口
systemctl restart firewalld.service    //重启防火墙
python3 -m IPython notebook --ip=0.0.0.0 --no-browser --allow-root
===
---
java for Jupyter
install java 
download ijava
wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip
unzip ijava-1.3.0.zip
python3 install.py --sys-prefix
jupyter console --kernel=java  //test java
===
---
ruby for Jupyter
yum install centos-release-scl-rh
 yum install rh-ruby25  -y
 scl  enable  rh-ruby25 bash
 ruby -v
 gem install redis
 gem install iruby
 iruby register --force
 