Setting up CoreOS is greatly documented, but for someone that just wants root access to a CLI, it's kinda painful to figure out. I didn't want to use the CoreOS API, but I wanted the benefits from the minimalistic Linux distro with docker installed by default.

Step 1: Boot the CoreOS Live CD (https://coreos.com/docs/running-coreos/platforms/iso/)
Step 2: Install CoreOS to the drive: https://coreos.com/docs/running-coreos/bare-metal/installing-to-disk/
Step 3: Unmount/Eject the CD and reboot.
Step 4: Press "E" at grub to edit the boot parameters
Step 5: On the line that has "load_coreos" add this parameter at the end of the line:
```
coreos.autologin=tty1
```
Step 6: Press CTRL+X or F10 to boot with modified parameters. Upon boot you will automatically be logged in as the "core" user.
Step 7: Elevate to root:
```
# sudo su -
```
Step 8: Reset passwords for root and core users:
```
# passwd root
....
# passwd core
...
```
Step 9: Reboot and test passwords.

After this I found that I could just SSH in and do my normal sys-admin thing. I ran CoreOS in a VirtualBox VM and booted it headlessly after setting up the VM.
