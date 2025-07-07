import vgamepad as vg

gamepad = vg.VX360Gamepad()

KEY_MAP = {
    # Face Buttons
    "A": vg.XUSB_BUTTON.XUSB_GAMEPAD_A,
    "B": vg.XUSB_BUTTON.XUSB_GAMEPAD_B,
    "X": vg.XUSB_BUTTON.XUSB_GAMEPAD_X,
    "Y": vg.XUSB_BUTTON.XUSB_GAMEPAD_Y,

    # D-Pad
    "UP": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_UP,
    "DOWN": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_DOWN,
    "LEFT": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_LEFT,
    "RIGHT": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_RIGHT,

    # Shoulder Buttons
    "LB": vg.XUSB_BUTTON.XUSB_GAMEPAD_LEFT_SHOULDER,
    "RB": vg.XUSB_BUTTON.XUSB_GAMEPAD_RIGHT_SHOULDER,

    # Stick Presses
    "LT": vg.XUSB_BUTTON.XUSB_GAMEPAD_LEFT_THUMB,
    "RT": vg.XUSB_BUTTON.XUSB_GAMEPAD_RIGHT_THUMB,

    # Menu Buttons
    "START": vg.XUSB_BUTTON.XUSB_GAMEPAD_START,
    "SELECT": vg.XUSB_BUTTON.XUSB_GAMEPAD_BACK,
    "GUIDE": vg.XUSB_BUTTON.XUSB_GAMEPAD_GUIDE,
}


def handle_keys(msg):
    key = msg.get("btn")
    action = msg.get("action")  # "press" or "release"

    if not key or not action:
        print("Invalid message:", msg)
        return

    if action == "press":
        on_press(key)
    elif action == "release":
        on_release(key)
    else:
        print(f"Unknown action: {action}")


def on_press(key):
    try:
        if key == "LT":
            gamepad.left_trigger(value=255)
        elif key == "RT":
            gamepad.right_trigger(value=255)
        elif key in KEY_MAP:
            btn = KEY_MAP[key]
            gamepad.press_button(button=btn)
        else:
            print(f"{key} is not mapped.")
            return
        gamepad.update()
    except Exception as e:
        print(f"Error pressing {key}: {e}")


def on_release(key):
    try:
        if key == "LT":
            gamepad.left_trigger(value=0)
        elif key == "RT":
            gamepad.right_trigger(value=0)
        elif key in KEY_MAP:
            btn = KEY_MAP[key]
            gamepad.release_button(button=btn)
        else:
            print(f"{key} is not mapped.")
            return
        gamepad.update()
    except Exception as e:
        print(f"Error releasing {key}: {e}")
