#!/bin/sh
MOUNT_POINT=/media
INSTALL_DIR=/tmp
ACTION=$1
DEVICE=$2
POWER_LED=/sys/class/leds/PWR/brightness

case $ACTION in
  "add")
     echo 255 > $POWER_LED
     mount /dev/$DEVICE $MOUNT_POINT
     RUN_SCRIPT="$(basename `find $MOUNT_POINT -name "*.sh" | sort | head -n 1`)"
     cat $MOUNT_POINT/$RUN_SCRIPT | tr -d '\r' > $INSTALL_DIR/$RUN_SCRIPT
     chmod +x $INSTALL_DIR/$RUN_SCRIPT
     $INSTALL_DIR/$RUN_SCRIPT
     echo 0 > $POWER_LED
     ;;
   "remove")
     shutdown -r now
     ;;
   *)
     echo "Usage: <add|remove> <device name>"
     ;;
esac

exit 0
