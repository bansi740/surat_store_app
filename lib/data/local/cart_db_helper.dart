import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CartDbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, 'cart.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart(
            userId TEXT,
            pId TEXT,
            name TEXT,
            price REAL,
            imagePath TEXT,
            stockQty INTEGER,
            qty INTEGER,
            PRIMARY KEY (userId, pId)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS cart');
          await db.execute('''
            CREATE TABLE cart(
              userId TEXT,
              pId TEXT,
              name TEXT,
              price REAL,
              imagePath TEXT,
              stockQty INTEGER,
              qty INTEGER,
              PRIMARY KEY (userId, pId)
            )
          ''');
        }
      },
    );
  }

  static Future<void> insertOrUpdateCartItem(
      Map<String, dynamic> data,
      String userId,
      ) async {
    final db = await database;

    data['userId'] = userId;

    await db.insert(
      'cart',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final db = await database;

    return await db.query(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  static Future<void> deleteCartItem(String userId, String pId) async {
    final db = await database;

    await db.delete(
      'cart',
      where: 'userId = ? AND pId = ?',
      whereArgs: [userId, pId],
    );
  }

  static Future<void> clearCart(String userId) async {
    final db = await database;

    await db.delete(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}