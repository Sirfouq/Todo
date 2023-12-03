abstract class DbService<T> {
  Future<int> insert(T item);
  Future<T?> get(int id);
  Future<List<T>> getAll();
  Future<int> update(T item);
  Future<int> delete(int id);
}
