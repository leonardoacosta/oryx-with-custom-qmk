# Oryx with custom QMK

This repository allows combining the convenience of [Oryx’s](https://www.zsa.io/oryx) graphical layout editing with the power of [QMK](https://qmk.fm), allowing you to customize your Oryx layout with advanced QMK features like Achordion and Repeat Key, while automating firmware builds through GitHub Actions.

For a detailed guide, check out the full [blog post here](https://blog.zsa.io/oryx-custom-qmk-features).

## How it works

Each time you run the GitHub Action, the workflow will:
1. Fetch the latest changes made in Oryx.
2. Merge them with any QMK features you've added in the source code.
3. Build the firmware, incorporating modifications from both Oryx and your custom source code.

## Real macOS Globe/Fn key on the Voyager

This repo carries one non-Oryx QMK patch to make the Voyager send the real macOS `Fn`/`Globe` key instead of a fallback shortcut:

- `Br7g0/keymap.c` defines `CUSTOM_GLOBE`
- `process_record_user()` sends `host_consumer_send(AC_NEXT_KEYBOARD_LAYOUT_SELECT)` on press and clears it on release
- the live layout exposes that real Globe/Fn behavior on layer 2 at the physical key whose base-layer legend is `6/^`
- `Br7g0/rules.mk` enables `KEYBOARD_SHARED_EP = yes`, which is required for that shared HID consumer report path
- `scripts/hooks/zsa-globe-key-patch.py` reapplies the patch after every Oryx fetch, because Oryx regenerates `keymap.c` and `rules.mk`

Why this approach exists: an earlier bare-`F13`/tap-dance workaround was not confirmed reliable for Wispr Flow, while the real consumer-usage Globe key gives macOS and apps the exact key they expect for Dictation, Siri, emoji picker, and Globe/Fn-triggered shortcuts.

## Operational findings

- The firmware file you flash matters more than the repo commit you just made. On July 30, 2026, the approved remap had already been committed, but the first recovery flash used the older Mac download `voyager_Br7g0_zsa_voyager_Br7g0.bin`, which still embedded `Br7g0/jZ7yY7` from July 29, 2026. Result: the flash worked, but the keys stayed on the old layout. Always build a fresh artifact from the approved source before flashing layout changes.
- If the Voyager appears unresponsive after a flash attempt, check whether it is in bootloader mode before assuming the board is dead. On macOS, `ioreg -p IOUSB -l -w 0 | egrep -i "Voyager|Bootloader|ZSA"` will show either `Voyager` or `Voyager Bootloader`.
- While the board is in bootloader mode, `kontroll status` will typically report `No keyboard connected`. That is expected because Keymapp is talking to the normal keyboard firmware API, not the bootloader.
- Layer highlighting for layers 1 and 2 is still implemented in firmware, but it is gated by the persistent `TOGGLE_LAYER_COLOR` setting. In this layout, `TOGGLE_LAYER_COLOR` lives on layer 2 in the top row immediately to the right of `RGB_TOG`. If layer highlighting disappears while the base RGB animation still works, toggle that key first.
- The Mac-side flashing path is now Zapp-first. If `zapp` is installed, `scripts/hooks/zsa-firmware-check.sh --flash <firmware>` prefers `zapp flash <firmware>` and only falls back to opening `Keymapp` when `zapp` is unavailable.
- Even with Zapp, the physical reset/bootloader transition is still manual. The host can stage the firmware, verify the Mac and Keymapp/Kontroll path, and wait for bootloader, but it cannot inject the reset press over USB with the public ZSA tooling.

## Recovery checklist

1. Verify the board state on the Mac:
   - normal mode: `Voyager`
   - bootloader mode: `Voyager Bootloader`
2. If the board is in bootloader mode, flash the exact intended artifact:
   - `zapp flash ~/Downloads/<firmware>.bin`
3. If the board returns as normal `Voyager` but Keymapp still does not attach, run:
   - `kontroll connect-any`
   - `kontroll status`
4. If layers 1 and 2 no longer highlight, toggle `TOGGLE_LAYER_COLOR` on layer 2 before changing firmware again.

## How to use

1. Fork this repository (be sure to **uncheck the "Copy the main branch only" option**).
2. To initialize the repository with your layout:
   - Go to the **Actions** tab.
   - Select **Fetch and build layout**.
   - Click **Run workflow**.
   - Input your layout ID and keyboard type (your layout must be public in Oryx), then run the workflow.
   - (To avoid having to input values each time, you can modify the default values at the top of the `.github/workflows/fetch-and-build-layout.yml` file).
3. A folder containing your layout will be generated at the root of the repository.
4. You can now add your custom QMK features to this folder:
   - Edit `config.h`, `keymap.c` and `rules.mk` according to the [QMK documentation](https://github.com/qmk/qmk_firmware/tree/master/docs/features).
   - Commit and push to the **main** branch.
5. You can continue editing your layout through Oryx:
   - Make your changes in Oryx. 
   - Optionally, add a description of your changes in the **Some notes about what you changed** field; if provided, this will be used as commit message.
   - Confirm changes by clicking the **Compile this layout** button.
6. To build the firmware (including both Oryx and code modifications), rerun the GitHub Action. The firmware will be available for download in the action’s artifacts.
7. Flash your downloaded firmware using [Keymapp](https://www.zsa.io/flash#flash-keymap).
8. Enjoy!

## Oryx Chrome extension

To make building even easier, [@nivekmai](https://github.com/nivekmai) created an [Oryx Chrome extension](https://chromewebstore.google.com/detail/oryx-extension/bocjciklgnhkejkdfilcikhjfbmbcjal) to be able to trigger the GitHub Actions from inside Oryx itself.
