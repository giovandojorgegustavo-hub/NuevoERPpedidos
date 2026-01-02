import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource cuentasBancariasAsignadasDataSource = SectionDataSource(
  sectionId: 'cuentas_bancarias_asignadas',
  listSchema: 'public',
  listRelation: 'v_cuentas_bancarias_asignadas',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'cuentas_bancarias_asignadas',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_cuentas_bancarias_asignadas',
  detailIsView: true,
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
);

const List<TableColumnConfig> cuentasBancariasAsignadasColumnas = [
  TableColumnConfig(key: 'usuario_nombre', label: 'Gerente'),
  TableColumnConfig(key: 'cuenta_nombre', label: 'Cuenta'),
  TableColumnConfig(key: 'cuenta_banco', label: 'Banco'),
  TableColumnConfig(key: 'activo', label: 'Activo'),
];

const List<DetailFieldOverride> cuentasBancariasAsignadasDetalle = [
  DetailFieldOverride(key: 'usuario_nombre', label: 'Gerente'),
  DetailFieldOverride(key: 'usuario_rol', label: 'Rol'),
  DetailFieldOverride(key: 'cuenta_nombre', label: 'Cuenta'),
  DetailFieldOverride(key: 'cuenta_banco', label: 'Banco'),
  DetailFieldOverride(key: 'activo', label: 'Activo'),
  DetailFieldOverride(key: 'registrado_at', label: 'Registrado'),
];
