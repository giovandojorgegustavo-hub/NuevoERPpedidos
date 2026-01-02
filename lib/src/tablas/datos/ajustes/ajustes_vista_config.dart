import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource ajustesDataSource = SectionDataSource(
  sectionId: 'ajustes',
  listSchema: 'public',
  listRelation: 'v_ajustes_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'ajustes',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_ajustes_vistageneral',
  detailIsView: true,
);

const SectionDataSource ajustesDetalleDataSource = SectionDataSource(
  sectionId: 'ajustes_detalle',
  listSchema: 'public',
  listRelation: 'v_ajustes_detalle_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'ajustes_detalle',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<TableColumnConfig> ajustesColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Fecha'),
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'productos_registrados', label: 'Productos'),
  TableColumnConfig(key: 'productos_pendientes', label: 'Pendientes'),
  TableColumnConfig(key: 'diferencia_total', label: 'Diferencia total'),
];

const List<DetailFieldOverride> ajustesCamposDetalle = [
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha de registro'),
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
  DetailFieldOverride(key: 'productos_registrados', label: 'Productos'),
  DetailFieldOverride(key: 'productos_pendientes', label: 'Pendientes'),
  DetailFieldOverride(key: 'productos_conteo', label: 'Registrados'),
  DetailFieldOverride(key: 'diferencia_total', label: 'Diferencia total'),
];

const List<DetailFieldOverride> ajustesDetalleCamposDetalle = [
  DetailFieldOverride(key: 'producto_nombre', label: 'Producto'),
  DetailFieldOverride(key: 'cantidad_sistema', label: 'Inventario sistema'),
  DetailFieldOverride(key: 'cantidad_real', label: 'Inventario real'),
  DetailFieldOverride(key: 'diferencia', label: 'Diferencia'),
];

const InlineSectionConfig ajustesDetalleInlineSection = InlineSectionConfig(
  id: 'ajustes_detalle',
  title: 'Productos ajustados',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_ajustes_detalle_vistageneral',
    orderBy: 'producto_nombre',
  ),
  foreignKeyColumn: 'idajuste',
  columns: [
    InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
    InlineSectionColumn(key: 'cantidad_sistema', label: 'Sistema'),
    InlineSectionColumn(key: 'cantidad_real', label: 'Inventario real'),
    InlineSectionColumn(key: 'diferencia', label: 'Diferencia'),
  ],
  showInForm: true,
  enableCreate: true,
  formSectionId: 'ajustes_detalle',
  formForeignKeyField: 'idajuste',
  pendingFieldMapping: {
    'producto_nombre': 'idproducto',
    'cantidad_sistema': 'cantidad_sistema',
    'cantidad_real': 'cantidad_real',
    'diferencia': 'cantidad',
  },
);

const List<InlineSectionConfig> ajustesInlineSections = [
  ajustesDetalleInlineSection,
];

Map<String, dynamic> ajustesRowTransformer(Map<String, dynamic> row) {
  return Map<String, dynamic>.from(row);
}
