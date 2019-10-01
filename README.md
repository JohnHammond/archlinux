Arch Linux
======================

> John Hammond | September 29th, 2019

These are my notes and scripts while installing and setting up my Arch Linux environment.

I did this on my DELL XPS 15 laptop on September 29th, 2019. Following that,
I began to set up a virtual machine for use at work. The virtual machine required
a little bit of a different setup, so I decided to write these things down
and try and automate the procedure.

--------------------------

The `bootstrap.sh` script
=================

This script is still in development, but it can be used to quickly take a 
freshly installed Arch Linux system to a fleshed-out and working state (per my own
idea of "usable").

> **NOTE:** The script is INCOMPLETE, and I will be continuously adding to it.

As of right now, the script will

* Set the locale, "arch" hostname, and EDT5EST timezone
* Create a new user (or use an existing one) you supply
* Configure `pacman` to use close mirrors
* Install:
	- sudo
	- pulseaudio (and pavucontrol)
	- git
	- vim
	- tmux
	- X (and xrandr)
	- base-devel
	- i3 (and gnu-free-fonts)
	- terminator
	- dmenu
	- firefox
	- yay
* Configure Terminator to use my prefered theme
* Configure tmux to run on start of a shell
* Configure X to start i3 and for the first TTY to start the desktop
* Configure Vim to use the Sublime Text Monokai colorscheme
* Configure git with my preferred name and e-mail (change this if you use this)
* Made the /opt directory writeable by the user (I like to store tools there)


You can run the script right after a fresh install and you set up GRUB. Replace
`john` with whatever username you want to be the one managing your system, that
you use from here on out.

```
./bootstrap.sh <john>
```


Installing
------------

**Downloading the ISO**

I downloaded the `archlinux-2019.09.01-x86_64.iso` from here: [https://www.archlinux.org/download/](https://www.archlinux.org/download/).
I searched for a United States mirror and chose one: specifically, I used: [http://mirrors.acm.wpi.edu/archlinux/iso/2019.09.01/](http://mirrors.acm.wpi.edu/archlinux/iso/2019.09.01/)


**Burning the ISO to a Disc**

I still had Ubuntu at the time, so I burned the Arch Linux ISO to a disc with [Brasero]. 
**Booting the Arch Linux Live Disc**

On my DELL XPS 15, I needed to spam the `F12` key when booting to get to the menu and choose "Boot from CD". **I made sure to boot in UEFI**.

Once I got into the Arch Linux prompt, I followed the instructions from their [Installation Guide](https://wiki.archlinux.org/index.php/installation_guide).

I didn't need to change the keyboard layout, so I went on just to verify the UEFI boot mode:

```
ls /sys/firmware/efi/efivars
```

This had results, so I knew I successfully booted with UEFI. Good enough!

When I did this on the virtual machine, I did not have results -- it had not booted
in UEFI. This did not end up mattering much.


**Connecting to the Internet**

On my DELL XPS 15, I wanted to connect to the Internet right away. To get started, I needed to know the name of the
interface I was working with.

```
ip link
```

In my case, my interface name was `wlp59s0`.

Now I needed to actually connect to my Wi-Fi. I used `netctl` to keep it easy.

```
cp /etc/netctl/examples/wireless-wpa /etc/netctl/home
vim /etc/netctl/home
```

With that configuration file, I could fill in the interface name, SSID, and Wi-Fi password.

```
net start home
```

At that point, I could connect to the Internet!

On the virtual machine, I did not need to set any of this up. Because the VM was 
either bridged or NAT-d, it should have Internet. I did run these commands to 
snag an IP address (and I often need to do this on boot for the VM):

```
dhcpcd
dhcpcd -4
```

**Updating the Time Service**

```
timedatectl set-ntp true
```

**Partitioning the Disks**

I used this command to determine which devices are set up already.

```
fdisk -l
```

In my case of my DELL XPS 15, I had `/dev/nvmen1p1`, `/dev/nvmen1p2` and `/dev/nvmen1p3` all set up (because I did have Ubuntu installed on this previously).

My `/dev/nvmen1p1` was the EFI partition for GRUB, `/dev/nvmen1p2` was my EXT4 filesystem, and `/dev/nvmen1p3` was my swapspace.

_If you needed to partition the drive manually, like you were setting up in a virtual machine, I would recommend using `cfdisk`._

In my case, I needed to format these partitions with their appropriate purposes.

```
mkfs.ext4 /dev/nvmen1p2
mkswap /dev/nvmen1p3
swapon /dev/nvmen1p3
```

I handled the `/dev/nvmen1p1` EFI partition later, when I would install GRUB.

In the case of the virtual machine, I would need to create these partitions "manually"
with

```
cfdisk
```

I created a 1 GB partition for swap space and another 1 GB for the boot loader (probably don't need that much...) and the rest I reserved for the filesystem.

I would then run the appropriate commands with `/dev/sda1`, `/dev/sda2`, etc.


**Mounting the Filesystem**

```
mount /dev/nvmen1p2 /mnt
```

**Installing Arch**

```
pacstrap /mnt base
```

**Configure the system**

```
genfstab -U /mnt >> /mnt/etc/fstab
```

**Chroot into the new filesystem**

```
arch-chroot /mnt
```

**Setting the root password**

```
passwd
```

**Install GRUB**

```
pacman -Sy grub os-prober
```

_When I was installing via virtual machine, I just needed to:_

```
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

_When I was installing on my hard drive I did:_

```
grub-install /dev/nvmen1p3
grub-mkconfig -o /boot/grub/grub.cfg
```

**DO NOT forget to copy over a network profile for `netctl` and install `netctl` and `network-manager`
so you still have internet access when you reboot into the real system** 


At this point, the `bootstrap.sh` script could be used.

