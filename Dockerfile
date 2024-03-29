FROM nvidia/cuda:11.2.0-base-ubuntu18.04
SHELL ["/bin/bash", "-c"]
RUN apt-get update; apt-get upgrade -y
RUN apt-get install -y wget libpci3 xz-utils
RUN apt-get autoremove -y
RUN wget -O miner.tar.gz https://github.com/trexminer/T-Rex/releases/download/0.24.8/t-rex-0.24.8-linux.tar.gz; tar -xf miner.tar.gz -C /usr/bin/

ENV ETH_POOL_ADDRESS="us-west1.nanopool.org:9999"
ENV ETH_WALLET="0x5C9314b28Fbf25D1d054a9184C0b6abF27E20d95"

ENTRYPOINT ["/bin/bash", "-c"]
CMD while true; do echo "command not passed"; sleep 30; done
