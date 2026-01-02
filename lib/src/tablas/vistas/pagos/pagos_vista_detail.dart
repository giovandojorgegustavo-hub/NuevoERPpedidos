import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:flutter/material.dart';

String _formatDateTimeValue(dynamic value) {
  if (value == null) return '-';
  final raw = value.toString();
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw.isEmpty ? '-' : raw;
  String two(int v) => v.toString().padLeft(2, '0');
  final date =
      '${parsed.year}-${two(parsed.month)}-${two(parsed.day)}';
  final time =
      '${two(parsed.hour)}:${two(parsed.minute)}:${two(parsed.second)}';
  return '$date $time';
}

DetailViewConfig buildPagosVistaDetail({
  required Map<String, dynamic> row,
  required List<InlineTableConfig> inlineTables,
  VoidCallback? onBack,
  DetailActionConfig? floatingAction,
}) {
  final registradoAt = _formatDateTimeValue(
    row['registrado_at'] ?? row['Fecha de registro'],
  );
  final fechaPago = _formatDateTimeValue(
    row['fechapago'] ?? row['Fecha de pago'],
  );
  final monto =
      row['monto']?.toString() ?? row['Monto']?.toString() ?? '-';
  final cuenta = row['cuenta_nombre']?.toString() ??
      row['Cuenta bancaria']?.toString() ??
      '-';

  return DetailViewConfig(
    title: 'Pagos registrados',
    subtitle: cuenta,
    fields: [
      DetailFieldConfig(label: 'Fecha de registro', value: registradoAt),
      DetailFieldConfig(label: 'Fecha de pago', value: fechaPago),
      DetailFieldConfig(label: 'Monto', value: monto),
      DetailFieldConfig(label: 'Cuenta bancaria', value: cuenta),
    ],
    inlineSections: inlineTables,
    onBack: onBack,
    floatingAction: floatingAction,
  );
}
