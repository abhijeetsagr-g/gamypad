#pragma once

// A second uinput device carrying gyro + accelerometer, shaped like the
// "Motion Sensors" node the Linux hid-playstation driver creates for a
// DualSense: ABS_X/Y/Z accelerometer, ABS_RX/RY/RZ gyro, INPUT_PROP_ACCELEROMETER.
// It is separate from the Xbox pad because Xbox 360 has no motion channel.
class Motion {
public:
  // Check ok() — construction can fail (no /dev/uinput access) and must not
  // take the app down with it.
  Motion();
  ~Motion();

  bool ok() const { return fd >= 0; }

  // Wire units: gyro in millidegrees/s, accelerometer in milli-g.
  void set(int gx, int gy, int gz, int ax, int ay, int az);

private:
  int fd = -1;
  void emit(int type, int code, int value);
  void absAxis(int code, int range, int resolution);
};
