#! /bin/bash

i=0
date
sectors=$(/usr/local/bin/lotus-miner sectors list | awk '$5 == "n/a"' | wc -l)
if [ $sectors -lt 6 ]
then
	echo "needs more pledges"
	while [ $sectors -lt 6 ]
	do
		/usr/local/bin/lotus-miner sectors pledge
		echo "pledge added"
		((sectors++))
		((i++))
		if [[ "$i" == '6' ]]
	       	then
			break
		fi
	done
else
	echo "no new pledges needed"
fi

