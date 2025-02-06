#!/bin/bash

# Decky AnimationChanger suspend vid fix for Steam Deck OLED. 2025-02-06_01
# Backs up the original files (appending ".orig" to their filename), then creates a symlink to the AnimationChanger suspend videos, if they exist.
# Can also restore the originals, undoing all changes.
#
# While I have tried to make this script as fool-proof and self-explanitory as possible, feel free to contact me on Discord (galea011) if you need any help.
# I may not be quick to reply, but I typically will do so.

official=/home/deck/.local/share/Steam/steamui/movies
animchgr=/home/deck/homebrew/data/SDH-AnimationChanger/downloads
vidList="deck-suspend-animation.webm deck-suspend-animation-from-throbber.webm oled-suspend-animation.webm oled-suspend-animation-from-throbber.webm"
err=0

# If this script has been piped into Bash via cURL, download itself and run locally. Things like 'read' fail to run, otherwise.
if [[ "$(basename $0)" == "bash" ]]; then
	wget https://raw.githubusercontent.com/TDGalea/decky-animationchanger-oled-fix/refs/heads/main/deck-suspend-vid-fix.sh
	chmod +x deck-suspend-vid-fix.sh
	printf "\n\nScript does not like being piped into Bash - it has been downloaded to your current directory, and made executable.\n"
	printf "Please run 'deck-suspend-vid-fix.sh' manually.\n"
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
	for vid in deck-suspend-animation.webm deck-suspend-animation-from-throbber.webm oled-suspend-animation.webm oled-suspend-animation-from-throbber.webm; do
		# Ensure AnimChanger version of this vid exists.
		if [[ ! -f $animchgr/$vid ]]; then
			printf "'$vid' does not exist at '$animchgr'. Not modifying that file.\nMake sure you've selected an animation for this first.\n"
		else
			whatDo="backing up"
			printf "Backing up '$vid': "
			mv $official/$vid $official/$vid.orig && printf "done.\n" || printf "failed.\n"
			whatDo="linking"
			printf "Linking '$vid': "
			ln -s $animchgr/$vid $official/$vid && printf "done.\n" || printf "failed.\n"
		fi
	done
	quit 0
}

restoreOriginal(){
	for vid in $vidList; do
		if [[ ! -f $official/$vid.orig ]]; then
			printf "No backup of '$vid' - if this has been modified, you'll need to restore it manually.\n"
		else
			printf "Restoring '$vid': "
			mv $official/$vid.orig $official/$vid && printf "done.\n" || printf "failed.\n"
		fi
	done
	quit 0
}


### Can't be bothered writing this twice.

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
printf "Do you want to apply links, or restore originals?\n"
unset choice
until [[ "${choice,,}" == "l" ]] || [[ "${choice,,}" == "r" ]]; do
	printf "\r[L/R]:               ^         ^\r[L/R]: "
	read -n1 choice
done
printf \\n
[[ "${choice,,}" == "l" ]] && applyLinks || restoreOriginal


# Script should quit before getting to this point.
printf "\n\nScript reached end of file. I forgot to put a 'quit' somewhere. Please tell me off.\n"
quit 0
