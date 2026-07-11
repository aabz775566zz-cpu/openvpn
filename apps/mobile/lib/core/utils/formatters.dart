/// Small formatting helpers shared across features.
class Formatters {
  const Formatters._();

  /// Formats a [Duration] as `HH:MM:SS`, used to display elapsed connection
  /// time on the home and VPN screens.
  static String duration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
