import 'package:audio_client/data/datasources/customs_office_datasource.dart';
import 'package:audio_client/data/models/customs_office_model.dart';
import 'package:dio/dio.dart';

class CustomsOfficeDataSourceImpl extends CustomsOfficeDataSource {
  final Dio dio;

  CustomsOfficeDataSourceImpl({ required this.dio });

  @override
  Future<List<CustomsOfficeModel>> fetchChildNodes(String parentId) async {
    try {
      var response = await dio.get("/ws/public/customs-office/by/parent?parentId=${int.tryParse(parentId)}");
      return response.data['data'].map<CustomsOfficeModel>((json) => CustomsOfficeModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CustomsOfficeModel>> fetchRootNodes() async {
    try {
      var response = await dio.get("/ws/public/customs-office/parents");

      return response.data['data'].map<CustomsOfficeModel>((json) => CustomsOfficeModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }


}