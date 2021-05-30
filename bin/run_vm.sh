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

# Default variable values

memory_in_gb="4"
number_of_cores="2"

# Process args

usage () {

  echo "${0} --disk-image=PATH_DISK_IMAGE [ --cores=NUMBER | --memory-in-gb=NUMBER | --install-media=ISO_OF_INSTALL_MEDIA ]"

}

flag_a=""
flag_b=""
flag_c=""
flag_d=""

cdrom_argument=" "
while [ $# -gt 0 ]
do
  case "${1}" in
    --cores=*)
      number_of_cores="`echo $1 | sed 's,^--cores=,,'`"
      flag_a="${flag_a:-""}A"
    ;;
    --memory-in-gb=*)
      memory_in_gb="`echo $1 | sed 's,^--memory-in-gb=,,'`"
      flag_b="${flag_b:-""}B"
    ;;
    --disk-image=*)
      disk_image="`echo $1 | sed 's,^--disk-image=,,' | sed -e s,\~,${HOME}, `"
      flag_c="${flag_c:-""}C"
    ;;
    --install-media=*)
      install_media="`echo $1 | sed 's,^--install-media=,,' | sed -e s,\~,${HOME}, `"
      cdrom_argument="-cdrom ${install_media}"
      flag_d="${flag_d:-""}D"
    ;;
    *)
      echo -e "\nUnrecognized flag\n\n$(usage)\n" 1>&2
      exit 1
    ;;
  esac
  shift
done

# Run QEMU Command Line

case "${flag_a}${flag_b}${flag_c}" in
  AC|ACD|BC|BCD|ABC|ABCD|C|CD)
    qemu-system-x86_64 \
      -m ${memory_in_gb}G \
      -vga virtio \
      -display default,show-cursor=on \
      -usb \
      -device usb-tablet \
      -machine type=q35,accel=hvf \
      ${cdrom_argument} \
      -smp cores=${number_of_cores} \
      -drive file="${disk_image}",format=raw,cache=none,if=virtio \
      -device intel-hda -device hda-output \
      -cpu host
  ;;
  *)
    echo -e "\nIncorrect combination of flags\n\n$(usage)\n" 1>&2
    exit 2
  ;;
esac

