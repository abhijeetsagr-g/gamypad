#include "Gamepad.h"
#include "Motion.h"

extern "C" {
    // Create a new Gamepad instance
    Gamepad* Gamepad_new() {
        return new Gamepad();
    }

    // Delete a Gamepad instance
    void Gamepad_delete(Gamepad* gp) {
        delete gp;
    }

    // Press key
    void Gamepad_pressKey(Gamepad* gp, const char* key) {
        gp->pressKey(std::string(key));
    }

    // Release key
    void Gamepad_releaseKey(Gamepad* gp, const char* key) {
        gp->releaseKey(std::string(key));
    }

    // Set axis
    void Gamepad_setAxis(Gamepad* gp, int type, int valueX, int valueY) {
        gp->setAxis(type, valueX, valueY);
    }

    // set triggers
    void Gamepad_setTrigger(Gamepad* gp, int code, int value) {
        gp->setTrigger(code, value);
    }

    void Gamepad_setDpad(Gamepad* gp, int xValue, int yValue) {
        gp->setDpad(xValue, yValue);
    }

    // Motion sensors. Motion_new returns null when the device cannot be created.
    Motion* Motion_new() {
        Motion* m = new Motion();
        if (!m->ok()) {
            delete m;
            return nullptr;
        }
        return m;
    }

    void Motion_delete(Motion* m) {
        delete m;
    }

    void Motion_set(Motion* m, int gx, int gy, int gz, int ax, int ay, int az) {
        m->set(gx, gy, gz, ax, ay, az);
    }

}