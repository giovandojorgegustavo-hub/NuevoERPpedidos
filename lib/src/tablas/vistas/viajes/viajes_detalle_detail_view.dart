import 'package:flutter/material.dart';
import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:erp_app/src/shared/utils/date_time_utils.dart'
    as date_time_utils;

DetailViewConfig buildViajesDetalleReadonlyDetail({
  required Map<String, dynamic> row,
  required List<InlineTableConfig> inlineTables,
  VoidCallback? onBack,
  DetailActionConfig? floatingAction,
}) {
  final fields = <DetailFieldConfig>[
    DetailFieldConfig(
      label: 'Cliente',
      value: row['cliente_nombre']?.toString() ?? '-',
    ),
    DetailFieldConfig(
      label: 'Número cliente',
      value: row['cliente_numero']?.toString() ?? '-',
    ),
    DetailFieldConfig(
      label: 'Base',
      value: row['base_nombre']?.toString() ?? '-',
    ),
    DetailFieldConfig(
      label: 'Dirección',
      value: row['direccion_display']?.toString() ??
          row['direccion_texto']?.toString() ??
          '-',
    ),
    DetailFieldConfig(
      label: 'Contacto',
      value: row['contacto_display']?.toString() ??
          row['contacto_nombre']?.toString() ??
          '-',
    ),
    DetailFieldConfig(
      label: 'Estado',
      value: (row['estado_detalle']?.toString() ?? 'en_camino')
          .replaceAll('_', ' ')
          .replaceFirstMapped(
            RegExp(r'^\w'),
            (match) => match.group(0)!.toUpperCase(),
          ),
    ),
    DetailFieldConfig(
      label: 'Packing',
      value: row['packing_display']?.toString() ??
          row['packing_nombre']?.toString() ??
          '-',
    ),
    DetailFieldConfig(
      label: 'Llegada',
      value: _formatDate(row['llegada_at']),
    ),
  ];

  return DetailViewConfig(
    title: 'Detalle de viaje',
    subtitle: row['cliente_nombre']?.toString() ?? '',
    fields: fields,
    inlineSections: inlineTables,
    onBack: onBack,
    floatingAction: null, // lectura únicamente
  );
}

String _formatDate(dynamic value) {
  return date_time_utils.formatLocalDateTimeFromValue(value) ?? '-';
}
