/// Gives a random port
const int _minPort = 1;

/// Highest valid port.
const int _maxPort = 65535;

sealed class ConnectionTarget {
  final String host;
  final int port;

  ConnectionTarget({required this.host, required this.port});
}

class UdpTarget extends ConnectionTarget {
  UdpTarget({required super.host, required super.port});

  factory UdpTarget.parse(String payload) {
    final trimmed = payload.trim();
    final separator = trimmed.indexOf(':');
    if (separator < 0) {
      throw FormatException('Expected "host:port", got "$payload"');
    }

    final host = trimmed.substring(0, separator);
    if (host.isEmpty) {
      throw FormatException('Missing host in "$payload"');
    }

    final port = trimmed.substring(separator + 1);
    final parsed = int.tryParse(port);
    if (parsed == null || parsed < _minPort || parsed > _maxPort) {
      throw FormatException(
        'Port must be $_minPort..$_maxPort, got "$port" in "$payload"',
      );
    }

    return UdpTarget(host: host, port: parsed);
  }

  static UdpTarget? tryParse(String payload) {
    try {
      return UdpTarget.parse(payload);
    } on FormatException {
      return null;
    }
  }

  @override
  String toString() => '$host:$port';
}
