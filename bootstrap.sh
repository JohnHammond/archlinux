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
	echo "${COLOR_RED}${BOLD}$1${COLOR_RESET}i"
}

function echo_green(){
	echo "${COLOR_GREEN}${BOLD}$1${COLOR_RESET}"
}

echo_green "Hello everyone"
