#include <string>
#include <map>


using namespace std;

class Gamepad {
public:
    Gamepad();
    ~Gamepad();

    void pressKey(const string& key);
    void releaseKey(const string& key);
private:
    int fd;
    std::map<string, int> keyMap;
    void emit(int type, int code, int value);
    void enableGamepad();
};
