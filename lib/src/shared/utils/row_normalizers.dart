import 'package:erp_app/src/shared/utils/date_time_utils.dart' as dt;
import 'package:erp_app/src/shared/utils/template_formatters.dart';

/// Normaliza valores SOLO para display.
/// - No toca persistencia.
/// - No cambia la semántica, solo hace consistente cómo se muestran tipos comunes.
Map<String, dynamic> normalizeRowForDisplay(Map<String, dynamic> row) {
  final out = Map<String, dynamic>.from(row);

  for (final entry in row.entries) {
    final key = entry.key;
    final value = entry.value;

    // 1) Normalizar strings vacíos / "null"
    if (value is String) {
      final t = value.trim();
      if (t.isEmpty || t.toLowerCase() == 'null') {
        out[key] = null;
        continue;
      }
    }

    // 2) Normalizar fechas (DISPLAY) a horario local y formato consistente
    if (value != null && isDateFieldKey(key)) {
      final formatted = dt.formatLocalDateTimeFromValue(value);
      if (formatted != null) {
        out[key] = formatted;
      }
    }
  }

  return out;
}
