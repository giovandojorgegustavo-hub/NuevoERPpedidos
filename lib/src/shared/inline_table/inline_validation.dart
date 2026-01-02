import 'package:erp_app/src/shared/inline_table/inline_pending_row.dart';

/// Checks if a value is already present in persisted or pending inline rows.
bool isInlineValueDuplicated({
  required Iterable<Map<String, dynamic>> persistedRows,
  required Iterable<InlinePendingRow> pendingRows,
  required String fieldName,
  required String value,
  String? excludePendingId,
  dynamic excludeRowId,
}) {
  for (final row in persistedRows) {
    if (excludeRowId != null && row['id'] == excludeRowId) {
      continue;
    }
    final rowValue = row[fieldName]?.toString();
    if (rowValue != null && rowValue.isNotEmpty && rowValue == value) {
      return true;
    }
  }
  for (final row in pendingRows) {
    if (excludePendingId != null && row.pendingId == excludePendingId) {
      continue;
    }
    final pendingValue = row.rawValues[fieldName]?.toString();
    if (pendingValue != null &&
        pendingValue.isNotEmpty &&
        pendingValue == value) {
      return true;
    }
  }
  return false;
}

String? validateInlineRequired(String? value, String message) {
  if (value == null) return message;
  if (value.trim().isEmpty) return message;
  return null;
}

String? validateInlineMax({
  required double value,
  required double max,
  required String message,
  double tolerance = 0.0001,
}) {
  if (value - max > tolerance) {
    return message;
  }
  return null;
}
