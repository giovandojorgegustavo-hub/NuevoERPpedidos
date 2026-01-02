import 'package:erp_app/src/shared/utils/date_time_utils.dart'
    as date_time_utils;

String formatColumnLabel(String key) {
  final sanitized = key.replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ');
  if (sanitized.isEmpty) return key;
  return sanitized
      .split(' ')
      .map(
        (segment) => segment.isEmpty
            ? segment
            : '${segment[0].toUpperCase()}${segment.substring(1)}',
      )
      .join(' ');
}

String formatOptionLabel(String value) {
  final sanitized = value.replaceAll('_', ' ').replaceAll('-', ' ');
  if (sanitized.isEmpty) return value;
  return sanitized[0].toUpperCase() + sanitized.substring(1);
}

String formatInlineValue(dynamic value) {
  if (value == null) return '';
  final text = value.toString();
  if (text.isEmpty || text.toLowerCase() == 'null') return '';
  return text;
}

bool isDateFieldKey(String key) {
  final lower = key.toLowerCase();
  if (lower.endsWith('_at')) return true;
  final parts = lower.split('_');
  for (final part in parts) {
    if (part.startsWith('fecha') || part.startsWith('date')) {
      return true;
    }
  }
  return false;
}

String? formatDateTimeString(String value) {
  return date_time_utils.formatLocalDateTimeString(value);
}

String formatDetailValue(String key, dynamic value) {
  if (value == null) return '';
  final stringValue = value.toString();
  if (isDateFieldKey(key)) {
    final formatted = formatDateTimeString(stringValue);
    if (formatted != null) {
      return formatted;
    }
  }
  return stringValue;
}
