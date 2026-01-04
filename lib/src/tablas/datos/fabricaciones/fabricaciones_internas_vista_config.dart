import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource fabricacionesInternasDataSource = SectionDataSource(
  sectionId: 'fabricaciones_internas',
  listSchema: 'public',
  listRelation: 'v_fabricaciones_internas_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'fabricaciones',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_fabricaciones_internas_vistageneral',
  detailIsView: true,
);

const SectionDataSource fabricacionesInternasConsumosDataSource =
    SectionDataSource(
      sectionId: 'fabricaciones_internas_consumos',
      listSchema: 'public',
      listRelation: 'v_fabricaciones_internas_consumos',
      listIsView: true,
      formSchema: 'public',
      formRelation: 'fabricaciones_consumos',
      formIsView: false,
      detailSchema: null,
      detailRelation: null,
      detailIsView: null,
    );

const SectionDataSource fabricacionesInternasResultadosDataSource =
    SectionDataSource(
      sectionId: 'fabricaciones_internas_resultados',
      listSchema: 'public',
      listRelation: 'v_fabricaciones_internas_resultados',
      listIsView: true,
      formSchema: 'public',
      formRelation: 'fabricaciones_resultados',
      formIsView: false,
      detailSchema: null,
      detailRelation: null,
      detailIsView: null,
    );

const List<TableColumnConfig> fabricacionesInternasColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Fecha'),
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'receta_nombre', label: 'Receta'),
  TableColumnConfig(key: 'consumos_registrados', label: 'Consumos'),
  TableColumnConfig(key: 'productos_registrados', label: 'Resultados'),
  TableColumnConfig(key: 'total_producido', label: 'Total fabricado'),
  TableColumnConfig(key: 'estado', label: 'Estado'),
];

const List<DetailFieldOverride> fabricacionesInternasCamposDetalle = [
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha de registro'),
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'receta_nombre', label: 'Receta'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
  DetailFieldOverride(key: 'total_consumido', label: 'Total consumido'),
  DetailFieldOverride(key: 'total_producido', label: 'Total fabricado'),
  DetailFieldOverride(key: 'total_valor', label: 'Valor total'),
  DetailFieldOverride(key: 'estado', label: 'Estado'),
];

const InlineSectionConfig fabricacionesInternasConsumosInlineSection =
    InlineSectionConfig(
      id: 'fabricaciones_internas_consumos',
      title: 'Insumos consumidos',
      dataSource: InlineSectionDataSource(
        schema: 'public',
        relation: 'v_fabricaciones_internas_consumos',
        orderBy: 'registrado_at',
      ),
      foreignKeyColumn: 'idfabricacion',
      columns: [
        InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
        InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
      ],
      showInForm: true,
      enableCreate: true,
      formSectionId: 'fabricaciones_internas_consumos',
      formForeignKeyField: 'idfabricacion',
      pendingFieldMapping: {
        'producto_nombre': 'idproducto',
        'cantidad': 'cantidad',
      },
    );

const InlineSectionConfig fabricacionesInternasResultadosInlineSection =
    InlineSectionConfig(
      id: 'fabricaciones_internas_resultados',
      title: 'Resultados de fabricación',
      dataSource: InlineSectionDataSource(
        schema: 'public',
        relation: 'v_fabricaciones_internas_resultados',
        orderBy: 'registrado_at',
      ),
      foreignKeyColumn: 'idfabricacion',
      columns: [
        InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
        InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
        InlineSectionColumn(key: 'costo_total', label: 'Costo total'),
      ],
      showInForm: true,
      enableCreate: true,
      formSectionId: 'fabricaciones_internas_resultados',
      formForeignKeyField: 'idfabricacion',
      pendingFieldMapping: {
        'producto_nombre': 'idproducto',
        'cantidad': 'cantidad',
      },
    );

const List<InlineSectionConfig> fabricacionesInternasInlineSections = [
  fabricacionesInternasConsumosInlineSection,
  fabricacionesInternasResultadosInlineSection,
];

Map<String, dynamic> fabricacionesInternasRowTransformer(
  Map<String, dynamic> row,
) {
  final formatted = Map<String, dynamic>.from(row);
  formatted['receta_nombre'] =
      (row['receta_nombre']?.toString().isNotEmpty ?? false)
          ? row['receta_nombre'].toString()
          : 'Sin receta';
  return formatted;
}
