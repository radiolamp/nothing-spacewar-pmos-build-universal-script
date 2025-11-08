This git should contain an action to generate PMOS for the Nothing Phone 1

However, my focus is on making build.sh be more portable as it currently only runs on someone'sm Ubuntu install.<br>
Debian is my first goal, at least.

Current status on my computer:<br>
script works up to build-images, pmbootstrap fails the build-images stage. <br>
Not the fault of the script, so the final copy and compress stages are untested.

On debian Trixie, the following need installing at least (I might of missed something, will suss that on a VM later):<br>
sudo apt-get install flex bison kpartx git<br>
and at least a GCC, presumably the latest.

How to use (Debian Trixie):<br>
1 - download build.sh and nothing-spacewar.cfg (or download the other .cfg for phosh or Plasma and rename it to nothing-spacewar.cfg)<br>
2 - create a folder to contain the script and configs as well as the pmbootstrap files downloaded.<br>
3 - open a terminal in that folder and make executable; chmod +x build.sh<br>
4 - run the script: ./build.sh<br>
5 - if all goes well, you should have the boot and root-fs images.<br>
6 - follow below from 5 onwards.<br>

<br><br>
For git-action generated images (mostly original from Nonta72, with my reccomends added):<br>
How to install ?

1. Login to your github account
2. Go to Actions tab
3. Download the most recent build 
4. Extract the archive
5. Flash boot to boot partition
6. Flash rootfs to userdata partition
7. wipe dtbo with i.e. #fastboot erase dtbo 
8. Reboot

Assume all black-screen hangs and random reboots for the next 10 minutes are due to rootfs unpacking itself into the full userdata partition space.

Deleting vendor_boot hasn't been tested by myself as I haven't gone back to Blandroid

CoC:<br>
No ai!<br>
Yes I use dashes as seperators in bullet points and numbering, I'll not accuse others of Ai-ing for doing the same.
