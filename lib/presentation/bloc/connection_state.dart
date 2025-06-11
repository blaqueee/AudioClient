enum SocketStatus { initial, connecting, connected, disconnected, error }

class ConnectionStatusState {
  final SocketStatus wsStatus;
  final String? wsUrl;
  final String? wsError;

  final SocketStatus tcpStatus;
  final String? tcpAddress;
  final String? tcpError;

  final String? activeListItem;

  const ConnectionStatusState({
    this.wsStatus = SocketStatus.initial,
    this.wsUrl,
    this.wsError,
    this.tcpStatus = SocketStatus.initial,
    this.tcpAddress,
    this.tcpError,
    this.activeListItem,
  });

  ConnectionStatusState copyWith({
    SocketStatus? wsStatus,
    String? wsUrl,
    String? wsError,
    bool clearWsError = false,
    SocketStatus? tcpStatus,
    String? tcpAddress,
    String? tcpError,
    bool clearTcpError = false,
    String? activeListItem,
    bool clearActiveListItem = false,
  }) {
    return ConnectionStatusState(
      wsStatus: wsStatus ?? this.wsStatus,
      wsUrl: wsUrl ?? this.wsUrl,
      wsError: clearWsError ? null : wsError ?? this.wsError,
      tcpStatus: tcpStatus ?? this.tcpStatus,
      tcpAddress: tcpAddress ?? this.tcpAddress,
      tcpError: clearTcpError ? null : tcpError ?? this.tcpError,
      activeListItem: clearActiveListItem ? null : activeListItem ?? this.activeListItem,
    );
  }

  bool get isFullyConnected => wsStatus == SocketStatus.connected;
  // bool get isFullyConnected => wsStatus == SocketStatus.connected && tcpStatus == SocketStatus.connected;
  bool get isAnyConnecting => wsStatus == SocketStatus.connecting;
  // bool get isAnyConnecting => wsStatus == SocketStatus.connecting || tcpStatus == SocketStatus.connecting;
  bool get isAnythingActiveOrConnecting =>
      wsStatus == SocketStatus.connected ||
          wsStatus == SocketStatus.connecting;
  // bool get isAnythingActiveOrConnecting =>
  //     wsStatus == SocketStatus.connected ||
  //         wsStatus == SocketStatus.connecting ||
  //         tcpStatus == SocketStatus.connected ||
  //         tcpStatus == SocketStatus.connecting;
  bool get isNothingConnectedAnymore =>
      (wsStatus == SocketStatus.initial || wsStatus == SocketStatus.disconnected || wsStatus == SocketStatus.error);
  // bool get isNothingConnectedAnymore =>
  //     (wsStatus == SocketStatus.initial || wsStatus == SocketStatus.disconnected || wsStatus == SocketStatus.error) &&
  //         (tcpStatus == SocketStatus.initial || tcpStatus == SocketStatus.disconnected || tcpStatus == SocketStatus.error);
}