import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String oneFoodTable = 'OneFood_table2';
  String colId = 'time';
  String colLabel = 'label';
  String colCalories = 'calories';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'OneFoods4.db';

    // Open/create the database at a given path
    var oneFoodsDatabase =
        await openDatabase(path, version: 2, onCreate: _createDb);
    return oneFoodsDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $oneFoodTable($colId INTEGER PRIMARY KEY, $colLabel TEXT, $colCalories DOUBLE)");
  }

  // Fetch Operation: Get all OneFood objects from database
  Future<List<Map<String, dynamic>>> getOneFoodMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $OneFoodTable order by $colTitle ASC');
    var result = await db.query(oneFoodTable, orderBy: '$colId DESC');
    return result;
  }

  // Insert Operation: Insert a OneFood object to database
  Future<int> insertOneFood(OneFood oneFood) async {
    Database db = await this.database;

    var result = await db.insert(oneFoodTable, oneFood.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  // // Update Operation: Update a OneFood object and save it to database
  // Future<int> updateOneFood(OneFood OneFood) async {
  // 	var db = await this.database;
  // 	var result = await db.update(OneFoodTable, OneFood.toMap(), where: '$colId = ?', whereArgs: [OneFood.time]);
  // 	return result;
  // }

  // Delete Operation: Delete a OneFood object from database
  Future<int> deleteOneFood(int time) async {
    print('del ' + time.toString());
    var db = await this.database;
    int result =
        await db.delete(oneFoodTable, where: "$colId = ?", whereArgs: [time]);
    print(result);
    return result;
  }

  // Get number of OneFood objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $oneFoodTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'OneFood List' [ List<OneFood> ]
  Future<List<OneFood>> getOneFoodList() async {
    var oneFoodMapList =
        await getOneFoodMapList(); // Get 'Map List' from database
    int count =
        oneFoodMapList.length; // Count the number of map entries in db table

    List<OneFood> oneFoodList = List<OneFood>();
    // For loop to create a 'OneFood List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      oneFoodList.add(OneFood.fromMapObject(oneFoodMapList[i]));
    }

    return oneFoodList;
  }
}

class OneFood {
  final String label;
  double calories;
  final bool works;
  int time;
  var servingQty;
  final String servingUnit;
  int servingConsumed = 1;
//OneFood FIGURE OUT IF THIS DEFAULT PARAMETER THING BREAKS
  OneFood({
    this.label,
    this.calories,
    this.works,
    this.time,
    this.servingQty,
    this.servingUnit,
  }) {
    this.time ??= DateTime.now().millisecondsSinceEpoch;
  }

  factory OneFood.fromJson(Map<String, dynamic> json, bool found) {
    if (found) {
      return OneFood(
        label: json['foods'][0]['brand_name'] +
            ' ' +
            json['foods'][0]['food_name'],
        calories: double.parse(json['foods'][0]['nf_calories'].toString()),
        works: found,
        servingQty: json['foods'][0]['serving_qty'],
        servingUnit: json['foods'][0]['serving_unit'],
      );
    } else {
      return OneFood(
        label: 'no',
        calories: 0.0,
        works: found,
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'label': label,
      'calories': calories*servingConsumed,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Food{time: $time, name: $label, calories: $calories}';
  }

  factory OneFood.fromMapObject(Map<String, dynamic> map) {
    return OneFood(
      label: map['label'],
      calories: map['calories'],
      time: map['time'],
      works: true,
    );
  }
}
