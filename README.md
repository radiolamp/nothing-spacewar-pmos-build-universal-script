<h1>Build PostMarketOS for NothingPhone 1 SpaceWar</h1> <br>

<br><br><h1>Notice: Building is very broken for some reason, even GitHub servers aren't fast enough to overcome package download stages failing</h1>
<br>I'll be seeing if I can get some advice, but this project maybe put on hold for months due to time.<br>
I've figured out a fix for the sudo issue, it's quite insecure versus if we had some kind of 'sudo --passwordless-session' or something, but broken will work better than nothing.<br>

(Sometimes*) Builds images on:<br>
Debian Trixie<br>
(Rest to be tested)<br>
<br>


<h2>Dependencies</h2>
For Debian 13 (Trixie) on a fresh install, You'll need the following depends:<br>
<code>sudo apt-get install git kpartx flex bison</code>
<br>


<h2>To download and build</h2>
Open a terminal and run:<br>
<code>mkdir pmos
cd pmos
git clone https://github.com/Ordinary-Ladess/nothing-spacewar-pmos-build-universal-script.git $PWD
chmod +x *.sh
./build.sh
</code>
<br>


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
In pmbootstrap, downloading packages randomly fail.<br>
This seems to happen on my older laptop and increasing<br>
timeout on pmbootstrap makes things better.<br>
I had to increase the timeout from 6000 to 99000.<br>
It did work fine the first time I added a delay, but<br>
on a fresh install, it's more flakey. However, YMMV.<br>
*Repeatedly rerunning sometimes gets a good build.<br>
<br>
Bad images, this can happen in Git-Action builds anyway.<br>
