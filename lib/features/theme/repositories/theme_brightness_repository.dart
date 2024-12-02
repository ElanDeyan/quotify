import '../../../utils/future_result.dart';
import '../logic/models/theme_brightness.dart';

abstract interface class ThemeBrightnessRepository {
  FutureResult<ThemeBrightness> fetchThemeBrightness();

  Future<bool> saveThemeBrightness(ThemeBrightness themeBrightness);
}
