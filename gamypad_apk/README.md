## Gamypad Andriod App
- Use alongside the Desktop Application.

### models/
- ***client.dart*** handles connection with sockets and saves the function to send json.

### widgets/
- ***gamepad.dart*** actual design of button ui, will be changed in future.
- ***gamepad_button.dart*** handles button press/release with the help of client class. Also the design of a single Button.
- ***joystick.dart*** joystick, my head hurts when I read that code.

### pages/
- ***home_page.dart*** handles the address/port input with socket connection.
- ***gamepad_page.dart*** saves the gamepad


