abstract class ConnectionRepository {
  Future<void> connectWebSocket(String url);
  Future<void> connectTcp(String host, int port);
  Future<void> disconnect();
}