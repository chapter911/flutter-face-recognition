import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DataBaseHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute(
        """CREATE TABLE employee (sap_id TEXT PRIMARY KEY, name TEXT, photoEmbedding TEXT)""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'face_recognition.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<void> deleteWhere(String table, String where, int val) async {
    final db = await DataBaseHelper.db();
    try {
      await db.delete(table, where: where, whereArgs: [val]);
    } catch (e) {
      Get.snackbar("Sorry", "Failed to Delete Data");
    }
  }

  static Future<void> deleteAll(String table) async {
    final db = await DataBaseHelper.db();
    Get.snackbar("Sorry", "All Data Deleted");
    try {
      await db.delete(table);
    } catch (e) {
      Get.snackbar("Sorry", "Failed to Delete Data");
    }
  }

  static Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await DataBaseHelper.db();
    return db.query(table);
  }

  static Future<List<Map<String, dynamic>>> getWhere(
      String table, String where) async {
    final db = await DataBaseHelper.db();
    return db.query(table, where: where);
  }

  static Future<int> insert(String table, var content) async {
    final db = await DataBaseHelper.db();
    final data = content;
    final id = await db.insert(table, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> update(
      String table, var content, String where, int val) async {
    final db = await DataBaseHelper.db();
    final data = content;
    final result = await db.update(table, data, where: where, whereArgs: [val]);
    return result;
  }

  static Future<List<Map<String, dynamic>>> customQuery(String query) async {
    final db = await DataBaseHelper.db();
    return db.rawQuery(query);
  }
}
