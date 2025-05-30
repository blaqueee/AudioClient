import 'package:audio_client/data/datasources/customs_office_datasource.dart';
import 'package:audio_client/data/models/customs_office_model.dart';
import 'package:audio_client/domain/repositories/customs_office_repository.dart';

class CustomsOfficeRepositoryImpl extends CustomsOfficeRepository {
  final CustomsOfficeDataSource dataSource;

  CustomsOfficeRepositoryImpl({ required this.dataSource });

  @override
  Future<List<CustomsOfficeModel>> fetchChildNodes(String parentId) async => await dataSource.fetchChildNodes(parentId);

  @override
  Future<List<CustomsOfficeModel>> fetchRootNodes() async => await dataSource.fetchRootNodes();

}