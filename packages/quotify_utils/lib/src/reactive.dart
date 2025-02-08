import 'dart:async';

import 'package:event/event.dart';

/// An abstract base class that represents a reactive entity which can publish
/// events of type [T].
///
/// [T] is a type that extends [EventArgs].
abstract base class Reactive<T extends EventArgs> {
  /// The event publisher responsible for publishing events of type [T].
  final EventPublisher<T> eventPublisher = EventPublisher<T>(Event());
}

/// An extension type that provides additional functionality for an [Event].
///
/// This extension type allows you to publish events, subscribe to event
/// notifications, and manage event handlers.
///
/// Example usage:
/// ```dart
/// final event = Event<MyEventArgs>();
/// final publisher = EventPublisher(event);
///
/// // Subscribe to the event
/// publisher.subscribe((args) {
///   print('Event received: ${args.someProperty}');
/// });
///
/// // Notify subscribers
/// publisher.notify(MyEventArgs(someProperty: 'value'));
/// ```
///
/// Type Parameters:
/// - `T`: The type of event arguments, which must extend [EventArgs].
extension type EventPublisher<T extends EventArgs>(Event<T> _event)
    implements Event<T> {
  /// Notifies all subscribers with the given event.
  ///
  /// Returns `true` if the notification was successful, `false` otherwise.
  ///
  /// Parameters:
  /// - `event`: The event arguments to notify subscribers with.
  bool notify(T event) => _event.notifySubscribers(event);

  /// Subscribes a handler to the event.
  ///
  /// The handler will be called whenever the event is notified.
  ///
  /// Parameters:
  /// - `handler`: A function that takes the event arguments as a parameter.
  void subscribe(void Function(T argument) handler) =>
      _event.subscribe(handler);

  /// Subscribes a [StreamSink] to the event.
  ///
  /// The [StreamSink] will receive the event arguments whenever the event
  /// is notified.
  ///
  /// Parameters:
  /// - `streamSink`: A [StreamSink] to receive the event arguments.
  void subscribeStreams(StreamSink<T> streamSink) =>
      _event.subscribeStream(streamSink);

  /// Subscribes multiple handlers to the event.
  ///
  /// Each handler in the list will be called whenever the event is notified.
  ///
  /// Parameters:
  /// - `handlers`: A list of functions that take the event arguments as a
  /// parameter.
  void subscribeAll(List<void Function(T argument)> handlers) =>
      handlers.forEach(subscribe);

  /// Unsubscribes a handler from the event.
  ///
  /// The handler will no longer be called when the event is notified.
  ///
  /// Parameters:
  /// - `handler`: A function that takes the event arguments as a parameter.
  void unsubscribe(void Function(T argument) handler) =>
      _event.unsubscribe(handler);

  /// Unsubscribes all handlers from the event.
  ///
  /// No handlers will be called when the event is notified.
  void unsubscribeAll() => _event.unsubscribeAll();
}
