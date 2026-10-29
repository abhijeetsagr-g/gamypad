import 'package:shared_preferences/shared_preferences.dart';

/// 0 asks the OS for a free port; otherwise stay out of the privileged range.
const int randomPort = 0;
const int minPort = 1024;
const int maxPort = 65535;

bool isValidPort(int port) =>
    port == randomPort || (port >= minPort && port <= maxPort);

class ServerSettings {
  const ServerSettings({this.port = randomPort});

  final int port;

  bool get isRandomPort => port == randomPort;
}

abstract interface class ServerSettingsRepository {
  Future<ServerSettings> load();
  Future<void> save(ServerSettings settings);
}

class SharedPreferencesServerSettingsRepository
    implements ServerSettingsRepository {
  const SharedPreferencesServerSettingsRepository();

  static const _portKey = 'server_port';

  @override
  Future<ServerSettings> load() async {
    final pref = await SharedPreferences.getInstance();
    final port = pref.getInt(_portKey);
    if (port == null || !isValidPort(port)) return const ServerSettings();
    return ServerSettings(port: port);
  }

  @override
  Future<void> save(ServerSettings settings) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(_portKey, settings.port);
  }
}
