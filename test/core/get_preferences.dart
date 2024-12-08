import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_shared_preferences_async.dart';

(SharedPreferencesAsync preferences, FakeSharedPreferencesAsync store)
    getPreferences() {
  final store = FakeSharedPreferencesAsync();
  SharedPreferencesAsyncPlatform.instance = store;
  final preferences = SharedPreferencesAsync();
  return (preferences, store);
}
