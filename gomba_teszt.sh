sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox chromium-browser
echo "installed dependencies"
sudo echo "# Disable any form of screen saver / screen blanking / power management
xset s off
xset s noblank
xset -dpms

# Allow quitting the X server with CTRL-ATL-Backspace
setxkbmap -option terminate:ctrl_alt_bksp

# Start Chromium in kiosk mode
sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/' ~/.config/chromium/'Local State'
sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/; s/\"exit_type\":\"[^\"]\+\"/\"exit_type\":\"Normal\"/' ~/.config/chromium/Default/Preferences
chromium-browser --disable-cpu --noerrdialogs --incognito --disable-session-crashed-bubble --disable-infobars --disable translate --kiosk --kiosk 'https://gombaszog.github.io/programscreen'" >> /etc/xdg/openbox/autostart

echo "[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -nocursor" >> .bash_profile
echo "installed config. you can restart the pi now."
#[Desktop Entry]
#Encoding=UTF-8
#Type=Application
#Exec=/usr/bin/chromium-browser --disable-cpu --noerrdialogs --incognito --disable-session-crashed-bubble --disable-infobars --disable translate --kiosk https://gombaszog.github.io/programscreen
#Hidden=false
#X-GNOME-Autostart-enabled=true
#Name[en_US]=AutoChromium
#Name=AutoChromium

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