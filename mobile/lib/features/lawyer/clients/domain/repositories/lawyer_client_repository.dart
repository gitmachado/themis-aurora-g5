import '../entities/lawyer_client.dart';

abstract interface class LawyerClientRepository {
  Future<List<LawyerClient>> getMyClients();
  Future<LawyerClient> getById(String id);
}
