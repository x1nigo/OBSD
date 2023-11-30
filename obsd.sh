#!/bin/bash
#
#   ___  ____ ____  ____
#  / _ \| __ ) ___||  _ \
# | | | |  _ \___ \| | | |
# | |_| | |_) |__) | |_| |
#  \___/|____/____/|____/
#
# This is Chris Iñigo's bootstrapping script for OpenBSD.
# by Chris Iñigo <chris@x1nigo.xyz>

# Things to note:
# - Run this script as ROOT!
# TODO: Under construction...

# Variables
progsfile="https://raw.githubusercontent.com/x1nigo/OBSD/main/progs.csv"
dotfilesrepo="https://github.com/x1nigo/dotfiles.git"

error() {
	# Log to stderr and exit with failure.
	printf "%s\n" "$1" >&2
	exit 1
}

openingmsg() {
	printf "%s\n" "Welcome to Chris Iñigo's Bootstrapping Script for OpenBSD! This will install a fully-fledged OpenBSD desktop, which is rare and should work out of the box.\\n\\n-Chris"
	printf "%s\n" "Press Enter to continue."
	read -r
}

getuserandpass() {
	printf "%s" "Enter a username: "
	read -r name
	printf "%s" "Type in a strong and complicated password: "
	read -r password
}

preinstallmsg() {
	printf "%s\n" "This install will be automated from now on. Are you ready to begin?"
	printf "%s" "Press Enter to continue. Otherwise press Ctrl+C to cancel the script."
	read -r
}

adduserandpass() {
	useradd -m "$name"
	usermod -G wheel "$name"
	export repodir="/home/$name/.local/src"
	mkdir -p "$repodir"
	chown -R "$name":wheel "$(dirname "$repodir")"
	echo -e "$password\\n$password" || passwd "$name"
	unset password
}

finalize() {
	printf "%s\n" "Installation complete! If you see this message, then there's a pretty good chance that there were no errors. You may reboot this system and log in with your new username.\\n\\n-Chris"
}

### The Main Install ###

installpkgs() {
	[ ! -f ~/obsd/progs.csv ] && { curl -Ls "$progsfile" | sed '/^#/d' > /tmp/progs.csv } || { cat ~/obsd/progs.csv | sed '/^#/d' > /tmp/progs.csv }
	while IFS=, read -r tag program description
	do
		case $tag in
			G) doas "$name" git -C "$repodir" clone "$program" ;;
			*) pkg_add "$program" ;;
		esac
	done < /tmp/progs.csv
}

getdotfiles() {
}

setupbsd() {
	# Configure multimedia
	echo "kern.audio.record=1" >> /etc/sysctl.conf
	echo "kern.video.record=1" >> /etc/sysctl.conf

	# Configure tapping and natural scrolling
	echo "mouse.tp.tapping=1" >> /etc/wsconsctl.conf
	echo "mouse.reverse_scrolling=1" >> /etc/wsconsctl.conf
}

setdoas() {
	echo "permit persist keepenv :wheel
permit nopass :wheel cmd halt args -p
permit nopass :wheel cmd reboot
permit nopass :wheel cmd make args install
permit nopass :wheel cmd make args clean install
permit nopass :wheel cmd su" > /etc/doas.conf
}

### The Main Functions ###

# The opening message.
openingmsg || error "Failed to display opening message."

# Get the necessary vairables.
getuserandpass || error "Failed to get user and password."

# Last chance to change your mind.
preinstallmsg || error "Preinstall message unsuccessful."

# Add the user and their password.
adduserandpass || error "Failed to add user and password to system."

# Install the packages
installpkgs || error "Failed to install packages."

# Get dotfiles and configure such.
getdotfiles || error "Failed to install configuration files."

# Setup the working environment
setupbsd || error "Failed to setup the working environment."

# Configure doas permissions
setdoas || error "Failed to configure doas permissions."
