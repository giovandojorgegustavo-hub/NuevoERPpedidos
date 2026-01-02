import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource fabricacionesMaquilaDataSource = SectionDataSource(
  sectionId: 'fabricaciones_maquila',
  listSchema: 'public',
  listRelation: 'v_fabricaciones_maquila_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'fabricaciones_maquila',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_fabricaciones_maquila_vistageneral',
  detailIsView: true,
);

const SectionDataSource fabricacionesMaquilaConsumosDataSource =
    SectionDataSource(
      sectionId: 'fabricaciones_maquila_consumos',
      listSchema: 'public',
      listRelation: 'v_fabricaciones_maquila_consumos',
      listIsView: true,
      formSchema: 'public',
      formRelation: 'fabricaciones_maquila_consumos',
      formIsView: false,
      detailSchema: null,
      detailRelation: null,
      detailIsView: null,
    );

const SectionDataSource fabricacionesMaquilaResultadosDataSource =
    SectionDataSource(
      sectionId: 'fabricaciones_maquila_resultados',
      listSchema: 'public',
      listRelation: 'v_fabricaciones_maquila_resultados',
      listIsView: true,
      formSchema: 'public',
      formRelation: 'fabricaciones_maquila_resultados',
      formIsView: false,
      detailSchema: null,
      detailRelation: null,
      detailIsView: null,
    );

const SectionDataSource fabricacionesMaquilaCostosDataSource =
    SectionDataSource(
      sectionId: 'fabricaciones_maquila_costos',
      listSchema: 'public',
      listRelation: 'v_fabricaciones_maquila_costos',
      listIsView: true,
      formSchema: 'public',
      formRelation: 'fabricaciones_maquila_costos',
      formIsView: false,
      detailSchema: null,
      detailRelation: null,
      detailIsView: null,
    );

const List<TableColumnConfig> fabricacionesMaquilaColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Fecha'),
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'proveedor_nombre', label: 'Proveedor'),
  TableColumnConfig(key: 'productos_registrados', label: 'Resultados'),
  TableColumnConfig(key: 'total_costos', label: 'Costos asociados'),
  TableColumnConfig(key: 'estado', label: 'Estado'),
];

const List<DetailFieldOverride> fabricacionesMaquilaCamposDetalle = [
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha de registro'),
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'proveedor_nombre', label: 'Proveedor'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
  DetailFieldOverride(key: 'total_consumido', label: 'Total consumido'),
  DetailFieldOverride(key: 'total_producido', label: 'Total devuelto'),
  DetailFieldOverride(key: 'total_valor', label: 'Valor productos'),
  DetailFieldOverride(key: 'total_costos', label: 'Costos adicionales'),
  DetailFieldOverride(key: 'estado', label: 'Estado'),
];

const InlineSectionConfig fabricacionesMaquilaConsumosInlineSection =
    InlineSectionConfig(
      id: 'fabricaciones_maquila_consumos',
      title: 'Material entregado',
      dataSource: InlineSectionDataSource(
        schema: 'public',
        relation: 'v_fabricaciones_maquila_consumos',
        orderBy: 'registrado_at',
      ),
      foreignKeyColumn: 'idfabricacion',
      columns: [
        InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
        InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
      ],
      showInForm: true,
      enableCreate: true,
      formSectionId: 'fabricaciones_maquila_consumos',
      formForeignKeyField: 'idfabricacion',
      pendingFieldMapping: {
        'producto_nombre': 'idproducto',
        'cantidad': 'cantidad',
      },
    );

const InlineSectionConfig fabricacionesMaquilaResultadosInlineSection =
    InlineSectionConfig(
      id: 'fabricaciones_maquila_resultados',
      title: 'Material recibido',
      dataSource: InlineSectionDataSource(
        schema: 'public',
        relation: 'v_fabricaciones_maquila_resultados',
        orderBy: 'registrado_at',
      ),
      foreignKeyColumn: 'idfabricacion',
      columns: [
        InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
        InlineSectionColumn(key: 'tipo_resultado', label: 'Tipo'),
        InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
        InlineSectionColumn(key: 'costo_total', label: 'Costo total'),
      ],
      showInForm: true,
      requiresPersistedParent: true,
      enableCreate: true,
      formSectionId: 'fabricaciones_maquila_resultados',
      formForeignKeyField: 'idfabricacion',
      pendingFieldMapping: {
        'producto_nombre': 'idproducto',
        'tipo_resultado': 'tipo_resultado',
        'cantidad': 'cantidad',
        'costo_total': 'costo_total',
      },
    );

const InlineSectionConfig fabricacionesMaquilaCostosInlineSection =
    InlineSectionConfig(
      id: 'fabricaciones_maquila_costos',
      title: 'Costos adicionales',
      dataSource: InlineSectionDataSource(
        schema: 'public',
        relation: 'v_fabricaciones_maquila_costos',
        orderBy: 'registrado_at',
      ),
      foreignKeyColumn: 'idfabricacion',
      columns: [
        InlineSectionColumn(key: 'concepto', label: 'Concepto'),
        InlineSectionColumn(key: 'monto', label: 'Monto'),
        InlineSectionColumn(key: 'cuenta_nombre', label: 'Cuenta bancaria'),
      ],
      showInForm: true,
      enableCreate: true,
      formSectionId: 'fabricaciones_maquila_costos',
      formForeignKeyField: 'idfabricacion',
      pendingFieldMapping: {
        'concepto': 'concepto',
        'monto': 'monto',
        'cuenta_nombre': 'idcuenta',
      },
    );

const List<InlineSectionConfig> fabricacionesMaquilaInlineSections = [
  fabricacionesMaquilaConsumosInlineSection,
  fabricacionesMaquilaCostosInlineSection,
  fabricacionesMaquilaResultadosInlineSection,
];

Map<String, dynamic> fabricacionesMaquilaRowTransformer(
  Map<String, dynamic> row,
) {
  return Map<String, dynamic>.from(row);
}
