import 'package:flutter/material.dart';
import 'package:gamypad_extra/client.dart';
import 'package:gamypad_extra/widgets/show_message.dart' show SnackBarUtils;

class Home extends StatefulWidget {
  Home({super.key});

  final TextEditingController address = TextEditingController();
  final TextEditingController port = TextEditingController();

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void checkIP() {
    final ip = widget.address.text.trim();
    final portText = widget.port.text.trim();

    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
      r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );

    if (ip.isEmpty || portText.isEmpty) {
      SnackBarUtils.show(context, "IP address and port must not be empty.");

      return;
    }

    if (!ipRegex.hasMatch(ip)) {
      SnackBarUtils.show(context, "Invalid IP address format.");
      return;
    }

    final port = int.tryParse(portText);
    if (port == null || port < 0 || port > 65535) {
      SnackBarUtils.show(context, "Port must be a number between 0 and 65535.");
      return;
    }
    connectServer(ip, int.parse(portText));
    Navigator.pushNamed(context, "/gamepad");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 20, 20, 20),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 220, 20, 60),
        title: const Text(
          "Gamepad",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Outer padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextField(
                        controller: widget.address,
                        decoration: InputDecoration(
                          hintText: "Address",
                          labelText: "IP Address",
                          focusColor: Color.fromARGB(255, 20, 20, 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        controller: widget.port,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Port",
                          labelText: "Port",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
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
                    "JOIN",
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color.fromARGB(255, 220, 20, 60),
        child: Icon(Icons.help_outline, color: Colors.white),
      ),
    );
  }
}
