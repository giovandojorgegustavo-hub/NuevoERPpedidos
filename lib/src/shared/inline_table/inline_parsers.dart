double parseInlineNumber(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
