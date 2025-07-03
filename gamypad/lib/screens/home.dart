import 'package:flutter/material.dart';
import 'package:gamypad/client.dart';

class Home extends StatefulWidget {
  Home({super.key});

  final TextEditingController address = TextEditingController();
  final TextEditingController port = TextEditingController();

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void checkIP() {
    final ip = widget.address.text.trim();
    final portText = widget.port.text.trim();

    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
      r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );

    if (ip.isEmpty || portText.isEmpty) {
      showMessage("IP address and port must not be empty.");
      return;
    }

    if (!ipRegex.hasMatch(ip)) {
      showMessage("Invalid IP address format.");
      return;
    }

    final port = int.tryParse(portText);
    if (port == null || port < 0 || port > 65535) {
      showMessage("Port must be a number between 0 and 65535.");
      return;
    }
    connectServer(ip, int.parse(portText));
    Navigator.pushNamed(context, "/gamepad");
  }

  @override
  void dispose() {
    super.dispose();
    if (socket != null) {
      disconnectServer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Gamepad",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Outer padding
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.help_outline, color: Colors.white),
      ),
    );
  }
}
