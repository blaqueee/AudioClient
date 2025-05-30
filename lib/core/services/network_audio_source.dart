import 'package:just_audio/just_audio.dart';

class NetworkAudioSource extends StreamAudioSource {
  final Stream<List<int>> byteStream;
  final String contentType;

  NetworkAudioSource(
      this.byteStream, {
        required this.contentType
      }) : super(tag: 'network-audio-stream-${DateTime.now().millisecondsSinceEpoch}');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    return StreamAudioResponse(
      sourceLength: null,
      contentLength: null,
      offset: 0,
      stream: byteStream,
      contentType: contentType,
    );
  }
}