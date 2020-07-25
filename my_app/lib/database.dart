import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

	static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
	static Database _database;                // Singleton Database

	String OneFoodTable = 'OneFood_table';
	String colId = 'id';
	String colTitle = 'title';
	String colDescription = 'description';
	String colDate = 'date';

	DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

	factory DatabaseHelper() {

		if (_databaseHelper == null) {
			_databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
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
		String path = directory.path + 'OneFoods.db';

		// Open/create the database at a given path
		var OneFoodsDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
		return OneFoodsDatabase;
	}

	void _createDb(Database db, int newVersion) async {

		await db.execute('CREATE TABLE $OneFoodTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
				'$colDescription TEXT, $colDate TEXT)');
	}

	// Fetch Operation: Get all OneFood objects from database
	Future<List<Map<String, dynamic>>> getOneFoodMapList() async {
		Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $OneFoodTable order by $colTitle ASC');
		var result = await db.query(OneFoodTable, orderBy: '$colTitle ASC');
		return result;
	}

	// Insert Operation: Insert a OneFood object to database
	Future<int> insertOneFood(OneFood OneFood) async {
		Database db = await this.database;
		var result = await db.insert(OneFoodTable, OneFood.toMap());
		return result;
	}

	// // Update Operation: Update a OneFood object and save it to database
	// Future<int> updateOneFood(OneFood OneFood) async {
	// 	var db = await this.database;
	// 	var result = await db.update(OneFoodTable, OneFood.toMap(), where: '$colId = ?', whereArgs: [OneFood.id]);
	// 	return result;
	// }


	// // Delete Operation: Delete a OneFood object from database
	// Future<int> deleteOneFood(int id) async {
	// 	var db = await this.database;
	// 	int result = await db.rawDelete('DELETE FROM $OneFoodTable WHERE $colId = $id');
	// 	return result;
	// }

	// // Get number of OneFood objects in database
	// Future<int> getCount() async {
	// 	Database db = await this.database;
	// 	List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $OneFoodTable');
	// 	int result = Sqflite.firstIntValue(x);
	// 	return result;
	// }

	// Get the 'Map List' [ List<Map> ] and convert it to 'OneFood List' [ List<OneFood> ]
	Future<List<OneFood>> getOneFoodList() async {

		var OneFoodMapList = await getOneFoodMapList(); // Get 'Map List' from database
		int count = OneFoodMapList.length;         // Count the number of map entries in db table

		List<OneFood> OneFoodList = List<OneFood>();
		// For loop to create a 'OneFood List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			OneFoodList.add(OneFood.fromMapObject(OneFoodMapList[i]));
		}

		return OneFoodList;
	}

}
var dbinit() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  return openDatabase(
    join(await getDatabasesPath(), 'database.db'),
    onCreate: (db, version) {
      var a = db.execute(
        "CREATE TABLE food(id INTEGER PRIMARY KEY, label TEXT, calories INTEGER,time INTEGER)",
      );
      insertFood(OneFood(
        label: 'start',
        calories: 0,
        works: true,
      ));
      return a;
    },
    version: 1,
  );
}
var database;
Future<void> insertFood(OneFood food) async {
  // Get a reference to the database.
  final Database db = await database;

  // Insert the Dog into the correct table. Also specify the
  // `conflictAlgorithm`. In this case, if the same dog is inserted
  // multiple times, it replaces the previous data.
  await db.insert(
    'food',
    food.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<OneFood>> foods() async {
  // Get a reference to the database.
  final Database db = await database;

  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps = await db.query('food');

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return OneFood(
      time: maps[i]['time'],
      label: maps[i]['label'],
      calories: maps[i]['calories'],
      works: true,
    );
  });

  // Future<void> updateDog(Dog dog) async {
  //   // Get a reference to the database.
  //   final db = await database;

  //   // Update the given Dog.
  //   await db.update(
  //     'dogs',
  //     dog.toMap(),
  //     // Ensure that the Dog has a matching id.
  //     where: "id = ?",
  //     // Pass the Dog's id as a whereArg to prevent SQL injection.
  //     whereArgs: [dog.id],
  //   );
  // }

  // Future<void> deleteFood(int id) async {
  //   // Get a reference to the database.
  //   final db = await database;

  //   // Remove the Dog from the database.
  //   await db.delete(
  //     'dogs',
  //     // Use a `where` clause to delete a specific dog.
  //     where: "id = ?",
  //     // Pass the Dog's id as a whereArg to prevent SQL injection.
  //     whereArgs: [id],
  //   );
  // }

  // var fido = Dog(
  //   id: 0,
  //   name: 'Fido',
  //   age: 35,
  // );

  // // Insert a dog into the database.
  // await insertDog(fido);

  // // Print the list of dogs (only Fido for now).
  // print(await dogs());

  // // Update Fido's age and save it to the database.
  // fido = Dog(
  //   id: fido.id,
  //   name: fido.name,
  //   age: fido.age + 7,
  // );
  // await updateDog(fido);

  // // Print Fido's updated information.
  // print(await dogs());

  // // Delete Fido from the database.
  // await deleteDog(fido.id);

  // // Print the list of dogs (empty).
  // print(await dogs());
}

class OneFood {
  final String label;
  final double calories;
  final bool works;
  var time = new DateTime.now();
//OneFood FIGURE OUT IF THIS DEFAULT PARAMETER THING BREAKS
  OneFood({this.label, this.calories, this.works, this.time});

  factory OneFood.fromJson(Map<String, dynamic> json, bool found) {
    if (found) {
      return OneFood(
        label: json['hints'][0]['food']['label'],
        calories: json['hints'][0]['food']['nutrients']['ENERC_KCAL'],
        works: found,
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
      'id': time,
      'label': label,
      'calories': calories,
      'time': time,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Food{time: $time, name: $label, calories: $calories}';
  }
}
