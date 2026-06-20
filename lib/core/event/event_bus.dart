import 'package:flutter/material.dart';

enum EventType {
  fileOpened,
  fileSaved,
  fileClosed,
  documentChanged,
  selectionChanged,
  themeChanged,
  commandExecuted,
  toolExecuted,
}

class AppEvent {
  final EventType type;
  final dynamic data;
  final DateTime timestamp;

  AppEvent({
    required this.type,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

typedef EventListener = void Function(AppEvent event);

class EventBus {
  static final EventBus _instance = EventBus._();
  factory EventBus() => _instance;
  EventBus._();

  final Map<EventType, List<EventListener>> _listeners = {};
  final List<AppEvent> _eventHistory = [];

  void subscribe(EventType type, EventListener listener) {
    _listeners[type] ??= [];
    _listeners[type]!.add(listener);
  }

  void unsubscribe(EventType type, EventListener listener) {
    _listeners[type]?.remove(listener);
  }

  void publish(AppEvent event) {
    _eventHistory.add(event);
    if (_eventHistory.length > 100) {
      _eventHistory.removeAt(0);
    }

    final listeners = _listeners[event.type];
    if (listeners != null) {
      for (final listener in listeners) {
        try {
          listener(event);
        } catch (e) {
          debugPrint('Event listener error: $e');
        }
      }
    }
  }

  void emit(EventType type, {dynamic data}) {
    publish(AppEvent(type: type, data: data));
  }

  List<AppEvent> getEventHistory() {
    return List.unmodifiable(_eventHistory);
  }

  List<AppEvent> getEventsByType(EventType type) {
    return _eventHistory.where((e) => e.type == type).toList();
  }

  void clearHistory() {
    _eventHistory.clear();
  }
}
