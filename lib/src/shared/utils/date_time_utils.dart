String formatLocalDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
}

String? formatLocalDateTimeString(String? value) {
  final parsed = parseDateTimeValue(value);
  if (parsed == null) return null;
  return formatLocalDateTime(parsed);
}

String? formatLocalDateTimeFromValue(dynamic value) {
  final parsed = parseDateTimeValue(value);
  if (parsed == null) return null;
  return formatLocalDateTime(parsed);
}

String? normalizeToUtcIsoString(dynamic value) {
  final parsed = parseDateTimeValue(value);
  if (parsed == null) return null;
  return parsed.toUtc().toIso8601String();
}

String currentLocalIsoString() {
  return DateTime.now().toLocal().toIso8601String();
}

String currentUtcIsoString() {
  return DateTime.now().toUtc().toIso8601String();
}

DateTime? parseDateTimeValue(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return DateTime.tryParse(text) ?? DateTime.tryParse(text.replaceAll(' ', 'T'));
}
