import 'package:audio_client/domain/repositories/connection_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectionStatus { initial, connected, disconnected, error }

class ConnectionStatusState {
  final ConnectionStatus status;
  final String? error;

  const ConnectionStatusState({this.status = ConnectionStatus.initial, this.error});
}

class ConnectionBloc extends Cubit<ConnectionStatusState> {
  final ConnectionRepository repository;

  ConnectionBloc(this.repository) : super(const ConnectionStatusState());

  Future<void> connect(String wsUrl, String tcpUrl) async {
    try {
      emit(const ConnectionStatusState(status: ConnectionStatus.initial));
      final uri = Uri.parse(tcpUrl);
      await repository.connectWebSocket(wsUrl);
      await repository.connectTcp(uri.host, uri.port);
      emit(const ConnectionStatusState(status: ConnectionStatus.connected));
    } catch (e) {
      emit(ConnectionStatusState(status: ConnectionStatus.error, error: e.toString()));
    }
  }

  Future<void> reconnect(String wsUrl, String tcpUrl) async {
    await disconnect();
    await connect(wsUrl, tcpUrl);
  }

  Future<void> disconnect() async {
    await repository.disconnect();
    emit(const ConnectionStatusState(status: ConnectionStatus.disconnected));
  }
}