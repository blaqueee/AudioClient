import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_client/domain/repositories/connection_repository.dart';
import 'package:audio_client/service/network_audio_source.dart';
import 'package:just_audio/just_audio.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';


class ConnectionRepositoryImpl implements ConnectionRepository {
  WebSocketChannel? _webSocketChannel;
  Socket? _tcpSocket;
  StreamSubscription? _wsStreamSubscription;

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamController<List<int>>? _audioStreamController;
  final String _audioContentType = 'audio/mpeg';

  @override
  Future<void> connectWebSocket(String url) async {

    final completer = Completer<void>();
    const Duration connectionTimeout = Duration(seconds: 7);

    try {
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(url));

      _wsStreamSubscription = _webSocketChannel!.stream.listen(
            (message) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.completeError(Exception('WebSocket stream error: $error'));
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            if (_webSocketChannel?.closeCode != null && _webSocketChannel?.closeCode != status.normalClosure) {
              completer.completeError(Exception('WebSocket connection closed with code: ${_webSocketChannel?.closeCode}'));
            } else {
              completer.completeError(Exception('The WebSocket stream was closed without explicit confirmation of the connection being established'));
            }
          }
        },
      );

      _webSocketChannel!.sink.done.then((_) {
        if (!completer.isCompleted && _webSocketChannel?.closeCode != status.normalClosure) {
          completer.completeError(Exception('Sink WebSocket finished with error, code: ${_webSocketChannel?.closeCode}'));
        }
      }).catchError((error) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('Error Sink WebSocket: $error'));
        }
      });

      await completer.future.timeout(connectionTimeout, onTimeout: () {
        _wsStreamSubscription?.cancel();
        _wsStreamSubscription = null;
        _webSocketChannel?.sink.close(status.goingAway, 'Client timeout').catchError((_) {});
        _webSocketChannel = null;
        throw TimeoutException('WebSocket connection timeout', connectionTimeout);
      });

    } catch (e) {
      await _wsStreamSubscription?.cancel();
      _wsStreamSubscription = null;
      _webSocketChannel?.sink.close().catchError((_){});
      _webSocketChannel = null;
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
  }

  @override
  Future<void> connectTcp(String host, int port) async {
    await disconnectTcp();

    try {
      _tcpSocket = await Socket.connect(host, port, timeout: const Duration(seconds: 7));
      _audioStreamController = StreamController<List<int>>();

      _tcpSocket!.listen(
            (Uint8List data) {
          if (_audioStreamController != null && !_audioStreamController!.isClosed) {
            _audioStreamController!.add(data);
          }
        },
        onError: (error, stackTrace) {},
        onDone: () {},
        cancelOnError: true,
      );

      final audioSource = NetworkAudioSource(
        _audioStreamController!.stream,
        contentType: _audioContentType,
      );

      await _audioPlayer.setAudioSource(audioSource, preload: false);
      _audioPlayer.play();

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