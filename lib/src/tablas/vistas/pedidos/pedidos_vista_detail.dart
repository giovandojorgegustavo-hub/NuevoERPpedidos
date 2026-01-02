import 'package:erp_app/src/tablas/vistas/pedidos/pedidos_vista_tabla.dart';
import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:flutter/material.dart';

DetailViewConfig buildPedidosVistaDetail({
  required Map<String, dynamic> row,
  required List<InlineTableConfig> inlineTables,
  VoidCallback? onBack,
  DetailActionConfig? floatingAction,
}) {
  final fields = pedidosVistaTablaDetailFields
      .map(
        (override) => DetailFieldConfig(
          label: override.label,
          value: row[override.key]?.toString() ?? '-',
        ),
      )
      .toList(growable: false);
  return DetailViewConfig(
    title: 'Pedido',
    subtitle: row['cliente_nombre']?.toString() ?? '',
    fields: fields,
    inlineSections: inlineTables,
    onBack: onBack,
    floatingAction: floatingAction,
  );
}
