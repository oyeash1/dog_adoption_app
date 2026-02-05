import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common/sqlite_api.dart';

class Dog {
  int? id;
  String name;
  String breed;
  int age;
  String description;
  String? imageBase64; // Changed from imageUrl to imageBase64
  bool isAdopted;

  Dog({
    this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.description,
    this.imageBase64,
    this.isAdopted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'description': description,
      'imageBase64': imageBase64,
      'isAdopted': isAdopted ? 1 : 0,
    };
  }

  static Dog fromMap(Map<String, dynamic> map) {
    return Dog(
      id: map['id'],
      name: map['name'],
      breed: map['breed'],
      age: map['age'],
      description: map['description'],
      imageBase64: map['imageBase64'],
      isAdopted: map['isAdopted'] == 1,
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final factory = databaseFactoryFfiWeb;
    
    return await factory.openDatabase(
      'dog_adoption.db',
      options: OpenDatabaseOptions(
        version: 2, // Increment version for schema change
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dogs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        breed TEXT NOT NULL,
        age INTEGER NOT NULL,
        description TEXT NOT NULL,
        imageBase64 TEXT,
        isAdopted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await _insertSampleData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add imageBase64 column and remove imageUrl if upgrading from version 1
      await db.execute('ALTER TABLE dogs ADD COLUMN imageBase64 TEXT');
    }
  }

  Future<void> _insertSampleData(Database db) async {
    final sampleDogs = [
      {
        'name': 'Buddy',
        'breed': 'Golden Retriever',
        'age': 3,
        'description': 'Friendly and energetic dog, great with kids',
        'imageBase64': null,
        'isAdopted': 0,
      },
      {
        'name': 'Luna',
        'breed': 'Border Collie',
        'age': 2,
        'description': 'Intelligent and active, loves to play fetch',
        'imageBase64': null,
        'isAdopted': 0,
      },
      {
        'name': 'Max',
        'breed': 'German Shepherd',
        'age': 4,
        'description': 'Loyal and protective, well-trained',
        'imageBase64': null,
        'isAdopted': 1,
      },
    ];

    for (var dog in sampleDogs) {
      await db.insert('dogs', dog);
    }
  }

  // CRUD Operations
  Future<int> insertDog(Dog dog) async {
    final db = await database;
    return await db.insert('dogs', dog.toMap());
  }

  Future<List<Dog>> getAllDogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dogs');
    return List.generate(maps.length, (i) => Dog.fromMap(maps[i]));
  }

  Future<Dog?> getDog(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dogs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Dog.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDog(Dog dog) async {
    final db = await database;
    return await db.update(
      'dogs',
      dog.toMap(),
      where: 'id = ?',
      whereArgs: [dog.id],
    );
  }

  Future<int> deleteDog(int id) async {
    final db = await database;
    return await db.delete(
      'dogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Dog>> getAvailableDogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dogs',
      where: 'isAdopted = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => Dog.fromMap(maps[i]));
  }
}
