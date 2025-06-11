class CommandDto {
  final String command;
  final ObjectData data;

  CommandDto({
    required this.command,
    required this.data,
  });
}

class ObjectData {
  final String url;

  ObjectData({
    required this.url,
  });
} 