import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// IANA time-zone aware business dates (docs/02). Offsets are never hardcoded.
bool _initialized = false;

void ensureTimeZones() {
  if (_initialized) return;
  tzdata.initializeTimeZones();
  _initialized = true;
}

bool isValidTimeZone(String name) {
  ensureTimeZones();
  try {
    tz.getLocation(name);
    return true;
  } catch (_) {
    return false;
  }
}

/// YYYY-MM-DD of [instant] in [timeZone].
String localDateOf(DateTime instant, String timeZone) {
  ensureTimeZones();
  final local = tz.TZDateTime.from(instant.toUtc(), tz.getLocation(timeZone));
  return '${local.year.toString().padLeft(4, '0')}-${_two(local.month)}-${_two(local.day)}';
}

/// Date-only input resolves to local noon in the chosen zone.
DateTime noonInZone(String date, String timeZone) {
  ensureTimeZones();
  final p = date.split('-').map(int.parse).toList();
  return tz.TZDateTime(tz.getLocation(timeZone), p[0], p[1], p[2], 12).toUtc();
}

/// RFC3339 UTC instant with exactly millisecond precision and Z.
String toInstant(DateTime t) {
  final u = DateTime.fromMillisecondsSinceEpoch(
    t.millisecondsSinceEpoch,
    isUtc: true,
  );
  return '${u.year.toString().padLeft(4, '0')}-${_two(u.month)}-${_two(u.day)}T${_two(u.hour)}:${_two(u.minute)}:${_two(u.second)}.${u.millisecond.toString().padLeft(3, '0')}Z';
}

DateTime parseInstant(String s) => DateTime.parse(s).toUtc();

String monthOf(String date) => date.substring(0, 7);

String addDays(String date, int days) {
  final p = date.split('-').map(int.parse).toList();
  final d = DateTime.utc(p[0], p[1], p[2] + days);
  return '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';
}

String firstOfNextMonth(String month) {
  final p = month.split('-').map(int.parse).toList();
  final d = DateTime.utc(p[0], p[1] + 1, 1);
  return '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-01';
}

String _two(int v) => v.toString().padLeft(2, '0');
