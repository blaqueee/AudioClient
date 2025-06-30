import 'package:equatable/equatable.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object> get props => [];
}

class ConnectAllRequested extends ConnectionEvent {
  final String wsUrl;
  final String tcpAddress;
  final String selectedListItem;

  const ConnectAllRequested({
    required this.wsUrl,
    required this.tcpAddress,
    required this.selectedListItem,
  });

  @override
  List<Object> get props => [wsUrl, tcpAddress, selectedListItem];
}

class ReconnectAllRequested extends ConnectionEvent {
  final String wsUrl;
  final String tcpAddress;
  final String selectedListItem;

  const ReconnectAllRequested({
    required this.wsUrl,
    required this.tcpAddress,
    required this.selectedListItem,
  });

  @override
  List<Object> get props => [wsUrl, tcpAddress, selectedListItem];
}

class DisconnectAllRequested extends ConnectionEvent {
  const DisconnectAllRequested();
}

class ConnectionTcpConnected extends ConnectionEvent {
  final String tcpAddress;
  const ConnectionTcpConnected({required this.tcpAddress});
  @override
  List<Object> get props => [tcpAddress];
}