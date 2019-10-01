# Arch Linux Bootstrap script
#
# Author: John Hammond
# Date:   October 1st, 2019
#
# This script is meant to help set up and install all the tools
# and configuration that I need to get Arch Linux up and running
# quickly and easily.

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


###############################################################


function configure_x(){
	echo_green "Configuring X"
	echo "exec i3" > ~/.xinitrc
	cp Xresources ~/.Xresources
}

function configure_terminator(){
	echo_green "Configuring Terminator"
	cp terminator_config ~/.config/terminator/config
}

function configure_bashrc(){
	echo_green "Getting default .bashrc"

	cp bashrc ~/.bashrc
	. ~/.bashrc
}

function configure_tmux(){
	echo 'source "$HOME/.bashrc"' > ~/.bash_profile
	cp tmux.conf ~/.tmux.conf
}

function configure_vim(){
	echo_green "Configuring vim..."
	curl -sfLo ~/.vim/autoload/plug.vim --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

	cp vimrc ~/.vimrc
	vim ~/.vimrc +PlugInstall +q +q
}

function configure_git(){
	git config --global core.editor "vim"
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

pre_install
install_niceties
configure_x
configure_terminator
configure_bashrc
configure_tmux
configure_vim
configure_git
