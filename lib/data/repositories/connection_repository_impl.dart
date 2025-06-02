import 'dart:async';
import 'dart:io';

import 'package:audio_client/core/services/db_service.dart';
import 'package:audio_client/domain/repositories/connection_repository.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  WebSocketChannel? _webSocketChannel;
  Socket? _tcpSocket;
  StreamSubscription? _wsStreamSubscription;
  final _webSocketController = StreamController<dynamic>.broadcast();

  final AudioPlayer _audioPlayer = AudioPlayer();
  ProcessingState? processingState;

  @override
  Stream<dynamic> get webSocketStream => _webSocketController.stream;

  @override
  Future<void> connectWebSocket(String url) async {
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

      _wsStreamSubscription = _webSocketChannel!.stream.listen(
        (message) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          _webSocketController.add(message);
        },
        onError: (error, stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception('WebSocket stream error: $error'),
            );
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            if (_webSocketChannel?.closeCode != null &&
                _webSocketChannel?.closeCode != status.normalClosure) {
              completer.completeError(
                Exception(
                  'WebSocket connection closed with code: ${_webSocketChannel?.closeCode}',
                ),
              );
            } else {
              completer.completeError(
                Exception(
                  'The WebSocket stream was closed without explicit confirmation of the connection being established',
                ),
              );
            }
          }
        },
      );

    } catch (e, stackTrace) {
      await _wsStreamSubscription?.cancel();
      _wsStreamSubscription = null;
      _webSocketChannel?.sink.close().catchError((_) {});
      _webSocketChannel = null;
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
    if (_webSocketChannel == null && _wsStreamSubscription == null) {
      return;
    }
    await _wsStreamSubscription?.cancel();
    _wsStreamSubscription = null;
    try {
      await _webSocketChannel?.sink.close(status.normalClosure);
    } catch (e) {}
    _webSocketChannel = null;
    await _webSocketController.close();
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
  }
}
