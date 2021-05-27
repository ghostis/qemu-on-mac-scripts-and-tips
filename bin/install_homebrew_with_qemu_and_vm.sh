#!/bin/bash

set -eu

### BEGIN LICENSE ###

### Copyright 2021 ghostis

### Permission is hereby granted, free of charge, to any person
### obtaining a copy of this software and associated documentation
### files (the "Software"), to deal in the Software without
### restriction, including without limitation the rights to use,
### copy, modify, merge, publish, distribute, sublicense, and/or
### sell copies of the Software, and to permit persons to whom
### the Software is furnished to do so, subject to the following
### conditions:
### 
### The above copyright notice and this permission notice shall
### be included in all copies or substantial portions of the Software.
### 
### THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
### EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
### OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
### NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
### HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
### WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
### OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
### DEALINGS IN THE SOFTWARE.

### END OF LICENSE ###

# Variables. Update these before running.

new_vm_name="debian10host"
disk_size_in_gb="30"
memory_in_gb="4"
number_of_cores="2"
url_to_install_image="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.9.0-amd64-netinst.iso"

mkdir -p ~/qemu/${new_vm_name}/{disks,install_images}

cd ~/qemu/${new_vm_name}/disks

dd if=/dev/zero of=./${disk_size_in_gb}GiB_raw bs=1g count=${disk_size_in_gb}

cd ~/qemu/${new_vm_name}/install_images/

curl -O -L -C - ${url_to_install_image}

cd ~/qemu/${new_vm_name}

cat > ./start.sh << eo_start.sh 
#!/bin/bash
qemu-system-x86_64 \
  -m ${memory_in_gb}G \
  -vga virtio \
  -display default,show-cursor=on \
  -usb \
  -device usb-tablet \
  -machine type=q35,accel=hvf \
  -smp cores=${number_of_cores} \
  -drive file=~/qemu/${new_vm_name}/disks/${disk_size_in_gb}GiB_raw,format=raw,cache=none,if=virtio \
  -cpu host

eo_start.sh

install_image_file="$(ls -1rt ./install_images | tail -1 )"

cat > ./start_with_installer.sh << eo_start_with_installer.sh 
#!/bin/bash
qemu-system-x86_64 \
  -m ${memory_in_gb}G \
  -vga virtio \
  -display default,show-cursor=on \
  -usb \
  -device usb-tablet \
  -machine type=q35,accel=hvf \
  -smp cores=${number_of_cores} \
  -cdrom ~/qemu/${new_vm_name}/install_images/${install_image_file} \
  -drive file=~/qemu/${new_vm_name}/disks/${disk_size_in_gb}GiB_raw,format=raw,cache=none,if=virtio \
  -cpu host

eo_start_with_installer.sh

chmod 700 ~/qemu/${new_vm_name}/start.sh ~/qemu/${new_vm_name}/start_with_installer.sh

# Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install qemu 

~/qemu/${new_vm_name}/start_with_installer.sh
