import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void saveString(String name, String value) async {
    _prefs.setString(name, value);
  }

  void saveInt(String name, int value) async {
    _prefs.setInt(name, value);
  }

  void saveDouble(String name, double value) async {
    _prefs.setDouble(name, value);
  }

  static String? readString(String key) {
    return _prefs.getString(key);
  }

  static int? readInt(String key) {
    return _prefs.getInt(key);
  }

  static double? readDouble(String key) {
    return _prefs.getDouble(key);
  }

  void clearData() async {
    await _prefs.clear();
  }

  static bool? checkData(String key) {
    return _prefs.containsKey(key);
  }
}
