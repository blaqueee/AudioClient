import 'dart:async';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/repositories/connection_repository.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  WebSocketChannel? _webSocketChannel;
  Socket? _tcpSocket;

  @override
  Future<void> connectWebSocket(String url) async {
    _webSocketChannel = WebSocketChannel.connect(Uri.parse(url));
  }

  @override
  Future<void> connectTcp(String host, int port) async {
    _tcpSocket = await Socket.connect(host, port);
  }

  @override
  Future<void> disconnect() async {
    await _webSocketChannel?.sink.close();
    _tcpSocket?.destroy();
  }
}