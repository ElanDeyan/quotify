import 'package:flutter/foundation.dart';

final class Notifier extends ChangeNotifier {
  Notifier();

  @override
  void notifyListeners() => super.notifyListeners();
}

final notifier = Notifier();
