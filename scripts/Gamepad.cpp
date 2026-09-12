#include "Gamepad.h"
#include <fcntl.h>
#include <linux/input-event-codes.h>
#include <linux/uinput.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <cstring>
#include <cstdio>

Gamepad::Gamepad(int playerIndex) : fd(-1), player(playerIndex) {
    fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (fd < 0) {
        perror("open /dev/uinput");
        return;
    }

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
    usetup.id.version = static_cast<__u16>(playerIndex);

    char name[UINPUT_MAX_NAME_SIZE];
    snprintf(name, UINPUT_MAX_NAME_SIZE, "Gamypad %d", playerIndex);
    strncpy(usetup.name, name, UINPUT_MAX_NAME_SIZE);

    ioctl(fd, UI_DEV_SETUP, &usetup);
    ioctl(fd, UI_DEV_CREATE);
    usleep(200000); // 200ms is enough for udev; 1s blocked every extra pad
}

Gamepad::~Gamepad() {
    if (fd < 0) return;
    ioctl(fd, UI_DEV_DESTROY);
    close(fd);
    fd = -1;
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

    auto setupAbs = [&](int code, int min, int max, int flat, int fuzz) {
        uinput_abs_setup abs{};
        abs.code = code;
        abs.absinfo.minimum = min;
        abs.absinfo.maximum = max;
        abs.absinfo.flat = flat;
        abs.absinfo.fuzz = fuzz;
        abs.absinfo.value = ABS_VALUE;
        ioctl(fd, UI_ABS_SETUP, &abs);
    };

    setupAbs(ABS_X, -RANGE_NUM, RANGE_NUM, ABS_FLAT, ABS_FUZZ);
    setupAbs(ABS_Y, -RANGE_NUM, RANGE_NUM, ABS_FLAT, ABS_FUZZ);
    setupAbs(ABS_RX, -RANGE_NUM, RANGE_NUM, ABS_FLAT, ABS_FUZZ);
    setupAbs(ABS_RY, -RANGE_NUM, RANGE_NUM, ABS_FLAT, ABS_FUZZ);
    setupAbs(ABS_Z, 0, 255, 0, 0);
    setupAbs(ABS_RZ, 0, 255, 0, 0);

    ioctl(fd, UI_SET_ABSBIT, ABS_HAT0X);
    ioctl(fd, UI_SET_ABSBIT, ABS_HAT0Y);
    setupAbs(ABS_HAT0X, -1, 1, 0, 0);
    setupAbs(ABS_HAT0Y, -1, 1, 0, 0);
}

void Gamepad::emit(int type, int code, int value) {
    if (fd < 0) return;
    input_event ie{};
    memset(&ie, 0, sizeof(ie));
    ie.type = type;
    ie.code = code;
    ie.value = value;
    gettimeofday(&ie.time, nullptr);
    write(fd, &ie, sizeof(ie));
}

void Gamepad::pressKey(const std::string& key) {
    auto it = keyMap.find(key);
    if (it == keyMap.end()) return;
    emit(EV_KEY, it->second, 1);
    emit(EV_SYN, SYN_REPORT, 0);
}

void Gamepad::releaseKey(const std::string& key) {
    auto it = keyMap.find(key);
    if (it == keyMap.end()) return;
    emit(EV_KEY, it->second, 0);
    emit(EV_SYN, SYN_REPORT, 0);
}

// Type = 1 -> left stick or 0 = right stick. X and Y are axes
void Gamepad::setAxis(int type, int valueX, int valueY) {
    if (type == 1) {
        emit(EV_ABS, ABS_X, valueX);
        emit(EV_ABS, ABS_Y, valueY);
    } else {
        emit(EV_ABS, ABS_RX, valueX);
        emit(EV_ABS, ABS_RY, valueY);
    }
    emit(EV_SYN, SYN_REPORT, 0);
}

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
