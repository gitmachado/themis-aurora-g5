import '../entities/lead.dart';

abstract interface class LeadRepository {
  Future<List<Lead>> getPending();
  Future<Lead> getById(String id);
  Future<void> convert(String id);
  Future<void> discard(String id, {String? reason});
}
