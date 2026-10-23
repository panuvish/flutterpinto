import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveConfig {
  static bool _initialized = false;

  static Future<void> init({
    String? subDir,
    List<TypeAdapter<dynamic>> adapters = const [],
  }) async {
    if (_initialized) return;

    if (subDir == null) {
      await Hive.initFlutter();
    } else {
      await Hive.initFlutter(subDir);
    }

    for (final adapter in adapters) {
      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter(adapter);
      }
    }

    _initialized = true;
  }

  static Future<Box<T>> openBox<T>(
    String name, {
    HiveCipher? cipher,
  }) async {
    return Hive.openBox<T>(name, encryptionCipher: cipher);
  }

  static Future<LazyBox<T>> openLazyBox<T>(
    String name, {
    HiveCipher? cipher,
  }) async {
    return Hive.openLazyBox<T>(name, encryptionCipher: cipher);
  }

  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}
