import 'package:backup_logic/backup_logic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/repository_mocks.dart';
import 'utils/sample_backup_generator.dart';

void main() {
  late MockQuotesRepository quotesRepository;
  late MockTagRepository tagRepository;
  late MockLanguagesRepository languagesRepository;
  late MockPrimaryColorsRepository primaryColorsRepository;
  late MockPrivacyRepository privacyRepository;
  late MockThemeBrightnessRepository themeBrightnessRepository;
  late Backup sampleBackup;

  setUp(() {
    themeBrightnessRepository = MockThemeBrightnessRepository();
    primaryColorsRepository = MockPrimaryColorsRepository();
    languagesRepository = MockLanguagesRepository();
    privacyRepository = MockPrivacyRepository();
    tagRepository = MockTagRepository();
    quotesRepository = MockQuotesRepository();
    sampleBackup = sampleBackupGenerator();
  });

  group('theme brightness', () {});
}
