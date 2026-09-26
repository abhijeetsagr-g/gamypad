class ClientState {
  final bool isConnected;
  final String? address;
  final int? port;
  final String? error;
  final bool? isLoading;

  const ClientState({
    this.isConnected = false,
    this.address,
    this.port,
    this.error,
    this.isLoading,
  });

  ClientState copyWith({
    bool? isConnected,
    String? address,
    int? port,
    String? error,
    bool? isLoading,
  }) => ClientState(
    isConnected: isConnected ?? this.isConnected,
    address: address ?? this.address,
    port: port ?? this.port,
    error: error,
    isLoading: isLoading ?? this.isLoading,
  );
}
