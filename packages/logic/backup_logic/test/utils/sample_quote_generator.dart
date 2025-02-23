import 'package:faker/faker.dart';
import 'package:quotes_repository/logic/models/quote.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'sample_tag_generator.dart';

Quote sampleQuoteGenerator({
  bool containsSource = false,
  bool containsSourceUri = false,
  Natural howManyTags = const Natural(0),
}) => Quote(
  id: Id(Natural(faker.randomGenerator.integer(50))),
  content: NonBlankString(faker.lorem.sentence()),
  author: NonBlankString(faker.person.name()),
  isFavorite: faker.randomGenerator.boolean(),
  source: containsSource ? faker.lorem.word() : null,
  sourceUri: containsSourceUri ? Uri.parse(faker.internet.httpsUrl()) : null,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now().add(const Duration(minutes: 5)),
  tags: {for (var i = 0; i < howManyTags.toInt(); i++) sampleTagGenerator()},
);
