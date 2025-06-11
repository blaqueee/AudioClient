import 'dart:convert';

import 'package:audio_client/data/models/command_dto_model.dart';
import 'package:audio_client/domain/usecases/handle_command_usecase.dart';
import 'package:audio_client/presentation/bloc/websocket_event.dart';
import 'package:audio_client/presentation/bloc/websocket_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final HandleCommandUseCase _handleCommandUseCase;

  WebSocketBloc(this._handleCommandUseCase) : super(WebSocketInitial()) {
    on<WebSocketMessageReceived>(_onMessageReceived);
  }

  Future<void> _onMessageReceived(
    WebSocketMessageReceived event,
    Emitter<WebSocketState> emit,
  ) async {
    try {
      print('Received WebSocket message: ${event.message}');
      
      // Проверяем, что сообщение не пустое
      if (event.message.isEmpty) {
        throw Exception('Received empty message');
      }

      // Пытаемся распарсить JSON
      Map<String, dynamic> json;
      try {
        json = jsonDecode(event.message) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Failed to parse JSON: $e');
      }

      // Проверяем наличие необходимых полей
      if (!json.containsKey('command')) {
        throw Exception('Message does not contain "command" field');
      }
      if (!json.containsKey('data')) {
        throw Exception('Message does not contain "data" field');
      }
      if (!(json['data'] is Map)) {
        throw Exception('"data" field is not an object');
      }
      if (!(json['data'] as Map).containsKey('url')) {
        throw Exception('"data" object does not contain "url" field');
      }

      final command = CommandDtoModel.fromJson(json);
      print('Parsed command: ${command.command}, URL: ${command.data.url}');
      
      await _handleCommandUseCase.execute(command);
      emit(WebSocketMessageProcessed());
    } catch (e) {
      print('Error processing WebSocket message: $e');
      emit(WebSocketError(e.toString()));
    }
  }
} 