enum QuoteErrors implements Exception {
  invalidMapRepresentation,
  invalidJsonString,

  updatedAtDateBeforeCreatedAt,

  invalidSourceUri,
}
