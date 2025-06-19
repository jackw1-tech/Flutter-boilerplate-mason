abstract class BaseRepository<T extends BaseModel> {
  Future<List<T>> getAll();

  Future<T?> get(String id);

  Future<T> create(T entity);
  Future<T> update(T entity);

  Future<void> delete(String id);
}
