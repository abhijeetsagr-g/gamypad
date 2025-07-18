import 'package:flutter/material.dart';
import 'package:gamypad/client.dart';

class Home extends StatefulWidget {
  Home({super.key});

  // Required Colors
  final Color backgroundColor = Color.fromARGB(255, 238, 238, 238);
  final Color wordColor = Color.fromARGB(255, 42, 71, 89);
  final Color btnColor = Color.fromARGB(255, 247, 155, 114);
  final Color extraColor = Color.fromARGB(255, 221, 221, 221);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isConnected = false;
  final TextEditingController addrController = TextEditingController();
  final TextEditingController portController = TextEditingController();

  Future<void> connect(String addr, int port) async {
    final connectionError = await connectServer(addr, port);
    if (connectionError != "") {
      print("ERROR: $connectionError");
      return;
    }
    setState(() {
      isConnected = true;
    });
  }

  Future<void> disconnect() async {
    String disconnectError = await disconnectServer();
    if (disconnectError != "") {
      print("ERROR WHILE DISCONNECTION: $disconnectError");
    } else {
      print("Disconnected, with no issue");
      setState(() {
        isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        backgroundColor: widget.backgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),

                SizedBox(width: 10.0),

                Text(
                  isConnected ? "Connected" : "Not Connected",
                  style: TextStyle(
                    fontFamily: "Hanalei",
                    color: widget.wordColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Gamypad",
                  style: TextStyle(
                    fontFamily: "Hanalei",
                    color: widget.wordColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: addrController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: widget.extraColor,
                      hintText: "Address",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: widget.extraColor,
                      hintText: "Port",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              /// Connection Button
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: isConnected ? Colors.red : widget.btnColor,
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    if (!isConnected) {
                      connect(
                        addrController.text,
                        int.parse(portController.text),
                      );
                    } else {
                      disconnect();
                    }
                  });
                },
                child: Text(
                  isConnected ? "DISCONNECT" : "CONNECT",
                  style: TextStyle(
                    fontFamily: "Hanalei",
                    color: widget.wordColor,
                    fontSize: 17,
                  ),
                ),
              ),

              isConnected ? SizedBox(width: 10) : SizedBox(width: 10),

              isConnected
                  ? TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: widget.btnColor,
                        elevation: 2,
                        shadowColor: Colors.black12,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/gamepad");
                      },
                      child: Text(
                        "Play",
                        style: TextStyle(
                          fontFamily: "Hanalei",
                          color: widget.wordColor,
                          fontSize: 17,
                        ),
                      ),
                    )
                  : SizedBox(width: 0),

              isConnected ? SizedBox(width: 10) : SizedBox(width: 0),
            ],
          ),
        ],
      ),
    );
  }
}
