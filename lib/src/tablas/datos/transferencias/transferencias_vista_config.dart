import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource transferenciasDataSource = SectionDataSource(
  sectionId: 'transferencias',
  listSchema: 'public',
  listRelation: 'v_transferencias_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'transferencias',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_transferencias_vistageneral',
  detailIsView: true,
);

const SectionDataSource transferenciasDetalleDataSource = SectionDataSource(
  sectionId: 'transferencias_detalle',
  listSchema: 'public',
  listRelation: 'v_transferencias_detalle_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'transferencias_detalle',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<TableColumnConfig> transferenciasColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Fecha'),
  TableColumnConfig(key: 'base_origen_nombre', label: 'Base origen'),
  TableColumnConfig(key: 'base_destino_nombre', label: 'Base destino'),
  TableColumnConfig(key: 'productos_registrados', label: 'Productos'),
  TableColumnConfig(key: 'total_cantidad', label: 'Cantidad total'),
];

const List<DetailFieldOverride> transferenciasCamposDetalle = [
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha'),
  DetailFieldOverride(key: 'base_origen_nombre', label: 'Base origen'),
  DetailFieldOverride(key: 'base_destino_nombre', label: 'Base destino'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
  DetailFieldOverride(key: 'productos_registrados', label: 'Productos'),
  DetailFieldOverride(key: 'total_cantidad', label: 'Cantidad total'),
];

const List<DetailFieldOverride> transferenciasDetalleCamposDetalle = [
  DetailFieldOverride(key: 'producto_nombre', label: 'Producto'),
  DetailFieldOverride(key: 'cantidad', label: 'Cantidad'),
  DetailFieldOverride(key: 'base_origen_nombre', label: 'Base origen'),
  DetailFieldOverride(key: 'base_destino_nombre', label: 'Base destino'),
];

const InlineSectionConfig transferenciasDetalleInlineSection =
    InlineSectionConfig(
      id: 'transferencias_detalle',
      title: 'Detalle de productos',
      dataSource: InlineSectionDataSource(
        schema: 'public',
        relation: 'v_transferencias_detalle_vistageneral',
        orderBy: 'producto_nombre',
      ),
      foreignKeyColumn: 'idtransferencia',
      columns: [
        InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
        InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
      ],
      showInForm: true,
      enableCreate: true,
      formSectionId: 'transferencias_detalle',
      formForeignKeyField: 'idtransferencia',
      pendingFieldMapping: {
        'producto_nombre': 'idproducto',
        'cantidad': 'cantidad',
      },
    );

const List<InlineSectionConfig> transferenciasInlineSections = [
  transferenciasDetalleInlineSection,
];

Map<String, dynamic> transferenciasRowTransformer(Map<String, dynamic> row) {
  return Map<String, dynamic>.from(row);
}
