import 'package:audio_client/data/models/customs_office_model.dart';

abstract class CustomsOfficeRepository {
  Future<List<CustomsOfficeModel>> fetchRootNodes();
  Future<List<CustomsOfficeModel>> fetchChildNodes(String parentId);
}