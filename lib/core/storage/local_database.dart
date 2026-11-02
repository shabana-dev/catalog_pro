import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import '../../models/product_model.dart';

class LocalDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // ONLY initialize FFI for Desktop platforms (Windows, Linux, macOS).
    // Android and iOS handle the factory automatically through the native sqflite plugin.
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        data TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE favourites (
        id INTEGER PRIMARY KEY
      )
    ''');
  }

  Future<void> cacheProducts(List<dynamic> products) async {
    try {
      final db = await database;
      final batch = db.batch();
      for (var product in products) {
        batch.insert(
          'products',
          {'id': product['id'], 'data': jsonEncode(product)},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error caching products: $e');
    }
  }

  Future<void> saveProduct(ProductModel product) async {
    try {
      final db = await database;
      await db.insert(
        'products',
        {'id': product.id, 'data': jsonEncode(product.toJson())},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saving product: $e');
    }
  }

  Future<List<dynamic>> getCachedProducts() async {
    try {
      final db = await database;
      final result = await db.query('products');
      return result.map((e) => jsonDecode(e['data'] as String)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> toggleFavourite(ProductModel product) async {
    try {
      final db = await database;
      final exists = await db.query('favourites', where: 'id = ?', whereArgs: [product.id]);
      if (exists.isNotEmpty) {
        await db.delete('favourites', where: 'id = ?', whereArgs: [product.id]);
      } else {
        await saveProduct(product);
        await db.insert('favourites', {'id': product.id});
      }
    } catch (e) {
      debugPrint('Error toggling favourite: $e');
    }
  }

  Future<List<int>> getFavouriteIds() async {
    try {
      final db = await database;
      final result = await db.query('favourites');
      return result.map((e) => e['id'] as int).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductModel>> getFavouriteProducts() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT p.data FROM products p
        INNER JOIN favourites f ON p.id = f.id
      ''');
      return result.map((e) => ProductModel.fromJson(jsonDecode(e['data'] as String))).toList();
    } catch (e) {
      return [];
    }
  }
}
