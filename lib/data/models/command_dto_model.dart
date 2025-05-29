import 'package:audio_client/domain/entities/command_dto.dart';

class CommandDtoModel extends CommandDto {
  CommandDtoModel({
    required super.command,
    required super.data,
  });

  factory CommandDtoModel.fromJson(Map<String, dynamic> json) {
    return CommandDtoModel(
      command: json['command'] as String,
      data: ObjectDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'data': (data as ObjectDataModel).toJson(),
    };
  }
}

class ObjectDataModel extends ObjectData {
  ObjectDataModel({
    required super.url,
  });

  factory ObjectDataModel.fromJson(Map<String, dynamic> json) {
    return ObjectDataModel(
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }
} 