import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource recetasDataSource = SectionDataSource(
  sectionId: 'recetas',
  listSchema: 'public',
  listRelation: 'v_recetas_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'recetas',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_recetas_vistageneral',
  detailIsView: true,
);

const SectionDataSource recetasInsumosDataSource = SectionDataSource(
  sectionId: 'recetas_insumos',
  listSchema: 'public',
  listRelation: 'v_recetas_insumos_detalle',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'recetas_insumos',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const SectionDataSource recetasResultadosDataSource = SectionDataSource(
  sectionId: 'recetas_resultados',
  listSchema: 'public',
  listRelation: 'v_recetas_resultados_detalle',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'recetas_resultados',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<TableColumnConfig> recetasColumnas = [
  TableColumnConfig(key: 'nombre', label: 'Receta'),
  TableColumnConfig(key: 'activo_label', label: 'Activo'),
  TableColumnConfig(key: 'insumos_registrados', label: 'Insumos'),
  TableColumnConfig(key: 'resultados_registrados', label: 'Resultados'),
];

const List<DetailFieldOverride> recetasCamposDetalle = [
  DetailFieldOverride(key: 'nombre', label: 'Receta'),
  DetailFieldOverride(key: 'activo_label', label: 'Activo'),
  DetailFieldOverride(key: 'notas', label: 'Notas'),
  DetailFieldOverride(
    key: 'insumos_registrados',
    label: 'Insumos registrados',
  ),
  DetailFieldOverride(
    key: 'resultados_registrados',
    label: 'Resultados registrados',
  ),
  DetailFieldOverride(key: 'registrado_at', label: 'Registrado el'),
];

const InlineSectionConfig recetasInsumosInlineSection = InlineSectionConfig(
  id: 'recetas_insumos',
  title: 'Insumos',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_recetas_insumos_detalle',
    orderBy: 'registrado_at',
  ),
  foreignKeyColumn: 'idreceta',
  columns: [
    InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
    InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
  ],
  showInForm: true,
  enableCreate: true,
  formSectionId: 'recetas_insumos',
  formForeignKeyField: 'idreceta',
  pendingFieldMapping: {
    'producto_nombre': 'idproducto',
    'cantidad': 'cantidad',
  },
);

const InlineSectionConfig recetasResultadosInlineSection = InlineSectionConfig(
  id: 'recetas_resultados',
  title: 'Resultados',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_recetas_resultados_detalle',
    orderBy: 'registrado_at',
  ),
  foreignKeyColumn: 'idreceta',
  columns: [
    InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
    InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
  ],
  showInForm: true,
  enableCreate: true,
  formSectionId: 'recetas_resultados',
  formForeignKeyField: 'idreceta',
  pendingFieldMapping: {
    'producto_nombre': 'idproducto',
    'cantidad': 'cantidad',
  },
);

const List<InlineSectionConfig> recetasInlineSections = [
  recetasInsumosInlineSection,
  recetasResultadosInlineSection,
];

Map<String, dynamic> recetasRowTransformer(Map<String, dynamic> row) {
  final formatted = Map<String, dynamic>.from(row);
  formatted['activo_label'] = (row['activo'] == true) ? 'Sí' : 'No';
  return formatted;
}
