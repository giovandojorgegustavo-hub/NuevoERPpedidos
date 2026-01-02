import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource comprasDataSource = SectionDataSource(
  sectionId: 'compras',
  listSchema: 'public',
  listRelation: 'v_compras_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'compras',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_compras_vistageneral',
  detailIsView: true,
);

const List<TableColumnConfig> comprasColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Fecha registro'),
  TableColumnConfig(key: 'proveedor_nombre', label: 'Proveedor'),
  TableColumnConfig(key: 'base_nombre', label: 'Bases vinculadas'),
  TableColumnConfig(key: 'estado_pago', label: 'Estado de pago'),
  TableColumnConfig(key: 'estado_entrega', label: 'Estado de entrega'),
];

const List<DetailFieldOverride> comprasCamposDetalle = [
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha de registro'),
  DetailFieldOverride(key: 'proveedor_nombre', label: 'Proveedor'),
  DetailFieldOverride(key: 'proveedor_numero', label: 'Número fiscal'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
  DetailFieldOverride(key: 'base_nombre', label: 'Bases asociadas'),
  DetailFieldOverride(key: 'total_detalle', label: 'Total calculado'),
  DetailFieldOverride(key: 'total_pagado', label: 'Total pagado'),
  DetailFieldOverride(key: 'saldo', label: 'Saldo'),
  DetailFieldOverride(key: 'estado_pago', label: 'Estado pago'),
  DetailFieldOverride(key: 'estado_entrega', label: 'Estado entrega'),
];

const List<InlineSectionConfig> comprasInlineSections = [
  comprasDetalleInlineSection,
  comprasPagosInlineSection,
  comprasMovimientosInlineSection,
  comprasHistorialContableInlineSection,
];

const InlineSectionConfig comprasDetalleInlineSection = InlineSectionConfig(
  id: 'compras_detalle',
  title: 'Detalle de compra',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_compras_detalle_vistageneral',
    orderBy: 'registrado_at',
  ),
  foreignKeyColumn: 'idcompra',
  columns: [
    InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
    InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
    InlineSectionColumn(key: 'costo_unitario', label: 'Costo unitario'),
    InlineSectionColumn(key: 'costo_total', label: 'Costo total'),
  ],
  showInForm: true,
  enableCreate: true,
  formSectionId: 'compras_detalle',
  formForeignKeyField: 'idcompra',
  pendingFieldMapping: {
    'producto_nombre': 'idproducto',
    'cantidad': 'cantidad',
    'costo_total': 'costo_total',
  },
);

const InlineSectionConfig comprasPagosInlineSection = InlineSectionConfig(
  id: 'compras_pagos',
  title: 'Pagos registrados',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_compras_pagos_vistageneral',
    orderBy: 'registrado_at',
  ),
  foreignKeyColumn: 'idcompra',
  columns: [
    InlineSectionColumn(key: 'cuenta_nombre', label: 'Cuenta'),
    InlineSectionColumn(key: 'monto', label: 'Monto'),
    InlineSectionColumn(key: 'registrado_display', label: 'Fecha'),
  ],
  emptyPlaceholder: 'Sin pagos registrados.',
  showInForm: true,
  enableCreate: true,
  formSectionId: 'compras_pagos',
  formForeignKeyField: 'idcompra',
  pendingFieldMapping: {'cuenta_nombre': 'idcuenta', 'monto': 'monto'},
);

const InlineSectionConfig comprasMovimientosInlineSection = InlineSectionConfig(
  id: 'compras_movimientos',
  title: 'Movimientos de ingreso',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_compras_movimientos_vistageneral',
    orderBy: 'registrado_at',
  ),
  foreignKeyColumn: 'idcompra',
  columns: [
    InlineSectionColumn(key: 'base_nombre', label: 'Base'),
    InlineSectionColumn(key: 'cantidad_total', label: 'Cantidad total'),
    InlineSectionColumn(key: 'productos_registrados', label: 'Productos'),
  ],
  emptyPlaceholder: 'Sin movimientos registrados.',
  showInForm: true,
  enableCreate: true,
  formSectionId: 'compras_movimientos',
  formForeignKeyField: 'idcompra',
  pendingFieldMapping: {'base_nombre': 'idbase', 'observacion': 'observacion'},
  rowTapSectionId: 'compras_movimientos',
  formTitle: 'Movimiento de compra',
);

const InlineSectionConfig comprasHistorialContableInlineSection =
    InlineSectionConfig(
  id: 'compras_historial_contable',
  title: 'Historial contable',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_compras_historial_contable',
    orderBy: 'fecha_at',
    orderAscending: false,
  ),
  foreignKeyColumn: 'idcompra',
  columns: [
    InlineSectionColumn(key: 'fecha_display', label: 'Fecha'),
    InlineSectionColumn(key: 'source_prefix', label: 'Origen'),
    InlineSectionColumn(key: 'descripcion', label: 'Descripcion'),
    InlineSectionColumn(key: 'debe', label: 'Debe'),
    InlineSectionColumn(key: 'haber', label: 'Haber'),
    InlineSectionColumn(key: 'estado', label: 'Estado'),
    InlineSectionColumn(key: 'reversa_label', label: 'Reversa'),
  ],
  emptyPlaceholder: 'Sin movimientos contables.',
  enableCreate: false,
  enableView: false,
);

Map<String, dynamic> comprasRowTransformer(Map<String, dynamic> row) {
  final formatted = Map<String, dynamic>.from(row);
  if (row['base_nombre'] == null || row['base_nombre'].toString().isEmpty) {
    formatted['base_nombre'] = 'Sin base asociada';
  }
  final movimientosFlag = row['tiene_movimientos'];
  if (movimientosFlag != null) {
    if (movimientosFlag is bool) {
      formatted['tiene_movimientos'] = movimientosFlag;
    } else if (movimientosFlag is num) {
      formatted['tiene_movimientos'] = movimientosFlag != 0;
    } else {
      final text = movimientosFlag.toString().toLowerCase().trim();
      formatted['tiene_movimientos'] = text == 'true' || text == '1';
    }
  }
  return formatted;
}
