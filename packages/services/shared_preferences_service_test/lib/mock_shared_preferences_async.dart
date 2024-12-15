import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This mock class can be used in testing to simulate the behavior of the
/// [SharedPreferencesAsync] class without actually interacting with the
/// real implementation.
final class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}
