enum Languages {
  brazilianPortuguese(languageCode: 'pt-BR'),
  english(languageCode: 'en');

  const Languages({required this.languageCode});

  final String languageCode;
}
