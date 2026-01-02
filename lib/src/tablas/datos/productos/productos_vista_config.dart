import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource productosDataSource = SectionDataSource(
  sectionId: 'productos_form',
  listSchema: 'public',
  listRelation: 'productos',
  listIsView: false,
  formSchema: 'public',
  formRelation: 'productos',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const SectionDataSource productosCatalogoDataSource = SectionDataSource(
  sectionId: 'productos',
  listSchema: 'public',
  listRelation: 'v_productos_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'productos',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_productos_vistageneral',
  detailIsView: true,
);

const List<TableColumnConfig> productosColumnas = [
  TableColumnConfig(key: 'nombre', label: 'Producto'),
  TableColumnConfig(key: 'categoria_nombre', label: 'Categoría'),
  TableColumnConfig(key: 'activo_label', label: 'Activo'),
  TableColumnConfig(key: 'es_para_venta_label', label: 'Venta'),
  TableColumnConfig(key: 'es_para_compra_label', label: 'Compra'),
];

const List<DetailFieldOverride> productosCamposDetalle = [
  DetailFieldOverride(key: 'nombre', label: 'Producto'),
  DetailFieldOverride(key: 'categoria_nombre', label: 'Categoría'),
  DetailFieldOverride(key: 'activo_label', label: 'Activo'),
  DetailFieldOverride(key: 'es_para_venta_label', label: 'Venta'),
  DetailFieldOverride(key: 'es_para_compra_label', label: 'Compra'),
  DetailFieldOverride(key: 'registrado_at', label: 'Registrado el'),
  DetailFieldOverride(key: 'editado_at', label: 'Última edición'),
];

Map<String, dynamic> productosRowTransformer(Map<String, dynamic> row) {
  final formatted = Map<String, dynamic>.from(row);
  formatted['categoria_nombre'] =
      (row['categoria_nombre']?.toString().isNotEmpty ?? false)
      ? row['categoria_nombre'].toString()
      : 'Sin categoría';
  formatted['activo_label'] = _flagLabel(row['activo']);
  formatted['es_para_venta_label'] = _flagLabel(row['es_para_venta']);
  formatted['es_para_compra_label'] = _flagLabel(row['es_para_compra']);
  return formatted;
}

String _flagLabel(dynamic value) {
  if (value is bool) return value ? 'Sí' : 'No';
  if (value == null) return 'No';
  if (value is num) return value != 0 ? 'Sí' : 'No';
  final text = value.toString().toLowerCase();
  return text == 'true' ? 'Sí' : 'No';
}
