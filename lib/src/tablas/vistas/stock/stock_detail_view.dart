import 'dart:convert';

import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:flutter/material.dart';

DetailViewConfig buildStockDetalleView({
  required Map<String, dynamic> row,
  required List<InlineTableConfig> inlineTables,
  VoidCallback? onBack,
  DetailActionConfig? floatingAction,
}) {
  return _buildStockDetail(
    row: row,
    inlineTables: inlineTables,
    onBack: onBack,
    floatingAction: floatingAction,
    showCosts: false,
  );
}

DetailViewConfig buildStockAdminDetalleView({
  required Map<String, dynamic> row,
  required List<InlineTableConfig> inlineTables,
  VoidCallback? onBack,
  DetailActionConfig? floatingAction,
}) {
  return _buildStockDetail(
    row: row,
    inlineTables: inlineTables,
    onBack: onBack,
    floatingAction: floatingAction,
    showCosts: true,
  );
}

DetailViewConfig _buildStockDetail({
  required Map<String, dynamic> row,
  required List<InlineTableConfig> inlineTables,
  required bool showCosts,
  VoidCallback? onBack,
  DetailActionConfig? floatingAction,
}) {
  final baseNombre = _stringValue(row['base_nombre'], fallback: 'Base');
  final productos = _parseProductos(row['productos']);
  final productosRegistrados = _intValue(
    row['productos_registrados'],
    fallback: productos.length,
  );
  final totalCantidad = _formatNumber(row['total_cantidad']);
  final totalValor = _formatNumber(row['total_valor']);
  final fields = <DetailFieldConfig>[
    DetailFieldConfig(
      label: 'Productos distintos',
      value: productosRegistrados.toString(),
    ),
    DetailFieldConfig(label: 'Cantidad total', value: totalCantidad),
  ];
  if (showCosts) {
    fields.add(DetailFieldConfig(label: 'Valor total', value: totalValor));
  }

  final inlineColumns = <String>['Producto', 'Cantidad'];
  if (showCosts) {
    inlineColumns.addAll(['Costo unitario', 'Valor total']);
  }

  final inlineRows = productos
      .map(
        (producto) => InlineTableRow(
          displayValues: {
            'Producto': _stringValue(
              producto['producto_nombre'],
              fallback: '-',
            ),
            'Cantidad': _formatNumber(producto['cantidad']),
            if (showCosts) ...{
              'Costo unitario': _formatNumber(
                producto['costo_unitario'],
                decimals: 4,
              ),
              'Valor total': _formatNumber(producto['valor_total']),
            },
          },
          rawRow: producto,
        ),
      )
      .toList(growable: false);

  final detalleInlineTable = InlineTableConfig(
    title: 'Detalle de productos',
    columns: inlineColumns,
    rows: inlineRows,
    emptyPlaceholder: 'Sin productos registrados.',
  );

  final mergedInlineTables = <InlineTableConfig>[
    detalleInlineTable,
    ...inlineTables,
  ];

  return DetailViewConfig(
    title: baseNombre,
    subtitle: showCosts ? 'Stock administrativo' : 'Stock por base',
    fields: fields,
    inlineSections: mergedInlineTables,
    onBack: onBack,
    floatingAction: floatingAction,
  );
}

List<Map<String, dynamic>> _parseProductos(dynamic value) {
  if (value is List) {
    return value
        .map<Map<String, dynamic>>(
          (item) => item is Map<String, dynamic>
              ? Map<String, dynamic>.from(item)
              : item is Map
              ? item.map((key, v) => MapEntry(key.toString(), v))
              : <String, dynamic>{},
        )
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = json.decode(value);
      return _parseProductos(decoded);
    } catch (_) {
      return const [];
    }
  }

  return const [];
}

String _stringValue(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
  return text;
}

int _intValue(dynamic value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  final parsed = int.tryParse(value?.toString() ?? '');
  return parsed ?? fallback;
}

String _formatNumber(dynamic value, {int decimals = 2}) {
  final numeric = value is num ? value.toDouble() : double.tryParse('$value');
  if (numeric == null) {
    return 0.toStringAsFixed(decimals);
  }
  return numeric.toStringAsFixed(decimals);
}
