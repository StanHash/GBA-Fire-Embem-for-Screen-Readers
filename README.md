# GBA Fire Emblem for Screen Readers

## Introduction

GBA Fire Emblem for Screen Readers is a set of Lua scripts that aim to improve access to the GBA Fire Emblem games for people using screen readers.

This project was built on top of the work done in the [pokemon-access][pokemon-access] project, which is itself an extension of the [pokemon-crystal-access][pokemon-crystal-access] project.

This is a work in progress. Only the North American release of Fire Emblem The Sacred Stones, colloquially abbreviated as Fire Emblem 8, is supported for now. Most mods of that game will also work.

These scripts are designed for use with the VBA-ReRecording emulator running on Windows.

[pokemon-access]: https://github.com/nuive/pokemon-access
[pokemon-crystal-access]: https://allinaccess.com/pca/

## Installation

1. You will need to have a ROM of the game, if you don't already have one. Currently only Fire Emblem 8 is supported. Most mods of that game will also work.
2. Obtain the latest packaged release of the scripts via the following line: https://github.com/StanHash/GBA-Fire-Embem-for-Screen-Readers/releases/latest/download/fire_emblem_screen_reader.zip. The releases section of the GitHub repository features any older releases.
3. Extract the package and run the included VBA emulator.
4. Go to the Options menu, Head-Up Display, Show Speed, None. (Alt-O, H, S, Enter). NVDA reads the title bar every time it changes, and this prevents it from changing.
5. Optional but recommended: turn down the sound. In the Options menu, navigate to Audio, Volume. (Alt-O, A, V). I recommend .25x.

## Starting the game

Each time you run VBA, you need to load the game ROM. You can do this from the open dialog, or load a recent rom after you've opened it once.

Once the ROM is loaded, load the lua script (tools, lua, New Lua script window). From there, load fire_emblem_gba.lua, and press run. It should say "Ready", alt tab out and back in again.

## Key Controls

You interract with the script through pressing keys on your keyboard.

- Default GBA controls: Z X are A B, A S are L R, Enter Backspace are Start Select, Arrows are D Pad.
- Y: read current board cursor position. Positions are formatted like chess coordinates. (For example: "A1" means the top left corner of the board).
- T: read terrain name under cursor.
- U: read unit name.
- J: read unit class name.
- H: read unit HP.
- L: read current dialogue.

If you hold Shift as you press a key, automatic reading will be toggled. For example, Shift-T will make the script read the terrain name every time the cursor moves to a new position.

## Licence

Some files of this project are based on the work done on the pokemon-access project, which does not yet specify explicit licencing or copyright information. Any other file is dedicated to the Public Domain, or otherwise licenced under the CC0 Licence. 

## Contact

If you have any feedback on this project, or any bugs to report, feel free to let me know through GitHub Issues or Discord.

I can be found on the Fire Emblem Universe Discord server. My handle may be "nat", "nat_776", "stan", or some combination thereof.

Contact via E-mail is also possible if necessary. My e-mail address may be found on my GitHub profile.

GitHub repository: https://github.com/StanHash/GBA-Fire-Embem-for-Screen-Readers 

## Credits

As mentioned earlier, the technical aspects that make this possible were inherited from the pokemon-access project. It is itself an expansion of the pokemon-crystal-access project. Huge thanks again to their authors for their work.

- pokemon-access: https://github.com/nuive/pokemon-access
- pokemon-crystal-access: https://allinaccess.com/pca/
