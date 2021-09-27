#! /bin/bash

i=0
date +%H:%M
if [ $(/usr/local/bin/lotus-miner sectors list | grep -v Proving | wc -l) -lt 7 ]
then
	echo "needs more pledges"
	while [ $(/usr/local/bin/lotus-miner sectors list | grep -v Proving | wc -l) -lt 7 ]
	do
		/usr/local/bin/lotus-miner sectors pledge
		echo "pledge added"
		((i++))
		if [[ "$i" == '6' ]]
	       	then
			break
		fi
	done
else
	echo "no new pledges needed"
fi
