import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

/// Configuración compartida para secciones relacionadas a movimientos.
const InlineSectionConfig movimientosDetalleInlineSection =
    InlineSectionConfig(
  id: 'movimientos_detalle',
  title: 'Detalle del movimiento',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_movimiento_detalle_vistageneral',
    orderBy: 'producto_nombre',
  ),
  foreignKeyColumn: 'idmovimiento',
  columns: [
    InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
    InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
  ],
  showInForm: true,
  enableCreate: true,
  formSectionId: 'movimientos_detalle',
  formForeignKeyField: 'idmovimiento',
  pendingFieldMapping: {
    'producto_nombre': 'idproducto',
    'cantidad': 'cantidad',
  },
  rowTapSectionId: 'movimientos_detalle',
);

const InlineSectionConfig movimientosDetalleLecturaInlineSection =
    InlineSectionConfig(
  id: 'movimientos_detalle',
  title: 'Detalle del movimiento',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_movimiento_detalle_vistageneral',
    orderBy: 'producto_nombre',
  ),
  foreignKeyColumn: 'idmovimiento',
  columns: [
    InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
    InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
  ],
  showInForm: false,
  enableCreate: false,
  formSectionId: 'movimientos_detalle',
  formForeignKeyField: 'idmovimiento',
  pendingFieldMapping: {
    'producto_nombre': 'idproducto',
    'cantidad': 'cantidad',
  },
  rowTapSectionId: 'movimientos_detalle',
);

const SectionDataSource pedidosMovimientosDataSource = SectionDataSource(
  sectionId: 'pedidos_movimientos',
  listSchema: 'public',
  listRelation: 'v_movimiento_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'movimientopedidos',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
  listOrderBy: 'fecharegistro',
  listOrderAscending: false,
  listLimit: 120,
);

const List<DetailFieldOverride> pedidosMovimientosCamposDetalle = [
  DetailFieldOverride(key: 'codigo', label: 'Movimiento'),
  DetailFieldOverride(key: 'destino_tipo', label: 'Destino'),
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'direccion_display', label: 'Dirección'),
  DetailFieldOverride(
    key: 'referencia_display',
    label: 'Referencia / info',
  ),
  DetailFieldOverride(
    key: 'contacto_numero_display',
    label: 'Número / DNI',
  ),
  DetailFieldOverride(
    key: 'contacto_nombre_display',
    label: 'Nombre que recibe',
  ),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
];

const List<TableColumnConfig> movimientosLecturaColumnas = [
  TableColumnConfig(key: 'codigo', label: 'Movimiento'),
  TableColumnConfig(key: 'fecharegistro', label: 'Fecha'),
  TableColumnConfig(key: 'estado_texto', label: 'Estado'),
  TableColumnConfig(key: 'destino_tipo', label: 'Destino'),
  TableColumnConfig(key: 'cliente_nombre', label: 'Cliente'),
  TableColumnConfig(key: 'cliente_numero', label: 'Número'),
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
];

Map<String, dynamic> movimientosLecturaRowTransformer(
  Map<String, dynamic> row,
) {
  final transformed = Map<String, dynamic>.from(row);
  final estado = (row['estado_texto'] ?? '').toString().trim();
  final isProvincia =
      (row['es_provincia']?.toString().toLowerCase() ?? '') == 'true';
  transformed['destino_tipo'] = isProvincia ? 'Provincia' : 'Lima';
  transformed['estado_texto'] = estado.isEmpty ? 'Pendiente' : estado;
  transformed['cliente_nombre'] =
      row['cliente_nombre']?.toString() ?? 'Sin cliente';
  transformed['cliente_numero'] =
      row['cliente_numero']?.toString() ?? 'Sin número';
  transformed['estado_grupo'] = estado.isEmpty ? 'Pendiente' : estado;
  return transformed;
}
