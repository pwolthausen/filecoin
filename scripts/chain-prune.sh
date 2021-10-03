#! /bin/bash

date
export RUSTFLAGS="-C target-cpu=native -g"
export FFI_BUILD_FROM_SOURCE=1

disk_space=$(df -h | awk '$6 == "/home" {print $5}' | tr -d %)
if [ $disk_space -gt 90 ]
then
    echo "Pruning chain"
    systemctl stop lotus.service
    systemctl stop lotus-miner
    systemctl stop lotus-worker
    systemctl stop lotus-worker-pc1
    systemctl stop lotus-worker-pc2
    sleep 60

    /usr/local/bin/lotus --version
    echo "updating lotus binaries"
    
    cd /root/lotus && git pull
    cd /root/lotus && make clean all
    cd /root/lotus && make install

    rm -rf /home/filecoin/.lotus/datastore/chain/*
    
    /usr/local/bin/lotus --version

    systemctl start lotus.service
    systemctl start lotus-miner
    systemctl start lotus-worker
    systemctl start lotus-worker-pc1
    systemctl start lotus-worker-pc2
else
    echo "Pruning not required"
fi
