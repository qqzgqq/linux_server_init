# 使用ansible对linux服务器远程批量初始化脚本

## 一、安装ansible
```
brew install ansible
```
## 二、安装sshpass（免密）
```
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
```
## 三、脚本介绍
- init.sh 
    - 输入需要初始化计算机数量
    - 输入被初始化ip地址
- serverinit.sh
    - 更改复杂root密码
    - 增加用户**
    - 挂载disk
    - 添加远程端ssh-key
    - yum安装所需软件


