By default, udev assigns the enumerated USB devices to group plugdev, so first you'll need to add yourself to that group.

### Adding username to plugdev group if not already added

1. `sudo usermod -a -G plugdev <YOUR USERNAME>`  or `sudo usermod -a -G dialout <YOUR USERNAME>` depending on your distribution/OS
2. Log out of Linux (sorry, this is necessary) 
3. Log back in
4. Run `groups` and check `plugdev` is listed


Now, you'll need to set up the udev rules to create a symlink from /dev/ttyARTY0 and /dev/ttyARTY1 to whatever /dev/ttyUSB device udev assigns to your ARTY. 

### Setting up udev rules for ARTY7

1. `sudo cp 99-arty.rules /etc/udev/rules.d`
2. `sudo udevadm control --reload-rules`
3. `sudo udevadm trigger`
4. `ls -alh /dev/ttyARTY*`


