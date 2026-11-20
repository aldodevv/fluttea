import 'dart:async';

import 'package:fluttea/core/constants/ui/durations.dart';

class Debouncer {
  new({this.delay = AppDurations.debounce});

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}
