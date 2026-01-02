import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource comprasMovimientosDataSource = SectionDataSource(
  sectionId: 'compras_movimientos',
  listSchema: 'public',
  listRelation: 'v_compras_movimientos_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'compras_movimientos',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_compras_movimientos_vistageneral',
  detailIsView: true,
);

const SectionDataSource comprasMovimientosDetalleDataSource = SectionDataSource(
  sectionId: 'compras_movimiento_detalle',
  listSchema: 'public',
  listRelation: 'v_compras_movimiento_detalle_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'compras_movimiento_detalle',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<TableColumnConfig> comprasMovimientosColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Fecha'),
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'cantidad_total', label: 'Cantidad total'),
  TableColumnConfig(key: 'productos_registrados', label: 'Productos'),
  TableColumnConfig(key: 'costo_total', label: 'Costo total'),
];

const List<DetailFieldOverride> comprasMovimientosCamposDetalle = [
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha'),
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'cantidad_total', label: 'Cantidad total'),
  DetailFieldOverride(
    key: 'productos_registrados',
    label: 'Productos registrados',
  ),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
  DetailFieldOverride(key: 'costo_total', label: 'Costo total'),
  DetailFieldOverride(key: 'es_reversion', label: 'Movimiento inverso'),
];

const List<DetailFieldOverride> comprasMovimientosDetalleCamposDetalle = [
  DetailFieldOverride(key: 'producto_nombre', label: 'Producto'),
  DetailFieldOverride(key: 'cantidad', label: 'Cantidad'),
  DetailFieldOverride(key: 'costo_unitario', label: 'Costo unitario'),
  DetailFieldOverride(key: 'costo_total', label: 'Costo total'),
];

const InlineSectionConfig comprasMovimientosDetalleInlineSection =
    InlineSectionConfig(
      id: 'compras_movimiento_detalle',
      title: 'Detalle del ingreso',
      dataSource: InlineSectionDataSource(
        schema: 'public',
        relation: 'v_compras_movimiento_detalle_vistageneral',
        orderBy: 'producto_nombre',
      ),
      foreignKeyColumn: 'idmovimiento',
      columns: [
        InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
        InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
        InlineSectionColumn(key: 'costo_unitario', label: 'Costo unitario'),
        InlineSectionColumn(key: 'costo_total', label: 'Costo total'),
      ],
      showInForm: true,
      enableCreate: true,
      formSectionId: 'compras_movimiento_detalle',
      formForeignKeyField: 'idmovimiento',
      pendingFieldMapping: {
        'producto_nombre': 'idproducto',
        'cantidad': 'cantidad',
      },
    );
