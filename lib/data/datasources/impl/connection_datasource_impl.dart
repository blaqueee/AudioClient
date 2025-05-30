import 'package:audio_client/core/configs/environment.dart';
import 'package:audio_client/core/services/db_service.dart';
import 'package:audio_client/core/utils/methods.dart';
import 'package:audio_client/data/datasources/connection_datasource.dart';
import 'package:dio/dio.dart';

class ConnectionDataSourceImpl extends ConnectionDataSource {
  final Dio dio;

  ConnectionDataSourceImpl({required this.dio});

  @override
  Future<void> signIn({ required String url }) async {
    try {
      String httpUrl = getHttpFromWs(url);

      dio.options = BaseOptions(baseUrl: httpUrl);

      var userData = convertStringToMap(Environment.WEBSOCKET_USER);

      var response = await dio.post("/callback", data: {
        'username': userData['username'],
        'password': userData['password']
      });

      if (response.statusCode == 200) {
        final jsessionId = await parseCookie(response.headers["set-cookie"]?.first);
        final csrfToken = response.headers["x-csrf-token"]?.first;

        await DBService.set("JSESSIONID", jsessionId);
        await DBService.set("CSRF-TOKEN", csrfToken);

        print(response.headers);
        return;
      }

      throw Exception('Failed to sign in');
    } catch (e) {
      rethrow;
    }
  }

}