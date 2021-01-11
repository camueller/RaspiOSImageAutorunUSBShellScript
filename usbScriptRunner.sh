#!/bin/sh
MOUNT_POINT=/media
INSTALL_DIR=/tmp
ACTION=$1
DEVICE=$2
POWER_LED=/sys/class/leds/led1/brightness

case $ACTION in
  "add")
     echo 255 > $POWER_LED
     mount /dev/$DEVICE $MOUNT_POINT
     RUN_SCRIPT="$(basename `find $MOUNT_POINT -name "*.sh" | sort | head -n 1`)"
     cp $MOUNT_POINT/$RUN_SCRIPT $INSTALL_DIR
     $INSTALL_DIR/$RUN_SCRIPT
     echo 0 > $POWER_LED
     ;;
   "remove")
     sudo umount /media
     poweroff
     ;;
   *)
     echo "Usage: <add|remove> <device name>"
     ;;
esac

exit 0
