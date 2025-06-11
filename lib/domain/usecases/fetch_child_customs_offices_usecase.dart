import 'package:audio_client/data/models/customs_office_model.dart';
import 'package:audio_client/domain/repositories/customs_office_repository.dart';

class FetchChildCustomsOfficesUseCase {
  final CustomsOfficeRepository repository;

  FetchChildCustomsOfficesUseCase(this.repository);

  Future<List<CustomsOfficeModel>> call(String parentId) {
    return repository.fetchChildNodes(parentId);
  }
}