CONSOLE_ENABLE = no
COMMAND_ENABLE = no
MOUSEKEY_ENABLE = no
ORYX_ENABLE = yes
RGB_MATRIX_CUSTOM_KB = yes
SPACE_CADET_ENABLE = no
CAPS_WORD_ENABLE = yes
# Real Apple Globe/Fn key via Consumer Usage (CUSTOM_GLOBE in keymap.c) --
# needed to send it as a modifier-capable report over the shared HID
# endpoint. Unconfirmed risk (2026-07-20): documented ChibiOS/QMK PR history
# shows a prior KEYBOARD_SHARED_EP fix on this backend had a Caps Lock LED
# side effect -- watch caps-word/RGB layer indicators after flashing.
KEYBOARD_SHARED_EP = yes
