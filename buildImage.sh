#!/bin/sh
#
# Copyright (C) 2021 Axel Müller <axel.mueller@avanux.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
IMAGE_URL=https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2023-12-11/2023-12-11-raspios-bookworm-armhf-lite.img.xz
MOUNT_POINT=mnt
COMPRESSED_IMAGE_INPUT_FILE=`basename $IMAGE_URL`
COMPRESSED_IMAGE_OUTPUT_FILE=`echo $COMPRESSED_IMAGE_INPUT_FILE | sed 's/lite.img.xz/lite-usbrun.img.zip/g'`

echo "Downloading Raspbian OS image from $IMAGE_URL ..."
curl -o $COMPRESSED_IMAGE_INPUT_FILE $IMAGE_URL

echo "Decompressing image from $COMPRESSED_IMAGE_INPUT_FILE ..."
xz -d $COMPRESSED_IMAGE_INPUT_FILE
IMAGE_FILE=`find . -name *.img`

FAT32_PARTITION_OFFSET=`fdisk -l $IMAGE_FILE | grep FAT32 | awk '{print $2}'`
echo "FAT32 partition offset is $FAT32_PARTITION_OFFSET"

LINUX_PARTITION_OFFSET=`fdisk -l $IMAGE_FILE | grep Linux | awk '{print $2}'`
echo "Linux partition offset is $LINUX_PARTITION_OFFSET"

echo "Mounting FAT32 partition under $MOUNT_POINT ..."
mkdir -p $MOUNT_POINT
sudo mount -t auto -o loop,offset=$((FAT32_PARTITION_OFFSET * 512)) $IMAGE_FILE $MOUNT_POINT

echo "Enable SSH access"
sudo touch $MOUNT_POINT/ssh

echo "Create default user"
sudo bash -c "echo -n 'pi:' > $MOUNT_POINT/userconf"
sudo bash -c "echo "raspberry" | openssl passwd -6 -stdin >> mnt/userconf >> $MOUNT_POINT/userconf"

echo "Unmounting FAT32 partition..."
sudo umount $MOUNT_POINT

echo "Mounting Linux partition under $MOUNT_POINT ..."
mkdir -p $MOUNT_POINT
sudo mount -t auto -o loop,offset=$((LINUX_PARTITION_OFFSET * 512)) $IMAGE_FILE $MOUNT_POINT

echo "Allow script execution by udevd ..."
# Refer to https://raspberrypi.stackexchange.com/questions/100312/raspberry-4-usbmount-not-working/100375#100375
sudo sed -i 's/PrivateMounts\=yes/PrivateMounts\=no/g' $MOUNT_POINT/lib/systemd/system/systemd-udevd.service
sudo sed -i 's/SystemCallFilter\=/# SystemCallFilter\=/g' $MOUNT_POINT/lib/systemd/system/systemd-udevd.service

echo "Add udev rules ..."
sudo cp usbScriptRunner.rules $MOUNT_POINT/etc/udev/rules.d/50-usbScriptRunner.rules

echo "Copy usb script runner ..."
sudo cp usbScriptRunner.sh $MOUNT_POINT/usr/local/bin

echo "Unmounting Linux partition ..."
sudo umount $MOUNT_POINT

echo "Compressing image ..."
zip $COMPRESSED_IMAGE_OUTPUT_FILE *.img
