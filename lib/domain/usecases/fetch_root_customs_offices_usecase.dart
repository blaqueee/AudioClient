import 'package:audio_client/data/models/customs_office_model.dart';
import 'package:audio_client/domain/repositories/customs_office_repository.dart';

class FetchRootCustomsOfficesUseCase {
  final CustomsOfficeRepository repository;

  FetchRootCustomsOfficesUseCase(this.repository);

  Future<List<CustomsOfficeModel>> call() {
    return repository.fetchRootNodes();
  }
}