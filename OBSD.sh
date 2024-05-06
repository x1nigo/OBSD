#!/bin/sh

# This is a post-install script for a new OpenBSD system.
# You must be root to run this script!

repodir="https://github.com/x1nigo"

id=$(whoami)
[ $id != "root" ] && echo "You need to be root." && exit

adduserandpass() {
	printf "%s" "Enter username: "
	read -r name
	useradd -m "$name"
	printf "%s" "Enter password: "
	read -r pass1
	printf "%s" "Enter pw again: "
	read -r pass2
	[ $pass1 != $pass2 ] && echo "Incorrect." && exit
	echo "$pass1\\n$pass1" | passwd
	unset pass1 pass2
}

add_pkgs() {
	for prog in $(cat OBSD-progs.txt); do
		pkg_add "$prog"
	done
}

suckless() {
	mkdir -p /home/$name/.local/src && cd /home/$name/.local/src
	for repo in $(echo "dwm st dmenu"); do
		git clone "$repodir"/"$repo".git
	done
}

updateutils() {
	echo "kern.audio.record=1
kern.video.record=1" >> /etc/sysctl.conf
	chown $name /dev/video0
	echo "mouse.tp.tapping=1
mouse.reverse_scrolling=1" >> /etc/wsconsctl.conf
}

clean() {
	cd # Return to root directory
	rm -r ~/OBSD
	rm -r "$repodir"/dotfiles
}

finalize() {
	echo "Congratulations! You now have a fully functioning OpenBSD system.

One quick reminder however, you need to manually compile the
suckless software before you can use this system. When
complete, enter \"startx\".

Other than that, you're good to go!"
}

# Main Install

adduserandpass
echo "permit keepenv nopass :$name" >> /etc/doas.conf
add_pkgs
suckless
git -C /home/$name/.local/src clone "$repodir"/dotfiles.git
rsync -r /home/$name/.local/src/dotfiles/.config /home/$name/
rsync -r /home/$name/.local/src/dotfiles/.local /home/$name/
clean
finalize
