// Gamepad.cpp
#include "Gamepad.h"
#include <fcntl.h>
#include <linux/uinput.h>
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

    // Device setup
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
    ioctl(fd, UI_SET_EVBIT, EV_KEY);
    ioctl(fd, UI_SET_EVBIT, EV_SYN);
    for (auto const& [name, code] : keyMap) {
        ioctl(fd, UI_SET_KEYBIT, code);
    }
}

void Gamepad::emit(int type, int code, int value) {
    input_event ie;
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
