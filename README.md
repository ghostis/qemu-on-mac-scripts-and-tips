# Scripts and notes for running QEMU VMs on MacOS

* See bin directory for example scripts. Modify the variables before running the scripts.

# Installing QEMU and setting up a VM

## First, install homebrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Install QEMU
```
brew install qemu 
```

## Set up the VM tree

* Let's call the VM "debian10vm". We'll use 4 cores, 8GB of ram, and a 40GB disk.

```
mkdir -p ~/qemu/debian10vm/{disks,install_images}

cd ~/qemu/debian10vm/disks
```

## Make the VM's disk image

```
dd if=/dev/zero of=./40GiB_raw bs=1g count=40
```

## Download the install media

```
cd ~/qemu/debian10vm/install_images/

curl -O -L -C - https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.9.0-amd64-netinst.iso
```

## Create VM start up scripts
```
cd ~/qemu/debian10vm

cat > ./start.sh << eo_start.sh 
#!/bin/bash
qemu-system-x86_64 \
  -m 8G \
  -vga virtio \
  -display default,show-cursor=on \
  -usb \
  -device usb-tablet \
  -machine type=q35,accel=hvf \
  -smp cores=4 \
  -drive file=~/qemu/debian10vm/disks/40GiB_raw,format=raw,cache=none,if=virtio \
  -cpu host

eo_start.sh


cat > ./start_with_installer.sh << eo_start_with_installer.sh 
#!/bin/bash
qemu-system-x86_64 \
  -m 8G \
  -vga virtio \
  -display default,show-cursor=on \
  -usb \
  -device usb-tablet \
  -machine type=q35,accel=hvf \
  -smp cores=4 \
  -cdrom ~/qemu/debian10vm/install_images/debian-10.9.0-amd64-netinst.iso \
  -drive file=~/qemu/debian10vm/disks/40GiB_raw,format=raw,cache=none,if=virtio \
  -cpu host

eo_start_with_installer.sh

chmod 700 ./start.sh start_with_installer.sh
```

## Run script to start the VM with the install media

```
~/qemu/debian10vm/start_with_installer.sh
```

## After installation, start the VM with the start script

```
~/qemu/debian10vm/start.sh
```

## Start at login

To start at login, add the script to your login items in System Preferences.

## SSH Access from your Mac

*In the past, you could create a bridge and then add a "tap" interface to that bridge on MacOS, but Apple discontinued support for kernel extensions. Unfortunately, the known tap device drivers are all kernel extensions and no longer work. As such, the QEMU VMs can only use NAT on MacOS. To access your VM from your Mac, you can set up an ssh reverse tunnel from the VM to a port on your host Mac.*

* Start the VM
* Log into the console window
* Run:
```
ssh -f -N -R 2222:localhost:22 your_mac_username@your_macs_hostname
```
* On your Mac, you can now log into the VM:
```
ssh username_on_vm@localhost -p 2222
```

