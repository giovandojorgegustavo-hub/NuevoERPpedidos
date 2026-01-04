import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:flutter/material.dart';

const SectionDataSource stockDataSource = SectionDataSource(
  sectionId: 'operaciones_stock',
  listSchema: 'public',
  listRelation: 'v_stock_por_base',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_stock_por_base',
  detailIsView: true,
);

const SectionDataSource stockAdminDataSource = SectionDataSource(
  sectionId: 'stock_admin',
  listSchema: 'public',
  listRelation: 'v_stock_por_base',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_stock_por_base',
  detailIsView: true,
);

const List<TableColumnConfig> stockOperacionesColumnas = [
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(
    key: 'productos_registrados',
    label: 'Productos registrados',
    textAlign: TextAlign.right,
  ),
  TableColumnConfig(
    key: 'total_cantidad',
    label: 'Cantidad total',
    textAlign: TextAlign.right,
  ),
];

const List<TableColumnConfig> stockAdminColumnas = [
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(
    key: 'productos_registrados',
    label: 'Productos registrados',
    textAlign: TextAlign.right,
  ),
  TableColumnConfig(
    key: 'total_cantidad',
    label: 'Cantidad total',
    textAlign: TextAlign.right,
  ),
  TableColumnConfig(
    key: 'total_valor',
    label: 'Valor total',
    textAlign: TextAlign.right,
  ),
];

Map<String, dynamic> stockAdminRowTransformer(Map<String, dynamic> row) {
  final formatted = Map<String, dynamic>.from(row);
  formatted['total_valor'] = _formatFixed(formatted['total_valor']);
  return formatted;
}

String _formatFixed(dynamic value, {int decimals = 2}) {
  final numeric = value is num ? value.toDouble() : double.tryParse('$value');
  if (numeric == null) {
    return 0.toStringAsFixed(decimals);
  }
  return numeric.toStringAsFixed(decimals);
}
