abstract class BaseService {
  String get tableName;

  Future<Map<String, dynamic>?> getById(String id);
  Future<List<Map<String, dynamic>>> getAll();
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}
