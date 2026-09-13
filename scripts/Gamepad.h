#include <string>
#include <map>

using namespace std;

class Gamepad {
public:
    explicit Gamepad(int playerIndex = 1);
    ~Gamepad();

    bool isValid() const { return fd >= 0; }
    int playerIndex() const { return player; }

    void pressKey(const string& key);
    void releaseKey(const string& key);
    void setAxis(int type, int valueX, int valueY);
    void setTrigger(int code, int value);
    void setDpad(int xValue, int yValue);
private:
    int fd;
    int player;
    std::map<string, int> keyMap;
    void emit(int type, int code, int value);
    void enableGamepad();
};
