# Arch Linux Bootstrap script
#
# Author: John Hammond
# Date:   October 1st, 2019
#
# This script is meant to help set up and install all the tools
# and configuration that I need to get Arch Linux up and running
# quickly and easily.

NEW_USER=$1

# Define some colors for quick use...
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_BLUE=$(tput setaf 4)
COLOR_MAGENTA=$(tput setaf 5)
COLOR_CYAN=$(tput setaf 6)
COLOR_WHITE=$(tput setaf 7)
BOLD=$(tput bold)
COLOR_RESET=$(tput sgr0)

function echo_red(){
	echo "${COLOR_RED}${BOLD}$1${COLOR_RESET}"
}

function echo_green(){
	echo "${COLOR_GREEN}${BOLD}$1${COLOR_RESET}"
}

function echo_yellow(){
	echo "${COLOR_YELLOW}${BOLD}$1${COLOR_RESET}"
}

###############################################################


SUDO_DEPENDENCIES="sudo"
AUDIO_DEPENDENCES="pulseaudio pavucontrol"
GIT_DEPENDENCIES="git"
VIM_DEPENDENCIES="vim"
TMUX_DEPENDENCIES="tmux"
X_DEPENDENCIES="xorg-xinit xorg-server xorg-xrandr"
YAY_DEPENDENCINES="base-devel"
I3_DEPENDENCIES="i3 gnu-free-fonts"
TERMINATOR_DEPENDENCIES="terminator"
URXVT_DEPENDENCIES="rxvt-unicode"

DEPENDENCIES="\
 $SUDO_DEPENDENCIES \
 $AUDIO_DEPENDENCIES \
 $GIT_DEPENDENCIES \
 $VIM_DEPENDENCIES \
 $TMUX_DEPENDENCIES \
 $X_DEPENDENCIES \
 $YAY_DEPENDENCIES \
 $I3_DEPENDENCIES \
 $TERMINATOR_DEPENDENCIES \

"

##############################################################

function create_new_user(){
	pacman -Sy sudo --noconfirm
	id -u $NEW_USER > /dev/null

	if [ $? -eq 1 ]
	then
		echo_green "Creating new user $COLOR_BLUE$NEW_USER"

		mkdir /home/$NEW_USER
		useradd $NEW_USER
		echo_yellow "Please set the password for $COLOR_BLUE$NEW_USER:"
		passwd $NEW_USER
	else
		echo_green "New user already exists, using that account for everything"
	fi

	groupadd sudo
	usermod -aG sudo $NEW_USER
	sed -i 's/# %sudo/%sudo/g' /etc/sudoers
	echo "$NEW_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

	chown $NEW_USER:$NEW_USER /home/$NEW_USER
	chown -R $NEW_USER:$NEW_USER $(pwd)
	mv $(pwd) /home/$NEW_USER/archlinux
	cd /home/$NEW_USER/archlinux
}

function cleanup(){
	sed -i "s/$NEW_USER ALL=(ALL) NOPASSWD: ALL//g" /etc/sudoers
}

###############################################################


function configure_x(){
	echo_green "Configuring X"
	sudo -u $NEW_USER bash -c 'echo "exec i3" > ~/.xinitrc'
	sudo -u $NEW_USER bash -c 'cp Xresources ~/.Xresources'
}

function configure_terminator(){
	echo_green "Configuring Terminator"
	sudo -u $NEW_USER bash -c 'mkdir -p ~/.config/terminator'
	sudo -u $NEW_USER bash -c 'cp terminator_config ~/.config/terminator/config'
}

function configure_bashrc(){
	echo_green "Getting default .bashrc"

	sudo -u $NEW_USER bash -c 'cp bashrc ~/.bashrc'
	sudo -u $NEW_USER bash -c '. ~/.bashrc'
	cp bashrc /etc/bash.bashrc
}

function configure_tmux(){
	sudo -u $NEW_USER bash -c "echo 'source \"\$HOME/.bashrc\"' > ~/.bash_profile"
	sudo -u $NEW_USER bash -c 'cp tmux.conf ~/.tmux.conf'
}

function configure_vim(){
	echo_green "Configuring vim..."
	sudo -u $NEW_USER bash -c 'curl -sfLo ~/.vim/autoload/plug.vim --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'

	sudo -u $NEW_USER bash -c 'cp vimrc ~/.vimrc'
	sudo -u $NEW_USER bash -c 'vim ~/.vimrc +PlugInstall +q +q'

	# Add for the root user as well..
	curl -sfLo ~/.vim/autoload/plug.vim --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
	cp vimrc /etc/vimrc
	vim /etc/vimrc +PlugInstall +q +q
}

function configure_git(){
	sudo -u $NEW_USER bash -c 'git config --global core.editor "vim"'
	sudo -u $NEW_USER bash -c 'git config --global user.email "johnhammond010@gmail.com"'
	sudo -u $NEW_USER bash -c 'git config --global user.name "John Hammond"'
}

function configure_pacman(){
	cp mirrorlist /etc/pacman.d/mirrorlist
}

##############################################################

function prepare_opt(){
	chown $NEW_USER:$NEW_USER /opt
}

function install_yay(){
	pacman -Sy --needed base-devel --noconfirm
	pushd /opt/
	git clone https://aur.archlinux.org/yay.git

	chown $NEW_USER:$NEW_USER /opt/yay
	cd yay
	sudo -u $NEW_USER bash -c 'cd /opt/yay/ && yes|makepkg -si'
	popd
	sudo -u $NEW_USER bash -c 'yes|yay'
}

###############################################################

function set_timezone(){
	echo_green "Setting timezone to EST5EDT"

	ln -sf /usr/share/zoneinfo/EST5EDT /etc/localtime
	hwclock --systohc
}

function set_locale(){
	echo_green "Setting locale"
	sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
	echo "LANG=en_US.UTF-8" > /etc/locale.conf
	locale-gen
}

function set_hostname(){
	echo_green "Setting hostname"

	echo arch > /etc/hostname
	cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1	      localhost
127.0.1.1 arch.localdomain arch
EOF

}

function pre_install(){
	set_timezone
	set_locale
	set_hostname
}


function install_niceties(){
	pacman -Sy $DEPENDENCIES --noconfirm --color=always
}



if [ "$1" == "" ]
then
	echo_red "You must supply a username to use."
	echo "usage: $0 <new_username>"
	exit
fi

pre_install
create_new_user
configure_pacman
install_niceties
configure_x
configure_terminator
configure_bashrc
configure_tmux
configure_vim
configure_git
prepare_opt
install_yay

cleanup
