import 'package:faker/faker.dart';
import 'package:quotify_utils/quotify_utils.dart';
import 'package:tags_repository/logic/models/tag.dart';

Tag sampleTagGenerator() => Tag(
  id: Id(Natural(faker.randomGenerator.integer(50))),
  label: NonBlankString(faker.lorem.word()),
);
