import 'package:erp_app/src/navegacion/inline_types.dart';
import 'package:erp_app/src/shared/inline_table/inline_helpers.dart';
import 'package:erp_app/src/shared/utils/date_time_utils.dart'
    as date_time_utils;

Map<String, String> buildComprasPagosPendingDisplay(
  InlinePendingDisplayContext context,
) {
  final fechaRaw = normalizeInlineValue(context.rawValues['registrado_at']);
  final cuentaId = normalizeInlineValue(context.rawValues['idcuenta']);
  final monto = normalizeInlineValue(context.rawValues['monto']);

  return {
    'registrado_display': _formatDisplayDate(fechaRaw),
    'cuenta_nombre': cuentaId.isEmpty
        ? ''
        : context.resolveReferenceLabel('idcuenta', cuentaId) ?? '',
    'monto': monto,
  };
}

String _formatDisplayDate(String value) {
  if (value.isEmpty) return '';
  final parsed = date_time_utils.parseDateTimeValue(value);
  if (parsed == null) return value;
  final local = parsed.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
}
