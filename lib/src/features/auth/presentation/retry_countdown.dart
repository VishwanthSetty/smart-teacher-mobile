import 'dart:async';

/// Ticks a `Retry-After` window down to zero, once a second.
///
/// All three auth screens are rate-limited independently (PRD §5.1.1, §5.1.4)
/// and all three want the same behaviour out of a `429`: say how long is left,
/// and re-enable the button by itself when it runs out. This is that behaviour
/// in one place, driven by whichever controller owns the state.
///
/// [onTick] receives the remaining time each second, then `null` exactly once
/// when the window closes. A window that is absent or already elapsed never
/// starts the timer — the app must not invent a duration the server didn't
/// give it (`RateLimitedError.retryAfter` is null when the response carried no
/// `Retry-After` header).
class RetryCountdown {
  RetryCountdown(this.onTick);

  final void Function(Duration? remaining) onTick;

  static const Duration _interval = Duration(seconds: 1);

  Timer? _timer;
  Duration? _remaining;

  /// Restarts the countdown, returning what the owner should store as the
  /// remaining time right now: [window] if it's worth counting down, `null`
  /// otherwise.
  Duration? start(Duration? window) {
    cancel();

    if (window == null || window <= Duration.zero) {
      return null;
    }

    _remaining = window;
    _timer = Timer.periodic(_interval, (Timer _) => _tick());
    return window;
  }

  /// Stops the countdown without reporting a tick. Call from the owner's
  /// `onDispose` — a timer outliving its controller would write to disposed
  /// state.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _remaining = null;
  }

  void _tick() {
    final Duration? remaining = _remaining;
    if (remaining == null || remaining <= _interval) {
      cancel();
      onTick(null);
      return;
    }

    _remaining = remaining - _interval;
    onTick(_remaining);
  }
}

/// Renders a remaining-time hint: `2 minutes 5s`, `1 minute`, `45s`.
String formatRetryWait(Duration remaining) {
  if (remaining.inMinutes < 1) {
    return '${remaining.inSeconds}s';
  }

  final int minutes = remaining.inMinutes;
  final int seconds = remaining.inSeconds % 60;
  final String unit = minutes == 1 ? 'minute' : 'minutes';

  return seconds == 0 ? '$minutes $unit' : '$minutes $unit ${seconds}s';
}
