# filecoin
files used for my filecoin deployment

## Ansible Playbook

#### Required Variables

master_static_ip: static IP assigned to the master node used by the miner

sealing_pvs:  list of storage devices used for the sealing directory. Used to make a Virtual Group for LVM

longterm_pvs: list of storage devices used for longterm storage. Used to make a Virtual Group for LVM

miner_backup_dir: directory where miner backups are stored