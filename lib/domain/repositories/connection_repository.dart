abstract class ConnectionRepository {
  Future<void> connectWebSocket(String url);
  Future<void> disconnectWebSocket();
  Future<void> connectTcp(String host, int port);
  Future<void> disconnectTcp();
  Future<void> disconnectAll();
  Future<void> playAudio(String url);
  Stream<dynamic> get webSocketStream;
}