import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';

const SectionDataSource viajesDataSource = SectionDataSource(
  sectionId: 'viajes',
  listSchema: 'public',
  listRelation: 'v_viaje_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'viajes',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
  listLimit: 80,
);

const SectionDataSource viajesBasesDataSource = SectionDataSource(
  sectionId: 'viajes_bases',
  listSchema: 'public',
  listRelation: 'v_viaje_vistageneral_bases',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'viajes',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
  listLimit: 80,
);

const SectionDataSource viajesDetalleDataSource = SectionDataSource(
  sectionId: 'viajes_detalle',
  listSchema: 'public',
  listRelation: 'v_viaje_detalle_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'viajesdetalles',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
  listLimit: 120,
);

const SectionDataSource viajesProvinciaDataSource = SectionDataSource(
  sectionId: 'viajes_provincia',
  listSchema: 'public',
  listRelation: 'v_viaje_provincia_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'viajes_provincia',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
  listLimit: 120,
);

const List<TableColumnConfig> viajesColumnas = [
  TableColumnConfig(key: 'nombre_motorizado', label: 'Motorizado'),
  TableColumnConfig(key: 'num_wsp', label: 'Número WhatsApp'),
  TableColumnConfig(key: 'estado_texto', label: 'Estado'),
];

const List<TableColumnConfig> viajesDetalleTablaColumnas = [
  TableColumnConfig(key: 'movimiento_codigo', label: 'Movimiento'),
  TableColumnConfig(key: 'cliente_nombre', label: 'Cliente'),
  TableColumnConfig(key: 'cliente_numero', label: 'Número cliente'),
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'direccion_display', label: 'Dirección'),
  TableColumnConfig(key: 'contacto_display', label: 'Contacto'),
  TableColumnConfig(key: 'estado_detalle', label: 'Estado'),
  TableColumnConfig(key: 'packing_display', label: 'Packing'),
];

const List<TableColumnConfig> viajesProvinciaTablaColumnas = [
  TableColumnConfig(key: 'movimiento_codigo', label: 'Movimiento'),
  TableColumnConfig(key: 'cliente_nombre', label: 'Cliente'),
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'provincia_destino', label: 'Destino'),
  TableColumnConfig(key: 'estado_detalle', label: 'Estado'),
  TableColumnConfig(key: 'llegada_at', label: 'Llegada'),
];

const List<DetailFieldOverride> viajesDetalleCamposDetalle = [
  DetailFieldOverride(key: 'movimiento_codigo', label: 'Movimiento'),
  DetailFieldOverride(key: 'cliente_nombre', label: 'Cliente'),
  DetailFieldOverride(key: 'cliente_numero', label: 'Número cliente'),
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'direccion_display', label: 'Dirección'),
  DetailFieldOverride(key: 'contacto_display', label: 'Contacto'),
  DetailFieldOverride(key: 'estado_detalle', label: 'Estado'),
  DetailFieldOverride(key: 'packing_display', label: 'Packing'),
  DetailFieldOverride(key: 'llegada_at', label: 'Llegada'),
  DetailFieldOverride(key: 'incidente_tipo', label: 'Incidente'),
  DetailFieldOverride(
    key: 'incidente_cantidad',
    label: 'Cantidad afectada',
  ),
  DetailFieldOverride(
    key: 'incidente_observacion',
    label: 'Observación de incidente',
  ),
  DetailFieldOverride(
    key: 'incidente_registrado_at',
    label: 'Incidente registrado el',
  ),
];

const List<DetailFieldOverride> viajesProvinciaCamposDetalle = [
  DetailFieldOverride(key: 'movimiento_codigo', label: 'Movimiento'),
  DetailFieldOverride(key: 'pedido_codigo', label: 'Pedido'),
  DetailFieldOverride(key: 'cliente_nombre', label: 'Cliente'),
  DetailFieldOverride(key: 'cliente_numero', label: 'Número cliente'),
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'provincia_destino', label: 'Destino'),
  DetailFieldOverride(key: 'provincia_destinatario', label: 'Destinatario'),
  DetailFieldOverride(key: 'provincia_dni', label: 'DNI'),
  DetailFieldOverride(key: 'direccion_display', label: 'Dirección'),
  DetailFieldOverride(key: 'contacto_display', label: 'Contacto'),
  DetailFieldOverride(key: 'llegada_at', label: 'Llegada'),
  DetailFieldOverride(key: 'estado_detalle', label: 'Estado'),
];

const List<DetailFieldOverride> viajesCamposDetalle = [
  DetailFieldOverride(key: 'nombre_motorizado', label: 'Nombre del motorizado'),
  DetailFieldOverride(key: 'num_llamadas', label: 'Número de llamadas'),
  DetailFieldOverride(key: 'num_pago', label: 'Número de pago'),
  DetailFieldOverride(key: 'num_wsp', label: 'Número WhatsApp'),
  DetailFieldOverride(key: 'monto', label: 'Monto'),
  DetailFieldOverride(key: 'link', label: 'Link'),
];

const InlineSectionConfig viajesDetalleInlineSection = InlineSectionConfig(
  id: 'viajes_detalle',
  title: 'Detalle del viaje',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_viaje_detalle_vistageneral',
    orderBy: 'cliente_nombre',
  ),
  foreignKeyColumn: 'idviaje',
  columns: [
    InlineSectionColumn(key: 'movimiento_codigo', label: 'Movimiento'),
    InlineSectionColumn(key: 'cliente_nombre', label: 'Cliente'),
    InlineSectionColumn(key: 'cliente_numero', label: 'Número cliente'),
    InlineSectionColumn(key: 'direccion_display', label: 'Dirección'),
    InlineSectionColumn(key: 'contacto_display', label: 'Contacto'),
    InlineSectionColumn(key: 'estado_detalle', label: 'Estado'),
    InlineSectionColumn(key: 'packing_display', label: 'Packing'),
  ],
  showInForm: true,
  enableCreate: true,
  formSectionId: 'viajes_detalle',
  formForeignKeyField: 'idviaje',
  pendingFieldMapping: {
    'cliente_nombre': 'idmovimiento',
    'cliente_numero': 'idmovimiento',
    'direccion_display': 'idmovimiento',
    'contacto_display': 'idmovimiento',
    'packing_display': 'idpacking',
  },
);

const InlineSectionConfig viajesMovimientoDetalleInlineSection =
    InlineSectionConfig(
  id: 'viajes_movimientos_detalle',
  title: 'Detalle del movimiento',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_movimiento_detalle_vistageneral',
    orderBy: 'producto_nombre',
  ),
  foreignKeyColumn: 'idmovimiento',
  foreignKeyParentField: 'idmovimiento',
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
);

const InlineSectionConfig viajesIncidentesInlineSection = InlineSectionConfig(
  id: 'viajes_incidentes_detalle',
  title: 'Productos afectados por incidente',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_viajes_incidentes_detalle_vistageneral',
    orderBy: 'producto_nombre',
  ),
  foreignKeyColumn: 'idincidente',
  foreignKeyParentField: 'incidente_id',
  columns: [
    InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
    InlineSectionColumn(
      key: 'cantidad_movimiento',
      label: 'Cantidad enviada',
    ),
    InlineSectionColumn(key: 'cantidad', label: 'Cantidad incidente'),
  ],
  showInForm: false,
  showInDetail: true,
  enableCreate: false,
  enableView: false,
  emptyPlaceholder: 'Sin incidentes registrados para este movimiento.',
  formSectionId: 'viajes_incidentes_detalle',
  formForeignKeyField: 'idincidente',
  requiresPersistedParent: true,
);

Map<String, dynamic> viajesRowTransformer(Map<String, dynamic> row) {
  final transformed = Map<String, dynamic>.from(row);
  final estado = (row['estado_texto'] ?? '').toString().trim();
  transformed['estado_texto'] = estado.isEmpty ? 'Pendiente' : estado;
  transformed['estado_grupo'] = transformed['estado_texto'];
  transformed['nombre_motorizado'] =
      row['nombre_motorizado']?.toString() ?? 'Sin asignar';
  transformed['num_wsp'] = row['num_wsp']?.toString() ?? '';
  return transformed;
}
