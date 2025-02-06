# decky-animationchanger-oled-fix
Steam now names the OLED suspend animations separately, so AnimationChanger is "broken" for OLED users when it comes to suspend animations. This script fixes that issue.

Simply download this script, make it executable, then run it.
If you're feeling lazy, or just aren't comfortable with terminal stuff, open Konsole on your Steam Deck and type/paste these two lines:

```
curl https://raw.githubusercontent.com/TDGalea/decky-animationchanger-oled-fix/refs/heads/main/deck-suspend-vid-fix.sh | bash
./deck-suspend-vid-fix.sh
```
Doing this will download the script to your current directory (probably your home folder if you've just opened Konsole) and make it executable.
You then just run that local script.

You'll then be asked if you want to apply links (fix AnimationChanger) or restore the original files.

If you choose to apply links, the script will back up the original files (appending ".orig" to their names) and then create symlinks to the files that AnimationChanger uses.
If you choose to restore the originals, these symlinks will be removed if they exist, and the backups will be restored.

I have tried to make this script as fool-proof and self-explanitory as possible. It'll check that everything exists first, to the best of my ability.
If you do have issues, need help, or just have questions, feel free to create Issues here on GitHub, or contact me on Discord (galea011).
I am usually happy to help, although my replies may not be super quick.
