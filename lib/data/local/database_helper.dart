import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
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
    // ================= PRODUCTS =================
    await db.execute('''
      CREATE TABLE products (
        p_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        stock_qty INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ================= ORDERS =================
    await db.execute('''
      CREATE TABLE orders (
        o_id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        total_amount REAL NOT NULL,
        order_date TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ================= ORDER ITEMS =================
    await db.execute('''
      CREATE TABLE order_items (
        item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        qty_sold INTEGER NOT NULL,
        price_at_sale REAL NOT NULL,
      )
    ''');
  }

  // =========================================================
  // PRODUCT METHODS
  // =========================================================

  Future<int> insertProduct(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('products', row);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query('products', orderBy: 'p_id DESC');
  }

  Future<int> updateProduct(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'products',
      row,
      where: 'p_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'p_id = ?',
      whereArgs: [id],
    );
  }

  // =========================================================
  // ORDER METHODS
  // =========================================================

  Future<int> insertOrder(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('orders', row);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await instance.database;
    return await db.query('orders', orderBy: 'o_id DESC');
  }

  Future<int> updateOrder(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'orders',
      row,
      where: 'o_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await instance.database;
    return await db.delete(
      'orders',
      where: 'o_id = ?',
      whereArgs: [id],
    );
  }

  // =========================================================
  // ORDER ITEMS METHODS
  // =========================================================

  Future<int> insertOrderItem(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('order_items', row);
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final db = await instance.database;
    return await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> updateOrderItem(int itemId, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'order_items',
      row,
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
  }

  Future<int> deleteOrderItem(int itemId) async {
    final db = await instance.database;
    return await db.delete(
      'order_items',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
  }
}