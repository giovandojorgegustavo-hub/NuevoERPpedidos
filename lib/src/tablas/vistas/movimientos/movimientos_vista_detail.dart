import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/utils/date_time_utils.dart'
    as date_time_utils;
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:flutter/material.dart';

DetailViewConfig buildMovimientosDetailView({
  required Map<String, dynamic> row,
  required List<InlineTableConfig> inlineTables,
  VoidCallback? onBack,
  DetailActionConfig? floatingAction,
}) {
  final base = _formatValue(row['base_nombre']);
  final esProvincia = _parseBool(row['es_provincia']);
  final estado = _cleanValue(row['estado_texto']) ?? 'Pendiente';
  final fecha = _formatDate(row['fecharegistro']);
  final fields = <DetailFieldConfig>[
    DetailFieldConfig(label: 'Estado', value: estado),
  ];
  if (fecha != null) {
    fields.add(DetailFieldConfig(label: 'Fecha de registro', value: fecha));
  }
  fields.addAll([
    DetailFieldConfig(label: 'Base', value: base),
    DetailFieldConfig(
      label: 'Cliente',
      value: _cleanValue(row['cliente_nombre']) ?? '-',
    ),
    DetailFieldConfig(
      label: 'Número del cliente',
      value: _cleanValue(row['cliente_numero']) ?? '-',
    ),
  ]);

  if (esProvincia) {
    _addFieldIfNotEmpty(
      fields,
      'Nombre del destinatario',
      row['provincia_destinatario'] ?? row['contacto_nombre_display'],
    );
    _addFieldIfNotEmpty(
      fields,
      'DNI',
      row['provincia_dni'] ?? row['contacto_numero_display'],
    );
    _addFieldIfNotEmpty(
      fields,
      'Dirección',
      row['provincia_destino'] ?? row['direccion_display'],
    );
  } else {
    _addFieldIfNotEmpty(
      fields,
      'Dirección',
      row['direccion_display'] ?? row['direccion_texto'],
    );
    _addFieldIfNotEmpty(
      fields,
      'Referencia',
      row['referencia_display'] ?? row['direccion_referencia'],
    );
    _addFieldIfNotEmpty(
      fields,
      'Número / DNI',
      row['contacto_numero_display'] ?? row['contacto_numero'],
    );
    _addFieldIfNotEmpty(
      fields,
      'Nombre que recibe',
      row['contacto_nombre_display'] ?? row['cliente_nombre'],
    );
  }

  _addFieldIfNotEmpty(fields, 'Observación', row['observacion']);

  return DetailViewConfig(
    title: 'Movimiento',
    subtitle: base,
    fields: fields,
    inlineSections: inlineTables,
    onBack: onBack,
    floatingAction: floatingAction,
  );
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  final text = value?.toString().toLowerCase();
  if (text == null) return false;
  return text == 'true' || text == '1';
}

String _formatValue(dynamic value) {
  if (value == null) return '-';
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return '-';
  return text;
}

void _addFieldIfNotEmpty(
  List<DetailFieldConfig> fields,
  String label,
  dynamic value,
) {
  final cleaned = _cleanValue(value);
  if (cleaned == null) return;
  fields.add(DetailFieldConfig(label: label, value: cleaned));
}

String? _cleanValue(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

String? _formatDate(dynamic value) {
  return date_time_utils.formatLocalDateTimeFromValue(value);
}
