import 'package:languages_repository/models/languages.dart';
import 'package:quotify_utils/quotify_utils.dart';

import '../logic/models/data_usage_info.dart';

abstract interface class DataUsageInfoRepository {
  FutureResult<DataUsageInfo> dataUsageInfoFrom(Languages language);
}
