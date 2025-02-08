import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:quotify_utils/result.dart';
import 'package:quotify_utils/serialization/interfaces/encodable.dart';

import '../../repositories/privacy_data_entry.dart';
import '../../repositories/privacy_repository.dart';
import 'privacy_data_model_errors.dart';

/// Represents public data related to user privacy
@immutable
final class PrivacyData implements Encodable {
  /// Represents public data related to user privacy
  const PrivacyData({
    this.allowErrorReporting = false,
    this.acceptedDataUsage = false,
  });

  /// Creates an instance from [PrivacyDataEntry].
  factory PrivacyData.fromPrivacyDataEntry(PrivacyDataEntry entry) =>
      PrivacyData(
        acceptedDataUsage: entry.acceptedDataUsage ?? false,
        allowErrorReporting: entry.allowErrorReporting ?? false,
      );

  /// Creates an instance with default values.
  const factory PrivacyData.initial() = PrivacyData;

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
  @override
  Map<String, Object?> toMap() => {
        PrivacyRepository.allowErrorReportingKey: allowErrorReporting,
        PrivacyRepository.acceptedDataUsageKey: acceptedDataUsage,
      };

  /// Returns a [Result] with either [Ok], with a [PrivacyData] object, or a
  /// [Failure] with some of [PrivacyDataModelErrors] enum members.
  static Result<PrivacyData, PrivacyDataModelErrors> fromMap(
    Map<String, Object?> map,
  ) {
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
      PrivacyDataModelErrors.invalidMapFormat,
      StackTrace.current,
    );
  }

  /// Encodes the [PrivacyData] with [jsonEncode].
  @override
  String toJsonString() => jsonEncode(toMap());

  /// Returns a [Result] with either [Ok], with a [PrivacyData] object, or a
  /// [Failure] with some of [PrivacyDataModelErrors] enum members.
  static Result<PrivacyData, PrivacyDataModelErrors> fromJsonString(
    String jsonString,
  ) {
    late final Object? decodedJsonString;

    try {
      decodedJsonString = jsonDecode(jsonString);
    } on FormatException catch (error, stackTrace) {
      return Result.failure(
        PrivacyDataModelErrors.invalidJsonStringFormat,
        stackTrace,
      );
    }

    if (decodedJsonString case final Map<String, Object?> map) {
      return fromMap(map);
    }

    return Result.failure(
      PrivacyDataModelErrors.invalidJsonStringFormat,
      StackTrace.current,
    );
  }

  /// Helper to convert to [PrivacyDataEntry].
  PrivacyDataEntry toPrivacyDataEntry() => PrivacyDataEntry(
        allowErrorReporting: allowErrorReporting,
        acceptedDataUsage: acceptedDataUsage,
      );
}
