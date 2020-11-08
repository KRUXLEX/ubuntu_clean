#!/bin/bash

check () {
    echo "$2, wynik: $1" 

	if [ "$1" -ne 0 ]; then
	echo "[ERROR] >>> Przerywam..." 
	exit 1
	fi
}

cd /var/log

### Cleaning APT Archives
echo
echo ">>> Clean APT's"
apt clean
check $? ">>>>>> Done"
apt autoclean
check $? ">>>>>> Done"

### Deleting Old Kernels
echo
echo ">>> Clean Old Kernales"
apt-get autoremove --purge
check $? ">>>>>> Done"

# dpkg --list lista pakietów w systemie
# grep linux-image pokaż wyłącznie obrazy Linux czyli Kernele
# awk ‘{ print $2 }’ Pokazuj wyłącznie drugą kolumne (numer kernela)
# sort -V sortuj wyłącznie po wersji
# sed -n ‘/’`uname -r`’/q;p’ wyświetl wyłącznie linie poza używanym kernelem
# xargs sudo apt-get -y purge usuń stare kernele
dpkg --list | grep linux-image | awk '{ print $2 }' | sort -V | sed -n '/'`uname -r`'/q;p' | xargs sudo apt-get -y purge
check $? ">>>>>> Done"

### Cleaning Logs
echo
echo ">>> Clean Logs"
journalctl --vacuum-time=3d
check $? ">>>>>> Done"
echo "" > syslog
check $? ">>>>>> Done"
echo "" > daemon.log
check $? ">>>>>> Done"
echo "" > messages
check $? ">>>>>> Done"
echo "" > user.log
check $? ">>>>>> Done"

# Removes old revisions of snaps
echo
echo ">>> Clean a Old SNAPS"
# CLOSE ALL SNAPS BEFORE RUNNING THIS
set -eu
snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done

# Clean the thumbnail cache
echo
echo ">>> Clean The Thumbnail Cache"
rm -rf ~/.cache/thumbnails/*
check $? ">>>>>> Done"

# Clear Dropbox Cache
echo
echo ">>> Clean Dropbox Cache"
rm -rf /home/*/Dropbox/.dropbox.cache/*
check $? ">>>>>> Done"

# Find and remove duplicate files
echo
echo ">>> Clean Duplicate Files"
fdupes /
check $? ">>>>>> Done"