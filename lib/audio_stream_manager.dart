import 'dart:convert';
import 'dart:io';
import 'package:audio_client/presentation/bloc/connection_bloc.dart';
import 'package:audio_client/presentation/bloc/connection_event.dart';

class AudioStreamManager {
  Socket? _socket;
  Process? _ffplayProcess;
  final String serverHost;
  final int serverPort;
  final String customsofficeId;
  final ConnectionBloc connectionBloc;
  final String tcpAddress;

  bool _isConnected = false;
  bool _ffplayRunning = false;

  AudioStreamManager({
    required this.serverHost,
    required this.serverPort,
    required this.customsofficeId,
    required this.connectionBloc,
    required this.tcpAddress,
  });

  Future<void> connectAndListen() async {
    try {
      _socket = await Socket.connect(serverHost, serverPort);

      _isConnected = true;
      connectionBloc.add(ConnectionTcpConnected(tcpAddress: tcpAddress));

      _socket!.add(utf8.encode(customsofficeId + '\n'));

      await _startFfplay();

      _socket!.listen(
            (data) {
          if (_ffplayProcess != null && _ffplayRunning) {
            _ffplayProcess!.stdin.add(data);
          }
        },
        onDone: () {
          _isConnected = false;
          _stopFfplay();
        },
        onError: (error) {
          _isConnected = false;
          _stopFfplay();
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('❗ Error connecting: $e');
    }
  }

  Future<void> _startFfplay() async {
    _ffplayProcess = await Process.start(
      'ffplay',
      [
        '-f', 's16le',
        '-ar', '48000',
        '-nodisp',
        '-i', 'pipe:0',
      ],
      runInShell: true,
    );
    _ffplayRunning = true;

    _ffplayProcess!.stderr.transform(utf8.decoder).listen((line) {});

    _ffplayProcess!.exitCode.then((code) {
      _ffplayRunning = false;
      _ffplayProcess = null;
    });
  }

  void _stopFfplay() {
    if (_ffplayProcess != null && _ffplayRunning) {
      _ffplayProcess!.stdin.close();
      _ffplayProcess!.kill();
      _ffplayProcess = null;
      _ffplayRunning = false;
    }
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _stopFfplay();
    _socket = null;
    _isConnected = false;
  }

  bool get isConnected => _isConnected;
}