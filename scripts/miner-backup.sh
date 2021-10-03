#! /bin/bash

date
date=$(date +"%d_%m_%Y")
backup_dir=/home/filecoin/miner-backups 
/usr/local/bin/lotus-miner backup $backup_dir/$date.cbor
if [ $(ls $backup_dir | wc -l) -gt 6 ]
then
    echo "Removing oldest backup $(ls $backup_dir -t | tail -1)"
    rm $backup_dir/$(ls $backup_dir -t | tail -1)
fi
