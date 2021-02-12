import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

// Database structure
// abstraction: table -> class, column -> property
// Usage: SQL.table.self - table name, SQL.table.column - column name
class TableFruits {
  // table name
  String get self => 'fruits';

  // columns
  String get id => 'id';

  String get name => 'name';

  String get amount => 'amount';
}

// Database control functions
class SQL {
  static const _dbName = 'fruits.db';
  static const _dbVersion = 1;

  // define tables
  static final fruits = TableFruits();

  // define keys: table -> key
  static final keys = {fruits.self: fruits.id};

  // initialize database, create if not exists
  static Future<Database> init() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(path.join(dbPath, _dbName),
        onCreate: (db, version) async {
      // ''' avoids breaks in text
      await db.execute('''CREATE TABLE ${fruits.self} (
          ${fruits.id} integer primary key autoincrement, 
          ${fruits.name} name text not null, 
          ${fruits.amount} amount integer not null)
          ''');
    }, version: _dbVersion);
  }

  // insert data => inserted row id
  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await SQL.init();
    return await db.insert(
      table, // INSERT INTO table
      data, // {col: value}
      conflictAlgorithm: ConflictAlgorithm.replace, // replace if key exists
    );
  }

  // select all table
  static Future<List<Map<String, dynamic>>> select(String table) async {
    final db = await SQL.init();
    return await db.query(table);
  }

  // update row => updated row id
  static Future<int> update(String table, Map<String, dynamic> data) async {
    final db = await SQL.init();
    return await db.update(
      table, // UPDATE table
      data, // SET {col: value}
      where: '${keys[table]} = ?', // WHERE id = ...
      whereArgs: [data[keys[table]]], // ... data[id]
      conflictAlgorithm: ConflictAlgorithm.ignore, // skip if error
    );
  }

  // delete row => number of rows deleted
  static Future<int> delete(String table, int id) async {
    final db = await SQL.init();
    return await db.delete(
      table, // DELETE FROM table
      where: '${keys[table]} = ?', // WHERE id = ...
      whereArgs: [id], // ... idValue
    );
  }

  // delete all table data => number of rows deleted
  static Future<int> deleteAll(String table) async {
    final db = await SQL.init();
    return await db.delete(table);
  }

  // delete  all database
  static Future<void> drop() async {
    final dbPath = await getDatabasesPath();
    await deleteDatabase(dbPath);
  }
}
