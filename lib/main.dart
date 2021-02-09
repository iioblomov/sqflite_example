import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: MyHomePage());
}

class SQL {
  static const _dbName = 'fruits.db';
  static const _dbVersion = 1;
  static const tabFruits = 'fruits';
  static const colId = 'id';
  static const colName = 'name';
  static const colAmount = 'amount';

  // Initialize database, create if not exists
  static Future<sql.Database> init() async {
    final dbPath = await sql.getDatabasesPath();
    return await sql.openDatabase(path.join(dbPath, _dbName),
        onCreate: (db, version) {
      // ''' avoids breaks in text
      return db.execute('''CREATE TABLE $tabFruits (
          $colId integer primary key autoincrement, 
          $colName name text not null, 
          $colAmount amount integer not null)
          ''');
    }, version: _dbVersion);
  }

  // insert data
  static Future<int> insert(String table, Map<String, Object> data) async {
    final db = await SQL.init();
    // insert and replace if key exists
    return await db.insert(table, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  // select all table
  static Future<List<Map<String, dynamic>>> select(String table) async {
    final db = await SQL.init();
    return db.query(table);
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sqflite Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('The result is displayed at the console.'),
            RaisedButton(
              onPressed: () async {
                final second = DateTime.now().second;
                final id = await SQL.insert(SQL.tabFruits, {
                  SQL.colName: (second > 30) ? 'apple' : 'orange',
                  SQL.colAmount: second,
                });
                print('element with "$id" added to table "${SQL.tabFruits}"');
              },
              child: Text('Insert'),
            ),
            RaisedButton(
              onPressed: () async {
                final data = await SQL.select(SQL.tabFruits);
                data.forEach((element) {
                  print(element);
                });
              },
              child: Text('Select'),
            )
          ],
        ),
      ),
    );
  }
}