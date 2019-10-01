Installing Arch Linux
======================

> John Hammond | September 29th, 2019

This are my notes while installing and setting up my Arch Linux environment.

I did this on my DELL XPS 15 laptop on September 29th, 2019.


Downloading the ISO
-------------------

I downloaded the `archlinux-2019.09.01-x86_64.iso` from here: [https://www.archlinux.org/download/](https://www.archlinux.org/download/).
I searched for a United States mirror and chose one: specifically, I used: [http://mirrors.acm.wpi.edu/archlinux/iso/2019.09.01/](http://mirrors.acm.wpi.edu/archlinux/iso/2019.09.01/)



Burning the ISO to a Disc
-------------------------

I still had Ubuntu at the time, so I burned the Arch Linux ISO to a disc with [Brasero]. 



Booting the Arch Linux Live Disc
------------------------

On my DELL XPS 15, I needed to spam the `F12` key when booting to get to the menu and choose "Boot from CD". **I made sure to boot in UEFI**.

Once I got into the Arch Linux prompt, I followed the instructions from their [Installation Guide](https://wiki.archlinux.org/index.php/installation_guide).

I didn't need to change the keyboard layout, so I went on just to verify the UEFI boot mode:

```
ls /sys/firmware/efi/efivars
```

This had results, so I knew I successfully booted with UEFI. Good enough!



Connecting to the Internet
----------------

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

Updating the Time Service
----------------------

```
timedatectl set-ntp true
```

Partitioning the Disks
----------------------

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

Mounting the Filesystem
-------------------

```
mount /dev/nvmen1p2 /mnt
```

Installing Arch
-------------

```
pacstrap /mnt base
```

Configure the system
-------------

```
genfstab -U /mnt >> /mnt/etc/fstab
```

Chroot into the new filesystem
----------------

```
arch-chroot /mnt
```

Setting the timezone
--------------

```
ln -sf /usr/share/zoneinfo/EST5EDT /etc/localtime
hwclock --systohc
```

Localization
------------

```
sed 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

Hostname
----------

```
echo arch > /etc/hostname

cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1	      localhost
127.0.1.1 arch.localdomain arch
EOF
```

Set root passwd
----------

```
passwd
```

Install GRUB
---------

```
pacman -Sy grub os-prober
```

**When I was installing via virtual machine, I just needed to:**

```
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

**When I was installing on my hard drive I did:**

```
grub-install /dev/nvmen1p3
grub-mkconfig -o /boot/grub/grub.cfg
```


**DO NOT forget to copy over a network profile for `netctl` and install `netctl` and `network-manager`
so you still have internet access when you reboot into the real system** 

Adding a new user
---------------------

```
mkdir /home/john
useradd john
passwd john
```

Getting Internet
----------------

When I was on a virtual machine, I needed to run these commands to get an IP address.

```
dhcpcd
dhcpcd -4
```

Installing Sudo
----------------

```
pacman -Sy sudo
```

Installing Audio Drivers
--------------------

```
sudo pacman -Sy pulseaudio pavucontrol
```


I needed to restart my computer after running these commands for the sound to start.
(There was probably a service, but I couldn't find it...)


Getting yay and AUR Support
----------

First get ready to work with PKGBUILD files:

```
sudo pacman -S --needed base-devel
```

Then get `yay`:

```
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```


Correcting .bashrc
------------------

I copy and pasted the default Ubuntu bashrc from here:

* [https://gist.github.com/indrakaw/1fdbc51639081216f04a025b1add2506](https://gist.github.com/indrakaw/1fdbc51639081216f04a025b1add2506)

Installing tmux
---------------

```
pacman -Sy tmux
echo 'source "$HOME/.bashrc"' > ~/.bashrc
```

Installing xrandr
----------------

```
pacman -S xorg-xrandr
```

Setting proper monitor size
--------------------------

```
xrandr --output DP-3 --scale 2x2 --mode 2560x1080
```	


Getting monokai in vim
----------------------


First I downloaded vim-plug. [https://github.com/junegunn/vim-plug](https://github.com/junegunn/vim-plug)

```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Then, I could modify my `~/.vimrc` file to what it is now.
Then I would run `:PlugInstall` from within vim and it would install the module for me.

Tmux would act strange though -- I would need to be sure to remove all of the tmux
sessions before I could see the vim changes take effect.

```bash
tmux ls # to see the running sessions
tmux kill-session -t 2   # to kill the other sessions
```

Installing OBS-Studio
--------------

```
yay -S obs-studio
```

Installing FontAwesome
-----------------------

```
yay -S ttf-font-awesome
```


> This is incomplete. I need to keep working on this (1109 September 30th 2019)


