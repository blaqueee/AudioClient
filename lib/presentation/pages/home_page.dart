import 'dart:async';

import 'package:audio_client/core/services/dio_service.dart';
import 'package:audio_client/core/utils/methods.dart';
import 'package:audio_client/di.dart';
import 'package:audio_client/domain/repositories/connection_repository.dart';
import 'package:audio_client/presentation/bloc/connection_bloc.dart';
import 'package:audio_client/presentation/bloc/connection_event.dart';
import 'package:audio_client/presentation/bloc/connection_state.dart';
import 'package:audio_client/presentation/bloc/websocket_bloc.dart';
import 'package:audio_client/presentation/bloc/websocket_event.dart';
import 'package:audio_client/presentation/components/customs_office_selector.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_treeview/flutter_treeview.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _wsController = TextEditingController();
  final TextEditingController _tcpController = TextEditingController();
  final Dio dio = DioService.dio;

  final TreeViewController _treeController = TreeViewController(children: []);
  String? _selectedCustomsOfficeId;

  late final ConnectionBloc _connectionBloc;
  late final WebSocketBloc _webSocketBloc;
  StreamSubscription? _webSocketSubscription;

  @override
  void initState() {
    super.initState();
    _connectionBloc = getIt<ConnectionBloc>();
    _webSocketBloc = getIt<WebSocketBloc>();

    _wsController.addListener(() {
      if (_wsController.text.isEmpty) return;
      String httpUrl = getHttpFromWs(_wsController.text);
      dio.options.baseUrl = httpUrl;
    });
    _wsController.text = 'ws://localhost:8080/audio/web-socket-endpoint';

    _tcpController.text = 'localhost:12346';

    _setupWebSocketListener();
  }

  void _setupWebSocketListener() {
    final repository = getIt<ConnectionRepository>();
    _webSocketSubscription = repository.webSocketStream.listen(
      (message) {
        _webSocketBloc.add(WebSocketMessageReceived(message.toString()));
      },
    );
  }

  void _handleConnect() {
    final String wsUrl = '${_wsController.text.trim()}?id=$_selectedCustomsOfficeId';
    final String tcpAddress = _tcpController.text.trim();

    if (wsUrl.isEmpty) {
      _showErrorSnackbar(AppLocalizations.of(context)!.enterWsAddress);
      return;
    }
    if (tcpAddress.isEmpty) {
      _showErrorSnackbar(AppLocalizations.of(context)!.enterTcpAddress);
      return;
    }
    if (_selectedCustomsOfficeId == null || _selectedCustomsOfficeId!.isEmpty) {
      _showErrorSnackbar(AppLocalizations.of(context)!.selectFromTree);
      return;
    }
    if (!_isValidTcpAddress(tcpAddress)) {
      _showErrorSnackbar(AppLocalizations.of(context)!.invalidTcpFormat);
      return;
    }

    _connectionBloc.add(ConnectAllRequested(
      wsUrl: wsUrl,
      tcpAddress: tcpAddress,
      selectedListItem: _selectedCustomsOfficeId!,
    ));
  }

  void _handleDisconnect() {
    _connectionBloc.add(DisconnectAllRequested());
  }

  bool _isValidTcpAddress(String address) {
    final parts = address.split(':');
    if (parts.length != 2) return false;
    if (parts[0].isEmpty) return false;
    if (int.tryParse(parts[1]) == null) return false;
    return true;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _statusToString(SocketStatus status) {
    switch (status) {
      case SocketStatus.initial: return AppLocalizations.of(context)!.notConnected;
      case SocketStatus.connecting: return AppLocalizations.of(context)!.connecting;
      case SocketStatus.connected: return AppLocalizations.of(context)!.connected;
      case SocketStatus.disconnected: return AppLocalizations.of(context)!.disconnected;
      case SocketStatus.error: return AppLocalizations.of(context)!.error;
      default: return AppLocalizations.of(context)!.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: BlocBuilder<ConnectionBloc, ConnectionStatusState>(
            bloc: _connectionBloc,
            builder: (context, state) {
              bool canInteract = !state.isAnyConnecting;
              bool canConnect = canInteract && !state.isFullyConnected;
              bool canReconnect = canInteract && (state.isFullyConnected || state.wsStatus == SocketStatus.error || state.tcpStatus == SocketStatus.error || state.wsStatus == SocketStatus.disconnected || state.tcpStatus == SocketStatus.disconnected);
              bool canDisconnect = canInteract && state.isAnythingActiveOrConnecting && !state.isNothingConnectedAnymore;


              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _wsController,
                      decoration: const InputDecoration(
                        labelText: 'WebSocket URL',
                        border: OutlineInputBorder(),
                      ),
                      enabled: canInteract,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // SizedBox(
                  //   height: 50,
                  //   child: TextField(
                  //     controller: _tcpController,
                  //     decoration: const InputDecoration(
                  //       labelText: 'TCP Address (host:port)',
                  //       border: OutlineInputBorder(),
                  //     ),
                  //     enabled: canInteract,
                  //   ),
                  // ),
                  // const SizedBox(height: 16),

                  SizedBox(
                    height: 60,
                    child: CustomsOfficeSelector(
                      onSelectionChanged: (label, id) {
                        setState(() {
                          _selectedCustomsOfficeId = id;
                        });
                      },
                    )
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildButton(AppLocalizations.of(context)!.buttonConnect, _handleConnect, enabled: canConnect),
                      _buildButton(AppLocalizations.of(context)!.buttonDisconnect, _handleDisconnect, enabled: canDisconnect),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    '${AppLocalizations.of(context)!.webSocket}: ${_statusToString(state.wsStatus)}',
                    style: TextStyle(fontSize: 16, color: state.wsStatus == SocketStatus.error ? Colors.red : Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  if (state.wsStatus == SocketStatus.error && state.wsError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('${AppLocalizations.of(context)!.errorWs}: ${state.wsError}', style: const TextStyle(fontSize: 12, color: Colors.red), textAlign: TextAlign.center),
                    ),
                  const SizedBox(height: 8),
                  // Text(
                  //   'TCP Socket: ${_statusToString(state.tcpStatus)} ${state.tcpAddress != null && state.tcpStatus == SocketStatus.connected ? "(${state.tcpAddress})" : ""}',
                  //   style: TextStyle(fontSize: 16, color: state.tcpStatus == SocketStatus.error ? Colors.red : Colors.black87),
                  //   textAlign: TextAlign.center,
                  // ),
                  // if (state.tcpStatus == SocketStatus.error && state.tcpError != null)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 4.0),
                  //     child: Text('Error TCP: ${state.tcpError}', style: const TextStyle(fontSize: 12, color: Colors.red), textAlign: TextAlign.center),
                  //   ),
                  if (state.isFullyConnected && state.activeListItem != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('${AppLocalizations.of(context)!.activeProfile}: ${state.activeListItem}', style: const TextStyle(fontSize: 14, color: Colors.deepPurple), textAlign: TextAlign.center),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, {required bool enabled}) {
    return SizedBox(
      width: 130,
      height: 45,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.only(left: 15, right: 15),
          backgroundColor: enabled ? Colors.deepPurple[100] : Colors.grey[300],
          foregroundColor: enabled ? Colors.deepPurple : Colors.grey[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  void dispose() {
    _wsController.dispose();
    _tcpController.dispose();
    _webSocketSubscription?.cancel();
    super.dispose();
  }
}