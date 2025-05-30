import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DBService {

  const DBService._();

  static late final SharedPreferences _cache;

  static Future<void> init({
    required SharedPreferences cache
  }) async {
    DBService._cache = cache;
  }


  static Future<void> set(String key, dynamic value) async {

    try {

      if (value is String) {
        await DBService._cache.setString(key, value);
      } else if (value is int) {
        await DBService._cache.setInt(key, value);
      }
      else if (value is double) {
        await DBService._cache.setDouble(key, value);
      }
      else if (value is bool) {
        await DBService._cache.setBool(key, value);
      }
      else if (value is List<String>) {
        await DBService._cache.setStringList(key, value);
      }
      else if (value is Map<String, dynamic>) {
        await DBService._cache.setString(key, jsonEncode(value));
      }

    }
    catch (_) {
      throw Exception('DBService: set: error');
    }

  }


  static Future<dynamic> get(String key, { bool encrypted = false }) async {

    try {
      return DBService._cache.get(key);
    }
    catch (__, s) {
      debugPrint('DBService: get: error $__ $s');
      return null;
    }

  }

  static dynamic getNoFuture(String key) {
    try {
      return DBService._cache.get(key);
    } catch (__, s) {
      debugPrint('DBService: get: error $__ $s');
      return null;
    }
  }


  static Future<void> remove(String key, { bool encrypted = false }) async {
    try {
      await DBService._cache.remove(key);
    }
    catch (_) {
      throw Exception('DBService: remove: error');
    }
  }


  static Future<void> clear() async {

    try {
      await _cache.clear();
    }
    catch (_) {
      throw Exception('DBService: clear: error');
    }

  }

}
