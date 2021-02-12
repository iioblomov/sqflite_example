import 'package:flutter/material.dart';

import 'sql.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: MyHomePage());
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
            Text('The result is displayed in the console.'),
            RaisedButton(
              child: Text('Insert'),
              onPressed: () async {
                final second = DateTime.now().second;
                final id = await SQL.insert(SQL.fruits.self, {
                  SQL.fruits.name: (second > 30) ? 'apple' : 'orange',
                  SQL.fruits.amount: second,
                });
                print('Row with "$id" added to table "${SQL.fruits.self}"');
              },
            ),
            RaisedButton(
              child: Text('Select'),
              onPressed: () async {
                final data = await SQL.select(SQL.fruits.self);
                data.forEach((e) => print(e));
              },
            ),
            RaisedButton(
              child: Text('Update'),
              onPressed: () async {
                final data = await SQL.select(SQL.fruits.self); // select all
                if (data.length != 0) {
                  // update first element if data exists
                  final id = await SQL.update(SQL.fruits.self, {
                    SQL.fruits.name: 'updated Fruit no.1',
                    SQL.fruits.amount: '99999999',
                    SQL.fruits.id: data.first[SQL.fruits.id],
                  });
                  print('Row "$id" updated. Press "Select" to see changes');
                } else {
                  print('nothing to update');
                }
              },
            ),
            RaisedButton(
              child: Text('Delete'),
              onPressed: () async {
                final data = await SQL.select(SQL.fruits.self); // select all
                if (data.length != 0) {
                  // delete last element if data exists
                  final num = await SQL.delete(
                    SQL.fruits.self,
                    data.last[SQL.fruits.id],
                  );
                  print('$num element(s) with ${SQL.fruits.id} deleted');
                } else {
                  print("the table is empty");
                }
              },
            ),
            RaisedButton(
              child: Text('Clear table'),
              onPressed: () async {
                final num = await SQL.deleteAll(SQL.fruits.self);
                print(
                    'Table "${SQL.fruits.self}" cleared. $num element(s) deleted');
              },
            ),
            RaisedButton(
              child: Text('Drop database'),
              onPressed: () async {
                await SQL.drop();
                print('All data removed. Cold restart the app to recreate it');
              },
            ),
          ],
        ),
      ),
    );
  }
}
