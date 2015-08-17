#!/bin/bash
# Authors:
#   Nathan Dyer <mail@nathandyer.me>
#
# Featuring the icons created by Mr. Magical, also licensed under the GPL.
# You can find the originals at:
#	http://gnome-look.org/content/show.php/Dropbox+for+Elementary+%235?content=134298
#
# This script free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; version 3.
#
# This file is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <https://www.gnu.org/licenses/gpl-3.0.txt>

# Installs icons
function icons {
ls
if [[ -d icons ]]; then
	echo "Copying icons..."
	cp -rT icons /usr/share/icons/elementary/
	echo "Updating the icon cache"
	gtk-update-icon-cache /usr/share/icons/elementary
	echo ""
	echo "elementary Dropbox icons have been installed."
else
	echo "Error installing icons: icons directory missing" >&2
fi
exit 0
}

# Downloads and installs Dropbox
function inst {

# Check 64 vs 32 bit
if [ $(uname -m) == 'x86_64' ]; then
	cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
else
	cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86" | tar xzf -
fi

# Finish installation and launch Dropbox
echo ""
echo "The Dropbox login screen should appear. Sign in and retry this script."
~/.dropbox-dist/dropboxd start &
exit 2

}





clear
echo '#-----------------------------------------#'
echo '#     elementary Dropbox Modifications    #'
echo '#-----------------------------------------#'

# Check for admin rights
if [[ "$(id -u)" = "0" ]]; then
	echo "This script is running as root."
	echo "You cannot install or modify dropbox as root."
else
	echo "This script does not have root privileges."
	echo "If you wish to install custom icons re-run this script with root privileges."
fi

# If root, install the custom icons and exit
if [[ "$(id -u)" = "0" ]]; then
	echo ""
	read -p "Would you like the install the custom icons? (Y)es, (N)o : " INPUT
	case $INPUT in
		[Yy]* ) icons;;
		[Nn]* ) exit 0;;
	    * )
	    clear && echo "Sorry, try again." >&2
	    main
	    ;;
	esac
fi

# Check to make sure the Dropbox dist folder exists
if [[ -d ~/.dropbox-dist ]]; then
	CURRENT=$PWD
	cd ~/.dropbox-dist
	echo ""
	echo "Backing up original dropboxd file..."
	cp dropboxd dropboxd.bak
	echo ""
	echo "Modifying dropboxd file..."
	awk 'NR==2{print "XDG_CURRENT_DESKTOP=Unity"}7' dropboxd > temp
	echo "XDG_CURRENT_DESKTOP=Pantheon" >> temp
	cp temp dropboxd
	rm temp
    cd $CURRENT
    # Does the desktop file exist?
    if [[ -e dropbox.desktop ]]; then
        echo ""
        echo "Adding Dropbox to the list of autostart applications."
        echo "Exec=$HOME/.dropbox-dist/dropboxd" >> dropbox.desktop
        cp dropbox.desktop ~/.config/autostart/dropbox.desktop
    fi
else
	echo "This script requires that Dropbox be installed." >&2
	echo ""
	read -p "Would you like this script to attempt to install Dropbox for you? (Y)es, (N)o : " INPUT
	case $INPUT in
		[Yy]* ) inst;;
		[Nn]* ) exit 1;;
	    * )
	    clear && echo "Sorry, try again." >&2
	    main
	    ;;
	esac
	exit 1
fi

# Restart dropbox
echo "Restarting dropbox..."
# Unfortunately, just calling ~/.dropbox-dist/dropboxd stop doesn't work during install
killall dropbox	
~/.dropbox-dist/dropboxd start &

echo ""
echo "elementary Dropbox modifications complete."
echo ""
