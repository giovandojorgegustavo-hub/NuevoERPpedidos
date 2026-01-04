import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource costosHistorialDataSource = SectionDataSource(
  sectionId: 'costos_historial',
  listSchema: 'public',
  listRelation: 'v_costos_historial',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_costos_historial',
  detailIsView: true,
);

const List<TableColumnConfig> costosHistorialColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Fecha'),
  TableColumnConfig(key: 'origen_tipo', label: 'Origen'),
  TableColumnConfig(key: 'origen_referencia', label: 'Referencia'),
  TableColumnConfig(key: 'accion', label: 'Acción'),
  TableColumnConfig(key: 'producto_nombre', label: 'Producto'),
  TableColumnConfig(key: 'cantidad', label: 'Cantidad'),
  TableColumnConfig(key: 'costo_unitario', label: 'Costo unitario'),
  TableColumnConfig(key: 'costo_total', label: 'Costo total'),
];

const List<DetailFieldOverride> costosHistorialCamposDetalle = [
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha'),
  DetailFieldOverride(key: 'origen_tipo', label: 'Origen'),
  DetailFieldOverride(key: 'origen_referencia', label: 'Referencia'),
  DetailFieldOverride(key: 'origen_id', label: 'ID de origen'),
  DetailFieldOverride(key: 'detalle_id', label: 'Detalle'),
  DetailFieldOverride(key: 'producto_nombre', label: 'Producto'),
  DetailFieldOverride(key: 'idproducto', label: 'Producto'),
  DetailFieldOverride(key: 'idbase', label: 'Base'),
  DetailFieldOverride(key: 'cantidad', label: 'Cantidad'),
  DetailFieldOverride(key: 'costo_unitario', label: 'Costo unitario'),
  DetailFieldOverride(key: 'costo_total', label: 'Costo total'),
  DetailFieldOverride(key: 'accion', label: 'Acción'),
];

Map<String, dynamic> costosHistorialRowTransformer(Map<String, dynamic> row) {
  final formatted = Map<String, dynamic>.from(row);
  final productoNombre = row['producto_nombre']?.toString() ?? '';
  formatted['producto_nombre'] = productoNombre.isNotEmpty
      ? productoNombre
      : row['idproducto']?.toString() ?? '-';
  return formatted;
}
