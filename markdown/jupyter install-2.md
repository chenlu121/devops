
Centos7 安装 Jupyter notebook
1、安装环境
CentOS7.6+python.3.7.4+openssl1.1.1c+Jupyter notebook
2、安装
由于python3.7以后的版本需要OpenSSL1.0.2版本或1.1以上的版本，否则无法使用pip3安装模块
1）安装OpenSSL（这里使用的为1.1c版本）
yum -y install gcc make perl libffi-devel zlib* openssl-devel    //环境准备
wget https://www.openssl.org/source/openssl-1.1.1c.tar.gz
tar xvf openssl-1.1.1c.tar.gz
cd openssl-1.1.1c
./config --prefix=/usr/local/openssl no-zlib
make && make install
mv /usr/bin/openssl /usr/bin/openssl.bak  //backup
mv /usr/include/openssl/ /usr/include/openssl.bak
ln -s /usr/local/openssl/include/openssl /usr/include/openssl
ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/local/lib64/libssl.so
ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
ldconfig -v  //ldconfig是一个动态链接库管理命令，为了让动态链接库为系统所共享,还需运行动态链接库的管理命令–ldconfig。 ldconfig 命令的用途,主要是在默认搜寻目录(/lib和/usr/lib)以及动态库配置文件/etc/ld.so.conf内所列的目录下,搜索出可共享的动态 链接库(格式如前介绍,lib*.so*),进而创建出动态装入程序(ld.so)所需的连接和缓存文件.缓存文件默认为 /etc/ld.so.cache,此文件保存已排好序的动态链接库名字列表.
openssl version -a  //查看版本
2）安装Python3.7.4
wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz
tar xvf Python-3.7.4.tgz
cd Python-3.7.4
./configure --prefix=/usr/local/python3 --with-openssl=/usr/local/openssl
make && make install
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
vi ~/.bash_profile //修改配置文件
    PATH=$PATH:$HOME/bin:/usr/local/python3/bin
source ~/.bash_profile //配置刷新
python3 -V  
pip3 -V
python3 -m pip install --upgrade pip
python3 -m pip install jupyter
firewall-cmd --zone=public --add-port=8888/tcp --permanent  //开放防火墙8888端口
systemctl restart firewalld.service    //重启防火墙
python3 -m IPython notebook --ip=0.0.0.0 --no-browser --allow-root


```python

```