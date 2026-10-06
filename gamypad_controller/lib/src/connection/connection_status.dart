/// Where this half believes it stands with the PC.
///
/// The transport owns this. Nothing else sets it, so "am I connected?" has
/// exactly one answer instead of being re-derived by every caller from socket
/// internals.
///
/// Replaces the old `ClientState.isConnected` bool, which could not tell
/// "never got there" from "was there and lost it" — the difference the UI
/// needs in order to say "not connected" rather than "connection lost".
enum ConnectionStatus {
  /// No socket. Either nothing has been asked for yet, or `disconnect` has run.
  disconnected,

  /// `connect` is in flight. UDP has no handshake, so this covers name
  /// resolution and bind() — the only parts that can fail before packets flow.
  connecting,

  /// Socket is bound and we are exchanging packets with the target.
  connected,

  /// Was connected, and the watchdog stopped hearing from the target.
  ///
  /// Deliberately distinct from [disconnected]: the peer went away mid-session
  /// rather than never being reached.
  lost,
}
