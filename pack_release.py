# USAGE:
# python pack_release.py [PATH/TO/VBA/DIR] [PATH/TO/DIR/WITH/DLLS]

import sys, pathlib
from zipfile import ZipFile, ZIP_DEFLATED

# this name is what the README links to. Keep it!
OUTPUT_FILE = "fire_emblem_screen_reader.zip"

def main(args):
    if len(args) > 1:
        vba_root = args[1]

    else:
        # assuming we are inside the lua folder of VBA-RR
        vba_root = ".."

    if len(args) > 2:
        dll_root = args[2]

    else:
        # assuming we are inside the lua folder of VBA-RR with DLLs already here
        dll_root = "."

    root = pathlib.Path('.')
    vba_path = pathlib.Path(vba_root)
    dll_path = pathlib.Path(dll_root)

    lua_path = pathlib.PurePath('lua')

    scripts = list(root.glob('**/*.lua'))
    dlls = list(dll_path.glob('*.dll'))

    with ZipFile(OUTPUT_FILE, 'w', compression=ZIP_DEFLATED) as zip:
        for script in scripts:
            zip.write(script, lua_path / script)

        for dll in dlls:
            zip.write(dll, lua_path / dll)

        zip.write(vba_path / "vba.exe", "vba.exe")
        zip.write(vba_path / "lua51.dll", "lua51.dll")

if __name__ == '__main__':
    main(sys.argv)
