import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();
  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;
    _database = await initDB();
    return _database;
  }


  initDB() async {
    WidgetsFlutterBinding.ensureInitialized();

    return await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'hot_wheels_collection.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE car(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, barcode TEXT, create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> insertCar(Car car) async {
    final db = await database;
    await db.insert(
      'car',
      car.toMap()
    );
  }

  Future<Car> getCarByBarcode(String barcode) async {
    final db = await database;
    List<Map> result = await db.query("car", where: "barcode = ?", whereArgs: [barcode]);
    print(result.isNotEmpty);
    if(result.isNotEmpty == false){
      return null;
    }else{
      return Car.fromMap(result.first);
    }
  }

  Future<List<Car>> listCars() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('car');
    return List.generate(maps.length, (i) {
      Car tmp = new Car();
      tmp.id = maps[i]["id"];
      tmp.name = maps[i]["name"];
      tmp.barcode = maps[i]["barcode"];
      tmp.create_time = maps[i]["create_time"];
      return tmp;
    });
  }
}

class Car {
  int id;
  String name;
  String barcode;
  DateTime create_time;
  static final columns = ["id", "name", "barcode", "create_time"];
  //Car(this.id, this.name, this.barcode, this.create_time);
  //Car(this.id, this.name, this.barcode, this.create_time);
  Car();



  factory Car.fromMap(Map<String, dynamic> data) {
    Car currentCar = new Car();
    currentCar.id = data["id"];
    currentCar.name = data["name"];
    currentCar.barcode = data["barcode"];
    currentCar.create_time = data["create_time"];
    return currentCar;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'create_time': create_time
    };
  }


}