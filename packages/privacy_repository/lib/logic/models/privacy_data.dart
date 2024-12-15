/// Represents public data related to user privacy
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
}
