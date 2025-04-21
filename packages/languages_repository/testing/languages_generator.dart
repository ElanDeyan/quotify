import 'package:glados/glados.dart';
import 'package:languages_repository/models/languages.dart';

extension AnyLanguage on Any {
  Generator<Languages> get languages => choose(Languages.values);
}
