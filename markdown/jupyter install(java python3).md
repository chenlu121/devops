
# Centos7 安装 Jupyter notebook
1. 安装环境(CentOS7.6+miniconda+jupyter notebook)
*[^_^]:下载并安装miniconda
```
wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

sh Miniconda3-latest-Linux-x86_64.sh
vi /etc/profile
    export PATH=/etc/miniconda3/bin:$PATH
source /etc/profile
cat .condarc
channels:
  - defaults
show_channel_urls: true
channel_alias: https://mirrors.tuna.tsinghua.edu.cn/anaconda
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/pro
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
conda config --set show_channel_urls yes
conda config --get channels
conda install jupyter notebook
conda create -n myenv jupyter notebook
conda deactivate
conda activate myenv
jupyter notebook --allow-root
jupyter notebook --generate-config
ipython
    from notebook.auth import passwd
     passwd()
vi ~/.jupyter/jupyter_notebook_config.py
    c.NotebookApp.password = ''
    c.NotebookApp.ip='*'
    c.NotebookApp.open_browser = False
    c.NotebookApp.port =8888
    allow_remote_access=True
pip install bash_kernel
python -m bash_kernel.install
pip install markdown-kernel
python -m markdown_kernel.install
pip3 install jupyter-c-kernel
install_c_kernel
conda install xeus-cling -c conda-forge
jupyter kernelspec list
```
 