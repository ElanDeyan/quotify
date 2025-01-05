import 'package:event/event.dart';
import 'package:quotify_utils/src/reactive.dart';

void main(List<String> args) {
  var a = 0;
  final counter = Counter(0)
    ..eventPublisher.subscribeAll([print, (arg) => a = arg.newValue])
    ..increment()
    ..increment()
    ..increment();

  print('a after all: $a');
}

final class Counter extends Reactive<CounterEvents> {
  Counter(this.value);
  int value;

  void increment() {
    try {
      value++;
    } finally {
      super.eventPublisher.notify(Increment(value));
    }
  }

  void decrement() {
    try {
      value--;
    } finally {
      super.eventPublisher.notify(Decrement(value));
    }
  }
}

sealed class CounterEvents extends EventArgs {
  CounterEvents(this.newValue);

  final int newValue;
}

final class Increment extends CounterEvents {
  Increment(super.newValue);

  @override
  String toString() {
    return 'Increment::NewValue->$newValue';
  }
}

final class Decrement extends CounterEvents {
  Decrement(super.newValue);

  @override
  String toString() {
    return 'Decrement::NewValue->$newValue';
  }
}
