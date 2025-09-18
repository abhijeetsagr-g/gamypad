// Gamepad.cpp
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
    {"LT", BTN_TL2},
    {"RT", BTN_TR2},
    {"LB", BTN_TL},
    {"RB", BTN_TR},
    };
    
    enableGamepad();

    uinput_setup usetup{};
    usetup.id.bustype = BUS_USB;
    usetup.id.product = 0x6969;
    usetup.id.vendor = 0x4420;
    snprintf(usetup.name, UINPUT_MAX_NAME_SIZE, "Gamypad");
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

void Gamepad::setAxis(int code, int value) {
    emit(EV_ABS, code, value);
    emit(EV_SYN, SYN_REPORT, 0);
}

