import 'package:quotify_utils/quotify_utils.dart';

import '../../languages/logic/models/languages.dart';
import '../logic/models/data_usage_info.dart';

abstract interface class DataUsageInfoRepository {
  FutureResult<DataUsageInfo> dataUsageInfoFrom(Languages language);
}
