import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:quotify_utils/quotify_utils.dart';

import '../../repositories/privacy_repository.dart';
import 'privacy_data_errors.dart';

/// Represents public data related to user privacy
@immutable
final class PrivacyData {
  /// Represents public data related to user privacy
  const PrivacyData({
    this.allowErrorReporting = false,
    this.acceptedDataUsage = false,
  });

  /// Flag to indicate wether the user allowed error reporting or not.
  /// Initialized with `false` by default.
  final bool allowErrorReporting;

  /// Store whether the user has accepted data usage terms or not.
  /// It is part of the `PrivacyData` class and is initialized to `false` by
  /// default.
  final bool acceptedDataUsage;

  @override
  int get hashCode => allowErrorReporting.hashCode ^ acceptedDataUsage.hashCode;

  @override
  bool operator ==(covariant PrivacyData other) =>
      allowErrorReporting == other.allowErrorReporting &&
      acceptedDataUsage == other.acceptedDataUsage;

  /// Method to transform [PrivacyData] to a [Map] of [String] and [Object]?
  /// pair.
  Map<String, Object?> toMap() => {
        PrivacyRepository.allowErrorReportingKey: allowErrorReporting,
        PrivacyRepository.acceptedDataUsageKey: acceptedDataUsage,
      };

  /// Returns a [Result] with either [Ok], with a [PrivacyData] object, or a
  /// [Failure] with some of [PrivacyDataErrors] enum members.
  static Result<PrivacyData> fromMap(Map<String, Object?> map) {
    if (map
        case {
          PrivacyRepository.allowErrorReportingKey: final bool
              allowErrorReporting,
          PrivacyRepository.acceptedDataUsageKey: final bool acceptedDataUsage,
        }) {
      return Result.ok(
        PrivacyData(
          acceptedDataUsage: acceptedDataUsage,
          allowErrorReporting: allowErrorReporting,
        ),
      );
    }

    return Result.failure(
      PrivacyDataErrors.invalidMapFormat,
      StackTrace.current,
    );
  }

  /// Encodes the [PrivacyData] with [jsonEncode].
  String toJsonString() => jsonEncode(toMap());

  /// Returns a [Result] with either [Ok], with a [PrivacyData] object, or a
  /// [Failure] with some of [PrivacyDataErrors] enum members.
  static Result<PrivacyData> fromJsonString(String jsonString) {
    if (jsonDecode(jsonString) case final Map<String, Object?> map) {
      return fromMap(map);
    }

    return Result.failure(
      PrivacyDataErrors.invalidJsonStringFormat,
      StackTrace.current,
    );
  }
}
