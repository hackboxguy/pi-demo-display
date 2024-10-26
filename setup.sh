#!/bin/sh
#./setup.sh -t 14.6 
USAGE="usage:$0 -t <type_of_display[14.6/15.6]>"
DISP_TYPE="none"

while getopts t: f
do
	case $f in
	t) DISP_TYPE=$OPTARG ;;
	esac
done

if [ $# -lt 2  ]; then
	echo $USAGE
	exit 1
fi

[ $DISP_TYPE = "none" ] && echo "missing display-type -t arg!" && exit 1

if [ $(id -u) -ne 0 ]; then
	echo "Please run setup as root ==> sudo ./setup.sh -n $SLAVE_NUM"
	exit
fi


#install dependencies
printf "Installing dependencies ................................ "
DEBIAN_FRONTEND=noninteractive apt-get update < /dev/null > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -qq ffmpeg mpv kodi kodi-eventclients-kodi-send < /dev/null > /dev/null
test 0 -eq $? && echo "[OK]" || echo "[FAIL]"

#printf "Enabling media-player service........................... "
#systemctl enable /home/pi/pi-demo-display/systemd-ffplaydemo.service 1>/dev/null 2>/dev/null
#systemctl start systemd-ffplaydemo.service 1>/dev/null 2>/dev/null
#test 0 -eq $? && echo "[OK]" || echo "[FAIL]"

printf "Setting up kodi......................................... "
runuser -l pi -c 'mkdir -p ~/.kodi/addons/service.autoexec'
runuser -l pi -c 'mkdir -p ~/.kodi/userdata/addon_data/skin.estuary/'
runuser -l pi -c 'cp kodi-files/addon.xml ~/.kodi/addons/service.autoexec'
runuser -l pi -c 'cp kodi-files/autoexec.py ~/.kodi/addons/service.autoexec'
runuser -l pi -c 'cp kodi-files/favourites.xml ~/.kodi/userdata/'
runuser -l pi -c 'cp kodi-files/settings.xml ~/.kodi/userdata/addon_data/skin.estuary/'
runuser -l pi -c 'cp kodi-files/guisettings.xml ~/.kodi/userdata/'

cp kodi-files/*.png /usr/share/kodi/media/
cp kodi-files/*.jpg /usr/share/kodi/media/
test 0 -eq $? && echo "[OK]" || echo "[FAIL]"

printf "Updating config.txt..................................... "
if [ $DISP_TYPE = "14.6" ]; then
	cp ./config-14-6.txt /boot/firmware/config.txt 
elif [ $DISP_TYPE = "15.6" ]; then
	cp ./config-15-6.txt /boot/firmware/config.txt 
else
	echo "Invalid Display type arg!"
	exit 1
fi
test 0 -eq $? && echo "[OK]" || echo "[FAIL]"

printf "Stitching demo-media-file............................... "
cat neo-qled-demo-?? > videos/neo-qled-demo-1.h264
test 0 -eq $? && echo "[OK]" || echo "[FAIL]"

printf "Enable Kodi at startup.................................. "
cp rc.local /etc/
test 0 -eq $? && echo "[OK]" || echo "[FAIL]"

sync
printf "Installation complete, reboot the system................ \n"
