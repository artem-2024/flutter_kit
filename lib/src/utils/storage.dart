import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class StorageUtils {
  StorageUtils._();

  /// 获取SharedPreferences对象
  static Future<SharedPreferences> get _getInstance async => await SharedPreferences.getInstance();

  /// 删除某个key
  static Future<bool> remove(String key) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.remove(key);
  }

  /// 获取缓存中某个key
  static Future<dynamic> get(String key) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.get(key);
  }

  /// 获取缓存int值
  static Future<int?> getInt(String key) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.getInt(key);
  }

  /// 获取缓存bool值
  static Future<bool?> getBool(String key) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.getBool(key);
  }

  /// 获取字符串值
  static Future<String?> getString(String key) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.getString(key);
  }

  /// 获取字符串list
  static Future<List<String>?> getStringList(String key) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.getStringList(key);
  }

  /// 设置int值
  static Future<bool> setInt(String key, int value) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.setInt(key, value);
  }

  /// 设置int值
  static Future<bool> setBool(String key, bool value) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.setBool(key, value);
  }

  /// 设置string值
  static Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.setString(key, value);
  }

  /// 设置string集合
  static Future<bool> setStringList(String key, List<String> value) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.setStringList(key, value);
  }

  /// 检查是否含有key
  static Future<bool> containsKey(String key) async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.containsKey(key);
  }

  /// 清空
  static Future<bool> get clear async {
    final SharedPreferences prefs = await _getInstance;
    return prefs.clear();
  }
}
