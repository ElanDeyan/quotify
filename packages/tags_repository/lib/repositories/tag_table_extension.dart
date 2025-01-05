import 'package:drift_database_service/drift_database_service.dart';
import 'package:quotify_utils/quotify_utils.dart';

import '../logic/models/tag.dart';

extension TagTableExtension on TagTable {
  Tag toTag() => Tag(id: Id(Natural(id)), label: NonBlankString(label));
}
