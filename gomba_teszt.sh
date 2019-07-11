#!/bin/sh

sudo apt-get update
sudo apt-get upgrade
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
chromium-browser --no-first-run --disable-accelerated-2d-canvas --disable-breakpad --disable-infobars --noerrdialogs --disable-gpu --incognito --lang-hu --kiosk 'https://program.gombaszog.sk/'" | sudo tee /etc/xdg/openbox/autostart > /dev/null
echo "config added to /etc/xdg/openbox/autostart (for chrome autostart)"

echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -nocursor' | sudo tee /home/pi/.bash_profile > /dev/null
echo "config added to ~/.bash_profile (for X server autostart)"

sudo timedatectl set-timezone Europe/Budapest
echo "timezone is now set to Europe/Budapest"

LOCALE="hu_HU.UTF-8"
if ! LOCALE_LINE="$(grep "^$LOCALE " /usr/share/i18n/SUPPORTED)"; then
  return 1
fi
ENCODING="$(echo $LOCALE_LINE | cut -f2 -d " ")"
echo "$LOCALE $ENCODING" | sudo tee /etc/locale.gen > /dev/null
sudo sed -i "s/^\s*LANG=\S*/LANG=$LOCALE/" /etc/default/locale
sudo dpkg-reconfigure -f noninteractive locales
echo "language changed to hungarian"

sudo systemctl set-default multi-user.target
#sudo sed /etc/systemd/system/autologin@.service -i -e "s#^ExecStart=-/sbin/agetty --autologin [^[:space:]]*#ExecStart=-/sbin/agetty --autologin pi#"
sudo ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service > /dev/null
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
