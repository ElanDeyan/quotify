import 'package:languages_repository/repositories/languages_repository.dart';
import 'package:primary_colors_repository/repositories/primary_colors_repository.dart';
import 'package:privacy_repository/repositories/privacy_repository.dart';
import 'package:quotes_repository/repositories/quotes_repository.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:quotify_utils/result.dart';
import 'package:tags_repository/repositories/tag_repository.dart';
import 'package:theme_brightness_repository/repository/theme_brightness_repository.dart';

import '../../backup_logic.dart';
import '../models/conflict_resolver.dart';
import '../models/data_source_to_keep.dart';

final class RestoreBackup
    implements UseCase<FutureResult<Unit, BackupUseCasesErrors>> {
  const RestoreBackup({
    required final Backup backup,
    required final QuotesRepository quotesRepository,
    required final TagRepository tagRepository,
    required final LanguagesRepository languagesRepository,
    required final PrimaryColorsRepository primaryColorsRepository,
    required final PrivacyRepository privacyRepository,
    required final ThemeBrightnessRepository themeBrightnessRepository,
    required final DataSourceToUse themeBrightnessDataSourceToUse,
    required final DataSourceToUse primaryColorDataSourceToUse,
    required final DataSourceToUse languageDataSourceToUse,
    required final DataSourceToUse privacyDataDataSourceToUse,
    required final ConflictResolver tagsConflictResolver,
    required final ConflictResolver quotesConflictResolver,
  }) : _backup = backup,
       _quotesRepository = quotesRepository,
       _tagRepository = tagRepository,
       _languagesRepository = languagesRepository,
       _primaryColorsRepository = primaryColorsRepository,
       _privacyRepository = privacyRepository,
       _themeBrightnessRepository = themeBrightnessRepository,
       _themeBrightnessDataSourceToUse = themeBrightnessDataSourceToUse,
       _primaryColorDataSourceToUse = primaryColorDataSourceToUse,
       _languageDataSourceToUse = languageDataSourceToUse,
       _privacyDataDataSourceToUse = privacyDataDataSourceToUse,
       _tagsConflictResolver = tagsConflictResolver,
       _quotesConflictResolver = quotesConflictResolver;

  final Backup _backup;

  final QuotesRepository _quotesRepository;

  final TagRepository _tagRepository;

  final LanguagesRepository _languagesRepository;

  final PrimaryColorsRepository _primaryColorsRepository;

  final PrivacyRepository _privacyRepository;

  final ThemeBrightnessRepository _themeBrightnessRepository;

  final DataSourceToUse _themeBrightnessDataSourceToUse;

  final DataSourceToUse _primaryColorDataSourceToUse;

  final DataSourceToUse _languageDataSourceToUse;

  final DataSourceToUse _privacyDataDataSourceToUse;

  final ConflictResolver _tagsConflictResolver;

  final ConflictResolver _quotesConflictResolver;

  @override
  FutureResult<Unit, BackupUseCasesErrors> call() {
    // TODO: implement call
    throw UnimplementedError();
  }
}
