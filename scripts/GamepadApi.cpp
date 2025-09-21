#include "Gamepad.h"

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
}