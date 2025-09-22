import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gamypad_apk/models/client.dart';
import 'package:gamypad_apk/widgets/my_widgets.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  late final clientProvider = Provider.of<Client>(context);

  String errorMessage = "";

  void onDisconnect() {
    showFloatingSnackbar(context, "Disconnected");
    clientProvider.disconnect();
  }

  void onError(dynamic error) {
    showFloatingSnackbar(context, error.toString());
  }

  // Change current page to gamepad
  void goToNewPage(String page) {
    errorMessage = "";
    FocusScope.of(context).unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, page);
    });
  }

  Future<void> connect() async {
    if (_addressController.text.isEmpty || _portController.text.isEmpty) {
      setState(() {
        errorMessage = "Please add an address and port";
      });
      return;
    }

    try {
      await clientProvider.connect(
        _addressController.text,
        int.parse(_portController.text),
      );
      _addressController.clear();
      _portController.clear();

      goToNewPage("/gamepad");
    } on SocketException catch (e) {
      setState(() {
        print(e);
        errorMessage = e.message;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Widget _textfield(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: hint, border: OutlineInputBorder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = clientProvider.isConnected;
    clientProvider.onDisconnected = () => onDisconnect();
    clientProvider.onError = (error) => onError(error);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isConnected
              ? " Connected to ${clientProvider.address}:${clientProvider.port}"
              : "Gamypad",
        ),
        actions: [
          IconButton(
            onPressed: () => goToNewPage("/settings"),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _textfield(_addressController, "Address"),
              ),
              SizedBox(width: 10),
              Expanded(flex: 1, child: _textfield(_portController, "Port")),
            ],
          ),
          if (errorMessage.isNotEmpty) Text(errorMessage),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => goToNewPage("/gamepad"),
                  child: Text("Gamepad"),
                ),
                const SizedBox(width: 10),
                if (isConnected)
                  ElevatedButton(
                    onPressed: onDisconnect,
                    child: Text("Disconnect"),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: connect,
        child: Icon(Icons.add),
      ),
    );
  }
}
