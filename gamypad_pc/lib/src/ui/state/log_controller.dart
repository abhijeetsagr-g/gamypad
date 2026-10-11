import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_pc/src/ui/state/providers.dart';
import 'package:protocol/protocol.dart';

/// [motion] is opt-in: raw sensor samples arrive ~50 times a second, so they
/// are only recorded while it is the selected filter, and never appear under
/// [all].
enum LogFilter { all, buttons, stick, trigger, motion }

class LogEntry {
  final DateTime time;
  final Message message;

  LogEntry({required this.time, required this.message});
}

class LogState {
  final List<LogEntry> entries;
  final bool paused;
  final LogFilter filter;

  LogState({
    this.entries = const [],
    this.paused = false,
    this.filter = LogFilter.all,
  });

  List<LogEntry> get filteredEntries {
    return switch (filter) {
      LogFilter.all => entries.where((e) => e.message is! MotionMessage).toList(),
      LogFilter.buttons =>
        entries.where((e) => e.message is ButtonMessage).toList(),
      LogFilter.stick =>
        entries.where((e) => e.message is StickMessage).toList(),
      LogFilter.trigger =>
        entries.where((e) => e.message is TriggerMessage).toList(),
      LogFilter.motion =>
        entries.where((e) => e.message is MotionMessage).toList(),
    };
  }

  LogState copyWith({
    List<LogEntry>? entries,
    bool? paused,
    LogFilter? filter,
  }) => LogState(
    entries: entries ?? this.entries,
    filter: filter ?? this.filter,
    paused: paused ?? this.paused,
  );
}

class LogController extends Notifier<LogState> {
  @override
  LogState build() {
    final sub = ref.listen(socketMessagesProvider, (prev, next) {
      final message = next.value;
      if (message == null || state.paused) return;
      _append(message);
    });
    ref.onDispose(sub.close);
    return LogState();
  }

  void setFilter(LogFilter value) {
    state = state.copyWith(filter: value);
  }

  void setPaused(bool value) => state = state.copyWith(paused: value);

  void clearAll() {
    state = state.copyWith(entries: const []);
  }

  void _append(Message message) {
    // Watchdog traffic isn't user input.
    if (message is Ping || message is Pong) return;
    // Motion samples (~50/s) would push every real input out of the log, so
    // they are only recorded while the motion filter is selected.
    if (message is MotionMessage && state.filter != LogFilter.motion) return;

    final entries = [...state.entries];
    final now = DateTime.now();

    final newest = entries.isNotEmpty ? entries.first : null;
    if (newest != null &&
        _sameControl(newest.message, message) &&
        now.difference(newest.time).inMilliseconds < 100) {
      entries[0] = LogEntry(time: now, message: message); // coalesce
    } else {
      entries.insert(0, LogEntry(time: now, message: message));
    }

    if (entries.length > 500) entries.removeRange(500, entries.length);
    state = state.copyWith(entries: entries);
  }

  bool _sameControl(Message a, Message b) => switch ((a, b)) {
    (ButtonMessage(), _) => false,
    (TriggerMessage(trigger: final t1), TriggerMessage(trigger: final t2)) =>
      t1 == t2,
    (StickMessage(stick: final s1), StickMessage(stick: final s2)) => s1 == s2,
    (MotionMessage(), MotionMessage()) => true,
    _ => false,
  };
}

final logControllerProvider =
    NotifierProvider<LogController, LogState>(LogController.new);
