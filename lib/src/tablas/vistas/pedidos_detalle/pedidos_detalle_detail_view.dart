import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:flutter/material.dart';

DetailViewConfig buildPedidosDetalleDetailView({
  required Map<String, dynamic> row,
  required List<InlineTableConfig> inlineTables,
  VoidCallback? onBack,
  DetailActionConfig? floatingAction,
}) {
  final nombre =
      row['producto_nombre']?.toString() ?? row['Nombre']?.toString() ?? '-';
  final cantidad =
      row['cantidad']?.toString() ?? row['Cantidad']?.toString() ?? '-';
  final precio =
      row['precioventa']?.toString() ?? row['Precio total']?.toString() ?? '-';

  return DetailViewConfig(
    title: 'Pedidos Detalle',
    subtitle: nombre,
    fields: [
      DetailFieldConfig(label: 'Nombre', value: nombre),
      DetailFieldConfig(label: 'Cantidad', value: cantidad),
      DetailFieldConfig(label: 'Precio total', value: precio),
    ],
    inlineSections: inlineTables,
    onBack: onBack,
    floatingAction: floatingAction,
  );
}
