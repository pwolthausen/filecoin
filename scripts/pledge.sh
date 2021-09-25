#! /bin/bash

if [ $(/usr/local/bin/lotus-miner sealing jobs | wc -l) -lt 11 ]
then
	while [ $(/usr/local/bin/lotus-miner sealing jobs | wc -l) -lt 11 ]
	do
		/usr/local/bin/lotus-miner sectors pledge
	done
fi
