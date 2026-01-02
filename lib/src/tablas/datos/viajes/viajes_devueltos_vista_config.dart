import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:flutter/material.dart';

const SectionDataSource viajesDevueltosDataSource = SectionDataSource(
  sectionId: 'viajes_devueltos',
  listSchema: 'public',
  listRelation: 'v_viajes_devueltos_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'viajes_devueltos',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
  listLimit: 80,
);

const List<TableColumnConfig> viajesDevueltosColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Registrado'),
  TableColumnConfig(key: 'cliente_nombre', label: 'Cliente'),
  TableColumnConfig(key: 'base_origen_nombre', label: 'Base origen'),
  TableColumnConfig(key: 'base_retorno_nombre', label: 'Base retorno'),
  TableColumnConfig(
    key: 'estado',
    label: 'Estado',
    textAlign: TextAlign.center,
  ),
  TableColumnConfig(
    key: 'productos_devueltos',
    label: 'Productos',
    textAlign: TextAlign.end,
  ),
  TableColumnConfig(
    key: 'cantidad_devuelta',
    label: 'Cantidad devuelta',
    textAlign: TextAlign.end,
  ),
  TableColumnConfig(
    key: 'costo_logistico',
    label: 'Costo logístico',
    textAlign: TextAlign.end,
  ),
];

const List<DetailFieldOverride> viajesDevueltosCamposDetalle = [
  DetailFieldOverride(key: 'cliente_nombre', label: 'Cliente'),
  DetailFieldOverride(key: 'cliente_numero', label: 'Número cliente'),
  DetailFieldOverride(key: 'base_origen_nombre', label: 'Base origen'),
  DetailFieldOverride(key: 'base_retorno_nombre', label: 'Base retorno'),
  DetailFieldOverride(key: 'estado', label: 'Estado'),
  DetailFieldOverride(
    key: 'productos_devueltos',
    label: 'Productos devueltos',
  ),
  DetailFieldOverride(
    key: 'cantidad_devuelta',
    label: 'Cantidad devuelta',
  ),
  DetailFieldOverride(key: 'monto_ida', label: 'Monto ida'),
  DetailFieldOverride(key: 'monto_vuelta', label: 'Monto vuelta'),
  DetailFieldOverride(key: 'penalidad', label: 'Penalidad'),
  DetailFieldOverride(key: 'cliente_resuelto_at', label: 'Cliente resolvió'),
  DetailFieldOverride(key: 'devuelto_recibido_at', label: 'Devuelto recibido'),
  DetailFieldOverride(key: 'link_evidencia', label: 'Link'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
];

Map<String, dynamic> viajesDevueltosRowTransformer(
  Map<String, dynamic> row,
) {
  final transformed = Map<String, dynamic>.from(row);
  final estado = (row['estado']?.toString() ?? '').trim();
  transformed['estado'] = estado.isEmpty ? 'pendiente' : estado;
  transformed['estado_grupo'] = transformed['estado'];
  transformed['costo_logistico'] =
      _formatMoney(_parseMoney(row['monto_ida']) +
          _parseMoney(row['monto_vuelta']) +
          _parseMoney(row['penalidad']));
  return transformed;
}

double _parseMoney(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _formatMoney(double value) {
  return value.toStringAsFixed(2);
}

const InlineSectionConfig viajesDevueltosDetalleInlineSection =
    InlineSectionConfig(
  id: 'viajes_devueltos_detalle_listado',
  title: 'Productos devueltos',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_viajes_devueltos_detalle_vistageneral',
    orderBy: 'producto_nombre',
  ),
  foreignKeyColumn: 'iddevuelto',
  columns: [
    InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
    InlineSectionColumn(
      key: 'cantidad_movimiento',
      label: 'Cantidad enviada',
    ),
    InlineSectionColumn(key: 'cantidad', label: 'Cantidad devuelta'),
  ],
  showInForm: true,
  showInDetail: true,
  enableCreate: false,
  enableView: false,
  formSectionId: 'viajes_devueltos_detalle',
  formForeignKeyField: 'iddevuelto',
  requiresPersistedParent: true,
  emptyPlaceholder: 'Sin productos devueltos.',
);
