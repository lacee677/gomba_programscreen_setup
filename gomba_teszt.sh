#!/bin/bash

sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox chromium-browser
echo "dependencies installed"
echo "
# Disable any form of screen saver / screen blanking / power management
xset s off
xset s noblank
xset -dpms

# Allow quitting the X server with CTRL-ATL-Backspace
setxkbmap -option terminate:ctrl_alt_bksp

# Start Chromium in kiosk mode
sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/' ~/.config/chromium/'Local State'
sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/; s/\"exit_type\":\"[^\"]\+\"/\"exit_type\":\"Normal\"/' ~/.config/chromium/Default/Preferences
chromium-browser --disable-accelerated-2d-canvas --disable-breakpad --disable-infobars --noerrdialogs --disable-gpu --incognito --lang-hu --kiosk 'https://gombaszog.github.io/programscreen'" | sudo tee /etc/xdg/openbox/autostart > /dev/null
echo "config added to /etc/xdg/openbox/autostart (for chrome autostart)"

echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -nocursor' | sudo tee /home/pi/.bash_profile > /dev/null
echo "config added to ~/.bash_profile (for X server autostart)"

sudo timedatectl set-timezone Europe/Budapest
echo "timezone is now set to Europe/Budapest"

export LANG=es_ES.UTF-8
echo "language changed to hungarian"

cat /etc/inittab | sed "s/1:2345:respawn:\/sbin\/getty 115200 tty1/#1:2345:respawn:\/sbin\/getty 115200 tty1\n1:2345:respawn:\/bin\/login -f pi tty1 <\/dev\/tty1 >\/dev\/tty1 2>\&1/g" | sudo tee testfile > /dev/null
echo "autologin enabled"

echo "Network priority will be from first added to last"
count=1
input=""
while [ "$input" != "done" ]
do
	echo -n "Network name: "
	read networkName
	echo -n "Network password: "
	read -s passWord
	echo "
	network={
	     ssid=\"$networkName\"
	     psk=\"$passWord\"
	     priority=$count
	     id_str=\"$networkName\"
	 }" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
	 echo "Network $networkName added to file"
	 echo -n "If no more network(s) remaining type done: "
	 read input
	(( count++ ))
done
if [ $count -gt 1 ] 
then
	echo "wifi network(s) added to /etc/wpa_supplicant/wpa_supplicant.conf"
fi

echo "script finished. You can restart the PI now (reboot)"

#https://die-antwort.eu/techblog/2017-12-setup-raspberry-pi-for-kiosk-mode/
#the --disable-translate, -disable-session-crashed-bubble flags were removed from chromium
#https://peter.sh/experiments/chromium-command-line-switches/