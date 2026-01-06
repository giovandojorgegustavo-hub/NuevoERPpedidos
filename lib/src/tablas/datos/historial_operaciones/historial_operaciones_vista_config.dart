import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource historialOperacionesDataSource = SectionDataSource(
  sectionId: 'historial_operaciones',
  listSchema: 'public',
  listRelation: 'v_kardex_operativo',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_kardex_operativo',
  detailIsView: true,
);

const List<TableColumnConfig> historialOperacionesColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Fecha de registro'),
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'origen_referencia', label: 'Referencia'),
  TableColumnConfig(key: 'producto_nombre', label: 'Producto'),
  TableColumnConfig(key: 'tipomov', label: 'Tipo de movimiento'),
  TableColumnConfig(key: 'cantidad', label: 'Cantidad'),
];

const List<DetailFieldOverride> historialOperacionesCamposDetalle = [
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha'),
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'origen_referencia', label: 'Referencia'),
  DetailFieldOverride(key: 'producto_nombre', label: 'Producto'),
  DetailFieldOverride(key: 'tipomov', label: 'Tipo de movimiento'),
  DetailFieldOverride(key: 'cantidad', label: 'Cantidad'),
  DetailFieldOverride(key: 'idoperativo', label: 'Origen operativo'),
];

Map<String, dynamic> historialOperacionesRowTransformer(
  Map<String, dynamic> row,
) {
  final formatted = Map<String, dynamic>.from(row);
  formatted['tipomov'] = _friendlyMovimiento(row['tipomov']);
  return formatted;
}

String _friendlyMovimiento(dynamic value) {
  final raw = (value?.toString() ?? '').toLowerCase();
  switch (raw) {
    case 'compra':
      return 'Compra';
    case 'movimiento':
      return 'Movimiento';
    case 'movimiento_rev':
      return 'Movimiento (revertido)';
    case 'ajuste':
      return 'Ajuste';
    case 'trans_origen':
      return 'Transferencia (salida)';
    case 'trans_destino':
      return 'Transferencia (entrada)';
    case 'fabr_consumo':
      return 'Consumo fabricación';
    case 'fabr_fabricado':
      return 'Producto fabricado';
    case 'fabr_consumo_rev':
      return 'Consumo fabricación (revertido)';
    case 'fabr_fabricado_rev':
      return 'Producto fabricado (revertido)';
    default:
      return raw.isEmpty ? '-' : raw;
  }
}
