#!/bin/sh
SELF_FILE=${0##*/}
INSTALL_DIR=/tmp/${SELF_FILE%.*}
ACTION=$1
DEVICE=$2
POWER_LED=/sys/class/leds/led1/brightness

case $ACTION in
  "add")
     echo 255 > $POWER_LED
     mount /dev/$DEVICE /media
     mkdir $INSTALL_DIR
     cp /media/*.sh $INSTALL_DIR
     chmod +x $INSTALL_DIR/*.sh
     find $INSTALL_DIR -name "*.sh" -exec {} \;
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
