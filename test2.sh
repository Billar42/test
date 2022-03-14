#!/usr/bin/env bash

# mount configfs
mount -t configfs none /sys/kernel/config
# load libcomposite module
modprobe libcomposite
# create a gadget
mkdir /sys/kernel/config/usb_gadget/g1
# cd to its configfs node
cd /sys/kernel/config/usb_gadget/g1
# configure it (vid/pid can be anything if USB Class is used for driver compat)
echo 0xabcd > idVendor
echo 0x1234 > idProduct
# configure its serial/mfg/product
mkdir strings/0x409
echo myserial > strings/0x409/serialnumber
echo mymfg > strings/0x409/manufacturer
echo myproduct > strings/0x409/product
# create configs
mkdir configs/c.1
mkdir configs/c.2
mkdir configs/c.3
# configure them with attributes if needed
echo 120 > configs/c.1/MaxPower
echo 120 > configs/c.2/MaxPower
echo 120 > configs/c.2/MaxPower
# ensure function is loaded
modprobe usb_f_mass_storage
# create the function (name must match a usb_f_<name> module such as 'acm')
mkdir functions/mass_storage.0
# create backing store(s): in this example 2 LUN's 16MB each
dd bs=1M count=16 if=/dev/zero of=/tmp/lun0.img # 16MB
dd bs=1M count=16 if=/dev/zero of=/tmp/lun1.img # 16MB
# associate with partitions
mkdir functions/mass_storage.0/lun.0
echo /tmp/lun0.img > functions/mass_storage.0/lun.0/file
mkdir functions/mass_storage.0/lun.1
echo /tmp/lun1.img > functions/mass_storage.0/lun.1/file
# associate function with config
ln -s functions/mass_storage.0 configs/c.1
# enable gadget by binding it to a UDC from /sys/class/udc
echo 0000:01:00.0 > UDC
# to unbind it: echo "" > UDC; sleep 1; rm -rf /sys/kernel/config/usb_gadget/g1
