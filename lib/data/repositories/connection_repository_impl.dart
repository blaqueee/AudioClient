import 'dart:async';
import 'dart:io';

import 'package:audio_client/core/services/db_service.dart';
import 'package:audio_client/data/datasources/connection_datasource.dart';
import 'package:audio_client/domain/repositories/connection_repository.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  final ConnectionDataSource dataSource;

  ConnectionRepositoryImpl({ required this.dataSource });

  WebSocketChannel? _webSocketChannel;
  Socket? _tcpSocket;
  StreamSubscription? _wsStreamSubscription;
  var _webSocketController = StreamController<dynamic>.broadcast();
  Timer? _reconnectTimer;
  String? _lastWebSocketUrl;
  bool _manuallyDisconnected = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  ProcessingState? processingState;

  @override
  Stream<dynamic> get webSocketStream => _webSocketController.stream;

  @override
  Future<void> connectWebSocket(String url) async {
    if (_webSocketController.isClosed) {
      _webSocketController = StreamController<dynamic>.broadcast();
    }

    await dataSource.signIn(url: url);

    _lastWebSocketUrl = url;
    _manuallyDisconnected = false;
    final completer = Completer<void>();

    try {
      final uri = Uri.parse(url);
      var jsessionid = await DBService.get("JSESSIONID");
      var csrfToken = await DBService.get("CSRF-TOKEN");

      _webSocketChannel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'Cookie': 'JSESSIONID=$jsessionid;CSRF-TOKEN=$csrfToken'
        },
      );

      Timer(const Duration(seconds: 2), () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      _wsStreamSubscription = _webSocketChannel!.stream.listen(
            (message) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          _webSocketController.add(message);
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.completeError(
                Exception('WebSocket stream error: $error'));
          }
          _scheduleReconnect();
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.completeError(Exception('WebSocket connection closed unexpectedly'));
          }
          if (!_manuallyDisconnected &&
              _webSocketChannel?.closeCode != status.normalClosure) {
            _scheduleReconnect();
          }
        },
        cancelOnError: true,
      );

      await completer.future;
    } catch (e) {
      _scheduleReconnect();
      rethrow;
    }
  }


  @override
  Future<void> playAudio(String url) async {
    try {
      await _audioPlayer.stop();

      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.speech());


      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _audioPlayer.play();

    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> disconnectWebSocket() async {
    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _wsStreamSubscription?.cancel();
    _wsStreamSubscription = null;
    try {
      await _webSocketChannel?.sink.close(status.normalClosure);
    } catch (_) {}
    _webSocketChannel = null;
  }


  @override
  Future<void> connectTcp(String host, int port) async {
    await disconnectTcp();

    try {
      _tcpSocket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 7),
      );
      print('TCP connection established to $host:$port');
    } catch (e) {
      _tcpSocket = null;
      rethrow;
    }
  }

  @override
  Future<void> disconnectTcp() async {
    if (_tcpSocket == null) {
      return;
    }
    try {
      _tcpSocket?.destroy();
    } catch (e) {}
    _tcpSocket = null;
  }

  @override
  Future<void> disconnectAll() async {
    await disconnectWebSocket();
    await disconnectTcp();
    if (!_webSocketController.isClosed) {
      await _webSocketController.close();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    if (_lastWebSocketUrl == null || _manuallyDisconnected) return;

    _reconnectTimer = Timer(const Duration(seconds: 10), () async {
      try {
        await connectWebSocket(_lastWebSocketUrl!);
      } catch (_) {
        _scheduleReconnect();
      }
    });
  }

}
