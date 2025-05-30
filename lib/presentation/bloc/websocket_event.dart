abstract class WebSocketEvent {}

class WebSocketMessageReceived extends WebSocketEvent {
  final String message;

  WebSocketMessageReceived(this.message);
} 