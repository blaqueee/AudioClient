abstract class WebSocketState {}

class WebSocketInitial extends WebSocketState {}

class WebSocketMessageProcessed extends WebSocketState {}

class WebSocketError extends WebSocketState {
  final String message;

  WebSocketError(this.message);
} 