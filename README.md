<h1>Build PostMarketOS for NothingPhone 1 SpaceWar</h1> <br>

<br><br><h1>Notice: Builds now, but it fails to start the GUI ._.</h1>
<br>to get a terminal, hold <code>Vol -</code> and press  <code>Power</code> 3 times<br>
As for how to get this back to a usable state, I'm going to have to study the DTB of the working one.
<br>
<br>

(Sometimes*) Builds images on:<br>
Debian Trixie<br>
(Rest to be tested)<br>
<br>


<h2>Dependencies</h2>
For Debian 13 (Trixie) on a fresh install, You'll need the following depends:<br>
<code>sudo apt-get install git kpartx flex bison</code>
<br>


<h2>To download and initialise</h2>
Open a terminal and run:<br>
<code>mkdir pmos
cd pmos
git clone https://github.com/Ordinary-Ladess/nothing-spacewar-pmos-build-universal-script.git $PWD
chmod +x pmdebug
./pmdebug init
</code>
<br>

<h2>To build images</h2>
Open a terminal in the pmos directory and run:<br>
<code>./build</code>

<h2>To install onto phone</h2>
Keep the terminal open<br>
Make sure the phone's bootloader is unlocked,<br>
Enter into fastboot <code>Power + Vol -</code><br>
In the same terminal, run:<br>
<code>cd out
./flashpmos.sh
</code>
<br>

<h2>Issues that might happen:</h2>
password appears on terminal,<br>
work around: delete your bash history, reboot PC, etc<br>
In pmbootstrap, downloading packages randomly fail.<br>
This seems to happen on my older laptop and increasing<br>
timeout on pmbootstrap makes things better.<br>
I had to increase the timeout from 6000 to 99000.<br>
It did work fine the first time I added a delay, but<br>
on a fresh install, it's more flakey. However, YMMV.<br>
*Repeatedly rerunning sometimes gets a good build.<br>
<br>
Bad images, this can happen in Git-Action builds anyway.<br>
boots but no GUI, currently regressed state of things ._.<br>
