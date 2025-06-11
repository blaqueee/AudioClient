import 'package:audio_client/domain/repositories/connection_repository.dart';
import 'package:audio_client/presentation/bloc/connection_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionStatusState> {
  final ConnectionRepository repository;

  String? _lastWsUrl;
  String? _lastTcpAddress;
  String? _lastSelectedItem;

  ConnectionBloc(this.repository) : super(const ConnectionStatusState()) {
    on<ConnectAllRequested>(_onConnectAllRequested);
    on<ReconnectAllRequested>(_onReconnectAllRequested);
    on<DisconnectAllRequested>(_onDisconnectAllRequested);
  }

  Future<void> _performConnect(
      String wsUrl, String tcpAddressString, String selectedItem, Emitter<ConnectionStatusState> emit) async {
    _lastWsUrl = wsUrl;
    _lastTcpAddress = tcpAddressString;
    _lastSelectedItem = selectedItem;

    final parts = tcpAddressString.split(':');
    if (parts.length != 2) {
      emit(state.copyWith(
          tcpStatus: SocketStatus.error,
          tcpError: "Invalid TCP format (expected host:port)",
          activeListItem: selectedItem,
          wsStatus: SocketStatus.initial,
          clearWsError: true
      ));
      return;
    }
    final String host = parts[0];
    final int? port = int.tryParse(parts[1]);

    if (port == null) {
      emit(state.copyWith(
          tcpStatus: SocketStatus.error,
          tcpError: "Invalid host for TCP address",
          activeListItem: selectedItem,
          wsStatus: SocketStatus.initial,
          clearWsError: true
      ));
      return;
    }

    emit(state.copyWith(
        wsStatus: SocketStatus.connecting,
        tcpStatus: SocketStatus.connecting,
        activeListItem: selectedItem,
        wsUrl: wsUrl,
        tcpAddress: tcpAddressString,
        clearWsError: true,
        clearTcpError: true));

    bool wsSuccess = false;
    try {
      await repository.connectWebSocket(wsUrl);
      wsSuccess = true;
      emit(state.copyWith(wsStatus: SocketStatus.connected, wsUrl: wsUrl));
    } catch (e) {
      emit(state.copyWith(wsStatus: SocketStatus.error, wsError: e.toString()));
    }

    // bool tcpSuccess = false;
    // try {
    //   await repository.connectTcp(host, port);
    //   tcpSuccess = true;
    //   emit(state.copyWith(
    //       tcpStatus: SocketStatus.connected,
    //       tcpAddress: tcpAddressString));
    // } catch (e) {
    //   emit(state.copyWith(tcpStatus: SocketStatus.error, tcpError: e.toString()));
    // }

    // if (!wsSuccess && !tcpSuccess) {
      // Error TODO
    if (!wsSuccess) {
      // Error TODO
    }
    // else if (!tcpSuccess) {
    //   // Error TODO
    // }
  }

  Future<void> _performDisconnect(Emitter<ConnectionStatusState> emit) async {

    SocketStatus finalWsStatus = SocketStatus.disconnected;
    SocketStatus finalTcpStatus = SocketStatus.disconnected;
    String? wsError;
    String? tcpError;

    try {
      await repository.disconnectWebSocket();
    } catch (e) {
      finalWsStatus = SocketStatus.error;
      wsError = "Error while disconnecting websocket: ${e.toString()}";
    }

    try {
      await repository.disconnectTcp();
    } catch (e) {
      finalTcpStatus = SocketStatus.error;
      tcpError = "Error while disconnection TCP socket: ${e.toString()}";
    }

    _lastWsUrl = null;
    _lastTcpAddress = null;
    _lastSelectedItem = null;

    emit(ConnectionStatusState(
        wsStatus: finalWsStatus,
        wsError: wsError,
        tcpStatus: finalTcpStatus,
        tcpError: tcpError,
        activeListItem: null
    ));
  }

  Future<void> _onConnectAllRequested(ConnectAllRequested event, Emitter<ConnectionStatusState> emit) async {
    await _performConnect(event.wsUrl, event.tcpAddress, event.selectedListItem, emit);
  }

  Future<void> _onDisconnectAllRequested(DisconnectAllRequested event, Emitter<ConnectionStatusState> emit) async {
    await _performDisconnect(emit);
  }

  Future<void> _onReconnectAllRequested(ReconnectAllRequested event, Emitter<ConnectionStatusState> emit) async {
    await _performDisconnect(emit);

    await Future.delayed(const Duration(milliseconds: 50));

    await _performConnect(event.wsUrl, event.tcpAddress, event.selectedListItem, emit);
  }
}