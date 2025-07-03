import vgamepad as vg

gamepad = vg.VX360Gamepad()

KEY_MAP = {
    # Face Button
    "A" : vg.XUSB_BUTTON.XUSB_GAMEPAD_A,
    "B" : vg.XUSB_BUTTON.XUSB_GAMEPAD_B,
    "X" : vg.XUSB_BUTTON.XUSB_GAMEPAD_X,
    "Y" : vg.XUSB_BUTTON.XUSB_GAMEPAD_Y,

    # DPAD
    "UP" : vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_UP,
    "DOWN" : vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_DOWN,
    "LEFT" : vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_LEFT,
    "RIGHT" : vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_RIGHT,

    # SHOULDER
    "LB" : vg.XUSB_BUTTON.XUSB_GAMEPAD_LEFT_SHOULDER,
    "RB" : vg.XUSB_BUTTON.XUSB_GAMEPAD_RIGHT_SHOULDER,
    "LT" : vg.XUSB_BUTTON.XUSB_GAMEPAD_LEFT_THUMB,
    "RT": vg.XUSB_BUTTON.XUSB_GAMEPAD_RIGHT_THUMB,
    
    # SELECT AND START
    "START": vg.XUSB_BUTTON.XUSB_GAMEPAD_START,
    "SELECT": vg.XUSB_BUTTON.XUSB_GAMEPAD_BACK,
    "GUIDE": vg.XUSB_BUTTON.XUSB_GAMEPAD_GUIDE,
}

def handle_keys(msg):
    key = msg.get("btn")
    action = msg.get("action")  # "press" or "release"
    
    if key not in KEY_MAP:
        print(f"{key} is not working")
        return

    if action == "press":
        on_press(key)
    elif action == "release":
        on_release(key)

def on_press(key):
    try:
        btn = KEY_MAP.get(key)
        gamepad.press_button(button=btn)
        gamepad.update()

    except AttributeError:
        pass 

def on_release(key):
    try:
        btn = KEY_MAP.get(key)
        gamepad.release_button(button=btn)
        gamepad.update()

    except AttributeError:
        pass
