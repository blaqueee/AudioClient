abstract class ConnectionEvent {}

class ConnectAllRequested extends ConnectionEvent {
  final String wsUrl;
  final String tcpAddress;
  final String selectedListItem;

  ConnectAllRequested({
    required this.wsUrl,
    required this.tcpAddress,
    required this.selectedListItem,
  });
}

class ReconnectAllRequested extends ConnectionEvent {
  final String wsUrl;
  final String tcpAddress;
  final String selectedListItem;

  ReconnectAllRequested({
    required this.wsUrl,
    required this.tcpAddress,
    required this.selectedListItem,
  });
}

class DisconnectAllRequested extends ConnectionEvent {}