import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/services/db_service.dart';

class SqfliteService<T> implements DbService<T> {
  final String tableName;
  final String dbName;
  final int dbVersion;
  final Function(Map<String, dynamic>) fromMap; // Converts map to T
  final Map<String, dynamic> Function(T) toMap;

  SqfliteService({
    required this.tableName,
    required this.dbName,
    required this.dbVersion,
    required this.fromMap,
    required this.toMap,
  });

  Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

 initDB() async {
  String path = join(await getDatabasesPath(), dbName);
  return await openDatabase(path, version: dbVersion, onCreate: (db, version) {
    return db.execute(
      'CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT, isCompleted INTEGER)',
    );
  });
}


  @override
  Future<int> insert(T item) async {
    final db = await database;
    return await db!.insert(tableName, toMap(item));
  }

  @override
  Future<T?> get(int id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db!.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return fromMap(results.first);
  }

 @override
Future<List<T>> getAll() async {
  final db = await database;
  var results = await db!.query(tableName);
  return results.map<T>((item) => fromMap(item)).toList();
}


  @override
  Future<int> update(T item) async {
    final db = await database;
    // Assuming T has an id property
    return await db!.update(tableName, toMap(item), where: 'id = ?', whereArgs: [(item as dynamic).id]);
  }

  @override
  Future<int> delete(int id) async {
    final db = await database;
    return await db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
