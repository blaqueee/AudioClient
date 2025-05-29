import 'package:audio_client/domain/entities/command_dto.dart';
import 'package:audio_client/domain/repositories/connection_repository.dart';

class HandleCommandUseCase {
  final ConnectionRepository repository;

  HandleCommandUseCase(this.repository);

  Future<void> execute(CommandDto command) async {
    if (command.command == 'play') {
      await repository.playAudio(command.data.url);
    }
  }
} 