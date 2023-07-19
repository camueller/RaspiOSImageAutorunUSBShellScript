# Raspberry Pi OS Image with auto-mount/auto-run of shell script located on USB flash drive

The shell script [buildImage.sh](buildImage.sh) downloads a [Raspberry Pi OS](https://www.raspberrypi.org/software/operating-systems) image and does the following modifications:
- enable SSH
- create default user "pi" (password: "raspberry")
- add a [udev rule](usbScriptRunner.rules) to trigger execution of the shell script [usbScriptRunner.sh](usbScriptRunner.sh) when an USB flash drive is connected/disconnected
- copy the shell script [usbScriptRunner.sh](usbScriptRunner.sh) to `/usr/local/bin` on the image

The **modified image** is provided as release with release number matching the release date and version of the original Raspberry Pi OS image (e.g. `2020.12.02-lite`).

## Pupose

The modified image enables fully unattended installation of software on top of a fresh Raspberry Pi OS image.

## More details

Once a USB flash drive is connected to the Raspberry Pi the `udev` daemon executes the shell script [usbScriptRunner.sh](usbScriptRunner.sh) which:
- mounts the USB flash drive
- scans the files on the USB flash drive for files like `*.sh`, sorts them and copies the first to `/tmp`
- executes the shell script copied to `/tmp`
- turns off the power led in order to signal the end of exectution 

Once the USB flash drive is disconnected from the Raspberry Pi the shell script [usbScriptRunner.sh](usbScriptRunner.sh) triggers a reboot of the Raspberry Pi.

## Example
  
The project [Smart Appliance Enabler](https://github.com/camueller/SmartApplianceEnabler) uses the modified image for a two phase install. For the installation process the following files have to be placed on a USB flash drive:

- [install.sh](https://raw.githubusercontent.com/camueller/SmartApplianceEnabler/master/install/install.sh) - the script to be executed by [usbScriptRunner.sh](usbScriptRunner.sh). It 
  * copies `install2.sh` and `install.config` to `/tmp` for the second installation phase 
  * moves `/etc/rc.local` away and creates a replacement in order to trigger `install2.sh` after reboot
  * enable Wifi with SSID/PSK provided in `install.config`
- [install2.sh](https://raw.githubusercontent.com/camueller/SmartApplianceEnabler/master/install/install2.sh) is executed from `/etc/rc.local` after Reboot and represents the second installation phase. It updates all packages, installs additional packages and downloads/installs/configures additional software. Finally it restores the original `/etc/rc.local` and performs clean up.
- [install.config](https://raw.githubusercontent.com/camueller/SmartApplianceEnabler/master/install/install.config) contains a few parameters users may change to configure the installation process

## TODO
- automatic checking for new Raspberry Pi OS build and subsequent created of a corresponding modified image
