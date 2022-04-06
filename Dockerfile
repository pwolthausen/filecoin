FROM nvidia/cuda:11.2.0-base-ubuntu18.04
SHELL ["/bin/bash", "-c"]
RUN apt update; apt upgrade -y; apt install -y wget libpci3 xz-utils
RUN wget -O miner.tar.gz https://github.com/trexminer/T-Rex/releases/download/0.24.8/t-rex-0.24.8-linux.tar.gz; tar -xf miner.tar.gz -C /usr/bin/

ENV ETH_POOL_ADDRESS="us-west1.nanopool.org:9999"
ENV ETH_WALLET="0x5C9314b28Fbf25D1d054a9184C0b6abF27E20d95"
# ENV DISPLAY=':0 XAUTHORITY=/var/run/lightdm/root/:0 /usr/bin/nvidia-settings --assign "[gpu:0]/GPUGraphicsClockOffset[3]=-100" --assign "[gpu:0]/GPUMemoryTransferRateOffset[3]=2800" --assign "[gpu:1]/GPUGraphicsClockOffset[3]=-100" --assign "[gpu:1]/GPUMemoryTransferRateOffset[3]=2800"'
# ENV DISPLAY=':0 XAUTHORITY=/var/run/lightdm/root/:0 /usr/bin/nvidia-settings --assign "[gpu:0]/GPUGraphicsClockOffset[3]=-200" --assign "[gpu:0]/GPUMemoryTransferRateOffset[3]=2400" --assign "[gpu:1]/GPUGraphicsClockOffset[3]=-200" --assign "[gpu:1]/GPUMemoryTransferRateOffset[3]=2400"'

ENTRYPOINT ["/bin/bash", "-c"]
CMD while true; do echo "command not passed"; sleep 30; done