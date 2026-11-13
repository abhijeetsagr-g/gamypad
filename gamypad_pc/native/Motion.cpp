#include "Motion.h"
#include <cstring>
#include <fcntl.h>
#include <linux/input-event-codes.h>
#include <linux/uinput.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <unistd.h>

// Same scaling as hid-playstation: 1024 units per deg/s, 8192 per g.
static const int GYRO_RES_PER_DEG_S = 1024;
static const int ACC_RES_PER_G = 8192;
static const int GYRO_RANGE = 2048 * GYRO_RES_PER_DEG_S;
static const int ACC_RANGE = 4 * ACC_RES_PER_G;

void Motion::absAxis(int code, int range, int resolution) {
  ioctl(fd, UI_SET_ABSBIT, code);
  uinput_abs_setup abs{};
  abs.code = code;
  abs.absinfo.minimum = -range;
  abs.absinfo.maximum = range;
  abs.absinfo.resolution = resolution;
  ioctl(fd, UI_ABS_SETUP, &abs);
}

Motion::Motion() {
  fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
  if (fd < 0)
    return;

  ioctl(fd, UI_SET_EVBIT, EV_ABS);
  ioctl(fd, UI_SET_EVBIT, EV_SYN);
  ioctl(fd, UI_SET_PROPBIT, INPUT_PROP_ACCELEROMETER);

  absAxis(ABS_X, ACC_RANGE, ACC_RES_PER_G);
  absAxis(ABS_Y, ACC_RANGE, ACC_RES_PER_G);
  absAxis(ABS_Z, ACC_RANGE, ACC_RES_PER_G);
  absAxis(ABS_RX, GYRO_RANGE, GYRO_RES_PER_DEG_S);
  absAxis(ABS_RY, GYRO_RANGE, GYRO_RES_PER_DEG_S);
  absAxis(ABS_RZ, GYRO_RANGE, GYRO_RES_PER_DEG_S);

  uinput_setup usetup{};
  usetup.id.bustype = BUS_USB;
  usetup.id.vendor = 0x054c;  // Sony
  usetup.id.product = 0x0ce6; // DualSense
  strncpy(usetup.name, "Gamypad Motion Sensors", UINPUT_MAX_NAME_SIZE - 1);

  if (ioctl(fd, UI_DEV_SETUP, &usetup) < 0 || ioctl(fd, UI_DEV_CREATE) < 0) {
    close(fd);
    fd = -1;
  }
}

Motion::~Motion() {
  if (fd < 0)
    return;
  ioctl(fd, UI_DEV_DESTROY);
  close(fd);
}

void Motion::emit(int type, int code, int value) {
  input_event ie{};
  ie.type = type;
  ie.code = code;
  ie.value = value;
  gettimeofday(&ie.time, nullptr);
  if (write(fd, &ie, sizeof(ie)) < 0) {
    // Device gone or full; dropping a motion sample is harmless.
  }
}

void Motion::set(int gx, int gy, int gz, int ax, int ay, int az) {
  if (fd < 0)
    return;
  // long long: 2,000,000 * 1024 overflows int.
  auto gyro = [](int mdps) {
    return (int)((long long)mdps * GYRO_RES_PER_DEG_S / 1000);
  };
  auto acc = [](int mg) {
    return (int)((long long)mg * ACC_RES_PER_G / 1000);
  };
  emit(EV_ABS, ABS_X, acc(ax));
  emit(EV_ABS, ABS_Y, acc(ay));
  emit(EV_ABS, ABS_Z, acc(az));
  emit(EV_ABS, ABS_RX, gyro(gx));
  emit(EV_ABS, ABS_RY, gyro(gy));
  emit(EV_ABS, ABS_RZ, gyro(gz));
  emit(EV_SYN, SYN_REPORT, 0);
}
