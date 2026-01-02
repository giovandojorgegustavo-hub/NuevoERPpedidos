import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';

const SectionDataSource usuariosDataSource = SectionDataSource(
  sectionId: 'usuarios',
  listSchema: 'public',
  listRelation: 'v_perfiles_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'perfiles',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<TableColumnConfig> usuariosColumnas = [
  TableColumnConfig(key: 'nombre', label: 'Usuario'),
  TableColumnConfig(key: 'rol', label: 'Rol'),
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
];

const List<DetailFieldOverride> usuariosCamposDetalle = [
  DetailFieldOverride(key: 'user_id', label: 'Correo / ID'),
  DetailFieldOverride(key: 'nombre', label: 'Nombre'),
  DetailFieldOverride(key: 'rol', label: 'Rol'),
  DetailFieldOverride(key: 'base_nombre', label: 'Base asignada'),
];

Map<String, dynamic> usuariosRowTransformer(Map<String, dynamic> row) {
  final transformed = Map<String, dynamic>.from(row);
  final rol = row['rol']?.toString() ?? '';
  transformed['rol'] = rol.toUpperCase();
  transformed['base_nombre'] = row['base_nombre']?.toString().isEmpty ?? true
      ? 'Sin asignar'
      : row['base_nombre'];
  return transformed;
}
