import 'dart:async';

class Debouncer {
  Timer? _timer;

  void debounce(Function() function, {Duration? duration}) {
    _cancelTimer();
    _timer = Timer(
      duration ??
          const Duration(
            milliseconds: 500,
          ),
      () {
        function();
        _timer = null;
      },
    );
  }

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }
}
