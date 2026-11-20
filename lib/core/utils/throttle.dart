import 'dart:async';

import 'package:fluttea/core/constants/ui/durations.dart';

class Throttler {
  new({this.duration = AppDurations.throttle});

  final Duration duration;
  Timer? _timer;
  bool _isThrottled = false;

  void run(void Function() action) {
    if (_isThrottled) return;

    action();
    _isThrottled = true;
    _timer?.cancel();
    _timer = Timer(duration, () {
      _isThrottled = false;
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _isThrottled = false;
  }

  void dispose() {
    cancel();
  }
}
