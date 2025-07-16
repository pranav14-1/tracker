import 'package:tracker/features/timer%20provider/timer_provider.dart';

class TimerManager {
  static final Map<String, TimerProvider> _providers = {};

  static TimerProvider get(String docID, TimerMode mode, Duration duration) {
    if (!_providers.containsKey(docID)) {
      _providers[docID] = TimerProvider(mode: mode, initialDuration: duration);
    }
    return _providers[docID]!;
  }

  static void remove(String docID) {
    _providers.remove(docID);
  }
}
