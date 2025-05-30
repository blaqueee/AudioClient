import 'package:dio/dio.dart';

class DioService {

  DioService._() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }


  static final DioService _instance = DioService._();

  late final Dio _dio;

  static Dio get dio => _instance._dio;

}
