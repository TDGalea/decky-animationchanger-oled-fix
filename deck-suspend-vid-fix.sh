#!/bin/bash

# Decky AnimationChanger suspend vid fix for Steam Deck OLED. 2025-02-06_02
# Backs up the original files (appending ".orig" to their filename), then creates a symlink to the AnimationChanger suspend videos, if they exist.
# Can also restore the originals, undoing all changes.
#
# While I have tried to make this script as fool-proof and self-explanitory as possible, feel free to contact me on Discord (galea011) if you need any help.
# I may not be quick to reply, but I typically will do so.

original="/home/deck/.local/share/Steam/steamui/movies"
override="/home/deck/.local/share/Steam/config/uioverrides/movies"
suspendVidList="deck-suspend-animation.webm oled-suspend-animation.webm steam_os_suspend.webm"
throbberVidList="deck-suspend-animation-from-throbber.webm oled-suspend-animation-from-throbber.webm steam_os_suspend_from_throbber.webm"

# If this script has been piped into Bash via cURL, download itself and run locally. Things like 'read' fail to run, otherwise.
if [[ "$(basename $0)" == "bash" ]]; then
	wget https://tdgalea.co.uk/s/deck-suspend-vid-fix.sh &&	\
	chmod +x deck-suspend-vid-fix.sh && \
	printf "\n\nScript has been downloaded to your current directory, and made executable.\n" && \
	printf "You can now type: ./deck-suspend-vid-fix.sh\n" || \
	printf "Failed to download script to your current directory. Make sure you're not in a read-only folder.\n"
	exit 0
fi

quit(){
	tput cnorm
	[[ -z $1 ]] && exit 0 || exit $1
}

fq(){
	printf "\n\nForce quitting. Don't blame me for any issues!\n"
	quit
}


### Apply / restore functions.

applyLinks(){
	for vid in $suspendVidList; do
		if [[ -f "$original/$vid.orig" ]]; then
			printf "\e[1;33mNOTE:\e[0m Backup for '$vid' already exists. Leaving this alone. If you're having issues, restoring backups first might help.\n"
		else
			printf "Backing up '$vid': "
			mv "$original/$vid" "$original/$vid.orig" >/dev/null 2>&1
			if [[ $? -eq 0 ]]; then
				printf "\e[32msuccess\e[0m.\nCreating symlink: "
				ln -s "$override/deck-suspend-animation.webm" "$original/$vid" >/dev/null 2>&1 && printf "\e[32mdone\e[0m.\n" || printf "\e[31mfailed\e[0m.\n"
			else
				printf "\e[31mfailed\e[0m. Not creating symlink. If you're having issues, restoring backups first might help.\n"
			fi
		fi
	done
	for vid in $throbberVidList; do
		if [[ -f "$original/$vid.orig" ]]; then
			printf "\e[1;33mWARN:\e[0m Backup for '$vid' already exists. Leaving this alone. If you're having issues, restoring backups first might help.\n"
		else
			printf "Backing up '$vid': "
			mv "$original/$vid" "$original/$vid.orig" >/dev/null 2>&1
			if [[ $? -eq 0 ]]; then
				printf "\e[32msuccess\e[0m.\nCreating symlink: "
				ln -s "$override/deck-suspend-animation-from-throbber.webm" "$original/$vid" >/dev/null 2>&1 && printf "\e[32mdone\e[0m.\n" || printf "\e[31mfailed\e[0m.\n"
			else
				printf "\e[31mfailed\e[0m. Not creating symlink. If you're having issues, restoring backups first might help.\n"
			fi
		fi
	done
	quit 0
}

restoreOriginal(){
	for vid in $suspendVidList; do
		if [[ -f "$original/$vid.orig" ]]; then
			printf "Restoring '$vid': "
			mv "$original/$vid.orig" "$original/$vid" >/dev/null 2>&1 && printf "\e[32msuccess\e[0m.\n" || printf "\e[31mfailed\e[0m. It might be time for a clean slate.\n"
		else
			printf "\e[1;33mNOTE:\e[0m Backup of '$vid' not found. It might be time for a clean slate.\n"
		fi
	done
	for vid in $throbberVidList; do
		if [[ -f "$original/$vid.orig" ]]; then
			printf "Restoring '$vid': "
			mv "$original/$vid.orig" "$original/$vid" >/dev/null 2>&1 && printf "\e[32msuccess\e[0m.\n" || printf "\e[31mfailed\e[0m. It might be time for a clean slate.\n"
		else
			printf "\e[1;33mNOTE:\e[0m Backup of '$vid' not found. It might be time for a clean slate.\n"
		fi
	done
	quit 0
}

cleanSlate(){
	cd /home/deck/.local/share/Steam/steamui
	printf "Downloading archive of original 'movies' folder: "
	wget "https://raw.githubusercontent.com/TDGalea/decky-animationchanger-oled-fix/refs/heads/main/original-videos.7z" >/dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		printf "\e[32msuccess\e[0m.\nRemoving current original 'movies' folder: "
		rm -r movies >/dev/null 2>&1
		if [[ $? -eq 0 ]]; then
			printf "\e[32msuccess\e[0m.\nExtracting archive: "
			7z x original-videos.7z >/dev/null 2>&1
			[[ $? -eq 0 ]] && printf "\e[32msuccess\e[0m.\n" || printf "\e[31mfailed\e[0m. You might need to do things manually. Contact me if you need help.\n"
		else
			printf "\e[31mfailed\e[0m. You might need to do things manually. Contact me if you need help.\n"
		fi
		rm "original-videos.7z"
	else
		printf "\e[31mfailed\e[0m. You might need to do things manually. Contact me if you need help.\n"
	fi
}

chooseYN(){
	unset choice
	until [[ "${choice,,}" == "y" ]] || [[ "${choice,,}" == "n" ]]; do
		printf "\r[Y/N]:   \r[Y/N]: "
		read -n1 choice
	done
}


### Main functionality.
trap 'fq' SIGINT SIGHUP SIGTERM
tput civis

# Lazy method of ensuring this is a Steam Deck.
if [[ ! -d /home/deck ]]; then
	printf "This does not seem to be a Steam Deck!\nAre you sure you want to continue?\n"
	printf "(As much as I am usually willing to help, don't blame me for any issues!)\n"
	chooseYN; printf \\n
	[[ "${choice,,}" == "n" ]] && quit 0
fi

# Ask if we're applying links or restoring originals.
printf "What do you want to do? Press a number to choose.\n"
printf -- "1) Apply symlinks (fix AnimationChanger)\n"
printf -- "2) Restore backups (unfix AnimationChanger)\n"
printf -- "3) Clean slate (completely remove and re-download 'movies' folder)\n"
valid=0
until [[ $valid -eq 1 ]]; do
	printf "\r >    \r > "
	read -n1 choice
	case $choice in
		1) valid=1; printf \\n\\n; applyLinks;;
		2) valid=1; printf \\n\\n; restoreOriginal;;
		3) valid=1; printf \\n\\n; cleanSlate;;
	esac
done

quit 0
