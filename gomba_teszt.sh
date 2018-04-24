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
chromium-browser --disable-cpu --noerrdialogs --incognito --disable-session-crashed-bubble --disable-infobars --disable translate --kiosk --kiosk 'https://gombaszog.github.io/programscreen'" | sudo tee -a /etc/xdg/openbox/autostart
echo "config added to /etc/xdg/openbox/autostart (for chrome autostart)"

echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -nocursor' | sudo tee -a /home/pi/.bash_profile
echo "config added to ~/.bash_profile (for X server autostart)"

sudo timedatectl set-timezone Europe/Budapest
echo "timezone is now set to Europe/Budapest"

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
	 }" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
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

#Old config
#[Desktop Entry]
#Encoding=UTF-8
#Type=Application
#Exec=/usr/bin/chromium-browser --disable-cpu --noerrdialogs --incognito --disable-session-crashed-bubble --disable-infobars --disable translate --kiosk https://gombaszog.github.io/programscreen
#Hidden=false
#X-GNOME-Autostart-enabled=true
#Name[en_US]=AutoChromium
#Name=AutoChromium


#https://die-antwort.eu/techblog/2017-12-setup-raspberry-pi-for-kiosk-mode/
# Disable any form of screen saver / screen blanking / power management
#xset s off
#xset s noblank
#xset -dpms

# Allow quitting the X server with CTRL-ATL-Backspace
#setxkbmap -option terminate:ctrl_alt_bksp

# Start Chromium in kiosk mode
#sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/'Local State'
#sed -i 's/"exited_cleanly":false/"exited_cleanly":true/; s/"exit_type":"[^"]\+"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences
#chromium-browser --disable-infobars --kiosk 'https://gombaszog.github.io/programscreen'