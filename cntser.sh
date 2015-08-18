#!/bin/sh

#sudo sshfs -o allow_other huafang@10.0.0.180:/home3/huafang ~/server
sshfs -o allow_other huafang@ss2:/home3/huafang ~/server/ss2
sshfs -o allow_other huafang@android13:/home3/huafang ~/server/android13
sudo mount -t cifs -o username=hua.fang,password=789@qweZXC,uid=$(id -u),gid=$(id -g) //10.0.0.165/thinclient ~/net_folder/n_folder
sudo mount -t cifs -o username=hua.fang,password=789@qweZXC,uid=$(id -u),gid=$(id -g) //10.0.0.165/to_internal ~/net_folder/to_internal_folder
#sudo sshfs -o allow_other builder@10.0.64.37:/home/builder/pac/modem3.0/modem_dolphin_Samsung ~/server/hudson_bj
#sudo sshfs -o allow_other builder@10.0.0.153:/home/builder/ ~/server/hudson_sh
