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


> This is incomplete. I need to keep working on this (1109 September 30th 2019)

[Brasero]: https://wiki.gnome.org/Apps/Brasero
