#include "Gamepad.h"

extern "C" {
    Gamepad* Gamepad_new(int playerIndex) {
        Gamepad* gp = new Gamepad(playerIndex);
        if (!gp->isValid()) {
            delete gp;
            return nullptr;
        }
        return gp;
    }

    void Gamepad_delete(Gamepad* gp) {
        delete gp;
    }

    void Gamepad_pressKey(Gamepad* gp, const char* key) {
        if (gp) gp->pressKey(std::string(key));
    }

    void Gamepad_releaseKey(Gamepad* gp, const char* key) {
        if (gp) gp->releaseKey(std::string(key));
    }

    void Gamepad_setAxis(Gamepad* gp, int type, int valueX, int valueY) {
        if (gp) gp->setAxis(type, valueX, valueY);
    }

    void Gamepad_setTrigger(Gamepad* gp, int code, int value) {
        if (gp) gp->setTrigger(code, value);
    }

    void Gamepad_setDpad(Gamepad* gp, int xValue, int yValue) {
        if (gp) gp->setDpad(xValue, yValue);
    }
}
