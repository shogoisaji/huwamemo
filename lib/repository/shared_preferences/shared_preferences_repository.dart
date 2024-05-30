import 'package:huwamemo/repository/shared_preferences/shared_preferences_key.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_repository.g.dart';

@Riverpod(keepAlive: true)
SharedPreferencesRepository sharedPreferencesRepository(
  SharedPreferencesRepositoryRef ref,
) {
  throw UnimplementedError();
}

class SharedPreferencesRepository {
  SharedPreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<bool> save<T>(SharedPreferencesKey key, T value) async {
    if (value is bool) {
      return _prefs.setBool(key.value, value);
    }
    if (value is String) {
      return _prefs.setString(key.value, value);
    }
    throw UnsupportedError('Not support \'$value\'');
  }

  T? fetch<T>(
    SharedPreferencesKey key,
  ) {
    if (T == bool) {
      return _prefs.getBool(key.value) as T?;
    }
    if (T == String) {
      return _prefs.getString(key.value) as T?;
    }
    throw UnsupportedError('Not support \'$T\'');
  }

  Future<bool> remove(SharedPreferencesKey key) => _prefs.remove(key.value);
}
