import 'package:flutter/material.dart';
import 'package:gamypad_extra/client.dart';
import 'package:gamypad_extra/widgets/show_message.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Required Colors
  Color backgroundColor = Color.fromARGB(255, 238, 238, 238);
  Color wordColor = Color.fromARGB(255, 42, 71, 89);
  Color btnColor = Color.fromARGB(255, 247, 155, 114);
  Color extraColor = Color.fromARGB(255, 221, 221, 221);

  // text controller
  TextEditingController addressController = TextEditingController();
  TextEditingController portController = TextEditingController();

  bool isConnected = false;

  Future<void> checkIP() async {
    final ip = addressController.text.trim();
    final portText = portController.text.trim();

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
    isConnected = true;
  }

  void openController() => Navigator.pushNamed(context, "/gamepad");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 10),
            Text(
              isConnected ? "Connected" : "Not Connected",
              style: TextStyle(
                fontFamily: "Hanalei",
                color: wordColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: addressController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: extraColor,
                      hintText: "Address",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 5),

                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: extraColor,
                      hintText: "Port",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(2, 10, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (isConnected) {
                        isConnected = false;
                        disconnectServer();
                      } else {
                        checkIP();
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isConnected ? Colors.red : btnColor,
                    elevation: 2,

                    shadowColor: Colors.black12,
                  ),
                  child: Text(
                    isConnected ? "Disconnect" : "Connect",
                    style: TextStyle(
                      fontFamily: "Hanalei",
                      color: wordColor,
                      fontSize: 17,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                isConnected
                    ? TextButton(
                        onPressed: () {
                          setState(() {
                            if (isConnected) {
                              openController();
                            }
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: btnColor,
                          elevation: 2,

                          shadowColor: Colors.black12,
                        ),
                        child: Text(
                          "Play",
                          style: TextStyle(
                            fontFamily: "Hanalei",
                            color: wordColor,
                            fontSize: 17,
                          ),
                        ),
                      )
                    : Padding(padding: EdgeInsetsGeometry.all(0)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/help");
        },
        backgroundColor: wordColor,
        child: Icon(Icons.help_rounded, color: btnColor),
      ),
    );
  }
}
