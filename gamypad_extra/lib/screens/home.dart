import 'package:flutter/material.dart';
import 'package:gamypad_extra/client.dart';
import 'package:gamypad_extra/widgets/show_message.dart' show ShowMessage;

class Home extends StatefulWidget {
  Home({super.key});

  final TextEditingController address = TextEditingController();
  final TextEditingController port = TextEditingController();

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> checkIP() async {
    final ip = widget.address.text.trim();
    final portText = widget.port.text.trim();

    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
      r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );

    if (ip.isEmpty || portText.isEmpty) {
      ShowMessage.show(context, "IP address and port must not be empty.");

      return;
    }

    if (!ipRegex.hasMatch(ip)) {
      ShowMessage.show(context, "Invalid IP address format.");
      return;
    }

    final port = int.tryParse(portText);
    if (port == null || port < 0 || port > 65535) {
      ShowMessage.show(context, "Port must be a number between 0 and 65535.");
      return;
    }
    final connectionError = await connectServer(ip, port);
    if (connectionError != null) {
      ShowMessage.show(context, "Connection failed: $connectionError");
      return;
    }
    setState(() {});

    Navigator.pushNamed(context, "/gamepad");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 215, 215, 215),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 215, 215, 215),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                isConnected
                    ? Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      )
                    : Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                SizedBox(width: 10),
                isConnected ? Text("Connected") : Text("Not Connected"),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    autocorrect: false,
                    controller: widget.address,
                    decoration: InputDecoration(
                      hintText: "Address",
                      labelText: "IP Address",
                      focusColor: Color.fromARGB(255, 20, 20, 20),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: TextField(
                    autocorrect: false,
                    controller: widget.port,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Port",
                      labelText: "Port",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  checkIP();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Connect",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 20, 20, 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color.fromARGB(255, 39, 63, 79),

        child: Icon(Icons.help, color: Colors.white),
      ),
    );
  }
}
