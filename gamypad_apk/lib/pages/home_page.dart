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
  }

  void onError(error) {
    showFloatingSnackbar(context, error.toString());
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

      Navigator.pushNamed(context, '/gamepad');
    } on SocketException catch (e) {
      setState(() {
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
              ? " Connected to ${clientProvider.client?.remoteAddress.address}:${clientProvider.client?.remotePort}"
              : "Gamypad",
        ),
        actions: [
          isConnected
              ? ElevatedButton(
                  onPressed: () => clientProvider.disconnect(),
                  child: Text("Disconnect"),
                )
              : ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/gamepad'),
                  child: Text("Gamepad"),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: connect,
        child: Icon(Icons.add),
      ),
    );
  }
}
