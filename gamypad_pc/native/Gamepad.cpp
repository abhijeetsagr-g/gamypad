#include "Gamepad.h"
#include <fcntl.h>
#include <linux/input-event-codes.h>
#include <linux/uinput.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <cstring>

Gamepad::Gamepad() {
    fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (fd < 0) { perror("open"); exit(1); }

    keyMap = { 
    {"A", BTN_A},
    {"B", BTN_B},
    {"X", BTN_X},
    {"Y", BTN_Y},
    {"UP", BTN_DPAD_UP},
    {"DOWN", BTN_DPAD_DOWN},
    {"LEFT", BTN_DPAD_LEFT},
    {"RIGHT", BTN_DPAD_RIGHT},
    {"LB", BTN_TL},
    {"RB", BTN_TR},
    {"START", BTN_START},
    {"SELECT", BTN_SELECT},
    {"LS", BTN_THUMBL},
    {"RS", BTN_THUMBR},
    {"GUIDE", BTN_MODE}
    };
    
    enableGamepad();
  
    uinput_setup usetup{};
    usetup.id.bustype = BUS_USB;
    
    usetup.id.vendor  = 0x045e;  // Microsoft
    usetup.id.product = 0x028e;  // Xbox 360 Controller
    strncpy(usetup.name, "Gamypad", UINPUT_MAX_NAME_SIZE);

    ioctl(fd, UI_DEV_SETUP, &usetup);
    ioctl(fd, UI_DEV_CREATE);
    sleep(1);
}

Gamepad::~Gamepad() {
    ioctl(fd, UI_DEV_DESTROY);
    close(fd);
}

void Gamepad::enableGamepad() {
    const int RANGE_NUM = 32767;
    const int ABS_FLAT = 128;
    const int ABS_FUZZ = 16;
    const int ABS_VALUE = 0;

    ioctl(fd, UI_SET_EVBIT, EV_KEY);
    ioctl(fd, UI_SET_EVBIT, EV_SYN);
    ioctl(fd, UI_SET_EVBIT, EV_ABS);
    
    ioctl(fd, UI_SET_ABSBIT, ABS_X);
    ioctl(fd, UI_SET_ABSBIT, ABS_Y);
    ioctl(fd, UI_SET_ABSBIT, ABS_RX);
    ioctl(fd, UI_SET_ABSBIT, ABS_RY);
    ioctl(fd, UI_SET_ABSBIT, ABS_Z);
    ioctl(fd, UI_SET_ABSBIT, ABS_RZ);

    for (auto const& [name, code] : keyMap) {
        ioctl(fd, UI_SET_KEYBIT, code);
    }


    // Left stick X 
    uinput_abs_setup abs_x {};
    abs_x.code = ABS_X;
    abs_x.absinfo.maximum = RANGE_NUM;
    abs_x.absinfo.minimum = -RANGE_NUM;
    abs_x.absinfo.flat = ABS_FLAT;
    abs_x.absinfo.fuzz = ABS_FUZZ;
    abs_x.absinfo.value = ABS_VALUE;
    ioctl(fd, UI_ABS_SETUP, &abs_x);

    // Left Stick Y
    uinput_abs_setup abs_y {};
    abs_y.code = ABS_Y;
    abs_y.absinfo.maximum = RANGE_NUM;
    abs_y.absinfo.minimum = -RANGE_NUM;
    abs_y.absinfo.flat = ABS_FLAT;
    abs_y.absinfo.fuzz = ABS_FUZZ;
    abs_y.absinfo.value = ABS_VALUE;
    ioctl(fd, UI_ABS_SETUP, &abs_y);
    
    // Right Stick X
    uinput_abs_setup abs_rx {};
    abs_rx.code = ABS_RX;
    abs_rx.absinfo.maximum = RANGE_NUM;
    abs_rx.absinfo.minimum = -RANGE_NUM;
    abs_rx.absinfo.flat = ABS_FLAT;
    abs_rx.absinfo.fuzz = ABS_FUZZ;
    abs_rx.absinfo.value = ABS_VALUE;
    ioctl(fd, UI_ABS_SETUP, &abs_rx);
    
    // Right Stick Y
    uinput_abs_setup abs_ry {};
    abs_ry.code = ABS_RY;
    abs_ry.absinfo.maximum = RANGE_NUM;
    abs_ry.absinfo.minimum = -RANGE_NUM;
    abs_ry.absinfo.flat = ABS_FLAT;
    abs_ry.absinfo.fuzz = ABS_FUZZ;
    abs_ry.absinfo.value = ABS_VALUE;
    ioctl(fd, UI_ABS_SETUP, &abs_ry);

    // Left Trigger (ABS_Z)
    uinput_abs_setup abs_z {};
    abs_z.code = ABS_Z;
    abs_z.absinfo.minimum = 0;
    abs_z.absinfo.maximum = 255;
    abs_z.absinfo.flat = 0;
    abs_z.absinfo.fuzz = 0;
    abs_z.absinfo.value = 0;
    ioctl(fd, UI_ABS_SETUP, &abs_z);

    // Right Trigger (ABS_RZ)
    uinput_abs_setup abs_rz {};
    abs_rz.code = ABS_RZ;
    abs_rz.absinfo.minimum = 0;
    abs_rz.absinfo.maximum = 255;
    abs_rz.absinfo.flat = 0;
    abs_rz.absinfo.fuzz = 0;
    abs_rz.absinfo.value = 0;
    ioctl(fd, UI_ABS_SETUP, &abs_rz);

    // D-pad horizontal (X) and vertical (Y)
    ioctl(fd, UI_SET_ABSBIT, ABS_HAT0X);
    ioctl(fd, UI_SET_ABSBIT, ABS_HAT0Y);

    uinput_abs_setup abs_hatx{};
    abs_hatx.code = ABS_HAT0X;
    abs_hatx.absinfo.minimum = -1;
    abs_hatx.absinfo.maximum = 1;
    abs_hatx.absinfo.flat = 0;
    abs_hatx.absinfo.fuzz = 0;
    abs_hatx.absinfo.value = 0;
    ioctl(fd, UI_ABS_SETUP, &abs_hatx);

    uinput_abs_setup abs_haty{};
    abs_haty.code = ABS_HAT0Y;
    abs_haty.absinfo.minimum = -1;
    abs_haty.absinfo.maximum = 1;
    abs_haty.absinfo.flat = 0;
    abs_haty.absinfo.fuzz = 0;
    abs_haty.absinfo.value = 0;
    ioctl(fd, UI_ABS_SETUP, &abs_haty);
}

void Gamepad::emit(int type, int code, int value) {
    input_event ie{};
    memset(&ie, 0, sizeof(ie));
    ie.type = type;
    ie.code = code;
    ie.value = value;
    gettimeofday(&ie.time, nullptr);
    write(fd, &ie, sizeof(ie));
}

void Gamepad::pressKey(const std::string& key) {
    emit(EV_KEY, keyMap[key], 1);
    emit(EV_SYN, SYN_REPORT, 0);
}

void Gamepad::releaseKey(const std::string& key) {
    emit(EV_KEY, keyMap[key], 0);
    emit(EV_SYN, SYN_REPORT, 0);
}

// Type = 1 -> left stick or 0 = right stick. X and Y are axes
void Gamepad::setAxis(int type, int valueX, int valueY) {
    if (type == 1) { // left stick
        emit(EV_ABS, ABS_X, valueX);
        emit(EV_ABS, ABS_Y, valueY);
    } else { // right stick
        emit(EV_ABS, ABS_RX, valueX);
        emit(EV_ABS, ABS_RY, valueY);
    }
    emit(EV_SYN, SYN_REPORT, 0); // flush events
}

// xValue: -1 = LEFT, 0 = neutral, 1 = RIGHT
// yValue: -1 = UP, 0 = neutral, 1 = DOWN
void Gamepad::setDpad(int xValue, int yValue) {
    emit(EV_ABS, ABS_HAT0X, xValue);
    emit(EV_ABS, ABS_HAT0Y, yValue);
    emit(EV_SYN, SYN_REPORT, 0);
}



void Gamepad::setTrigger(int type, int value) {
    int code = type == 1 ? ABS_Z : ABS_RZ;
    emit(EV_ABS, code, value);
    emit(EV_SYN, SYN_REPORT, 0);
}