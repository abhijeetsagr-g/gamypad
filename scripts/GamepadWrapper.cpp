#include "Gamepad.h"
#include <string>

extern "C" {

Gamepad* Gamepad_new() {
    return new Gamepad();
}

void Gamepad_delete(Gamepad* gp) {
    delete gp;
}

void Gamepad_pressButton(Gamepad* gp, const char* buttonCode) {
    gp->pressKey(std::string(buttonCode));
}

void Gamepad_releaseButton(Gamepad* gp, const char* buttonCode) {
    gp->releaseKey(std::string(buttonCode));
}

}