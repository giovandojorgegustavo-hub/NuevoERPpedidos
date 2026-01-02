import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';

const SectionDataSource comunicacionesBaseDataSource = SectionDataSource(
  sectionId: 'comunicaciones_base',
  listSchema: 'public',
  listRelation: 'v_comunicaciones_internas_bases',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'comunicaciones_internas',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_comunicaciones_internas_bases',
  detailIsView: true,
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
  listLimit: 150,
);

const SectionDataSource comunicacionesDataSource = SectionDataSource(
  sectionId: 'comunicaciones',
  listSchema: 'public',
  listRelation: 'v_comunicaciones_internas',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'comunicaciones_internas',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_comunicaciones_internas',
  detailIsView: true,
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
  listLimit: 150,
);

const List<TableColumnConfig> comunicacionesColumnas = [
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'asunto', label: 'Asunto'),
  TableColumnConfig(key: 'prioridad', label: 'Prioridad'),
  TableColumnConfig(key: 'estado', label: 'Estado'),
  TableColumnConfig(key: 'registrado_at', label: 'Registrado'),
];

const List<DetailFieldOverride> comunicacionesDetalleCampos = [
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'asunto', label: 'Asunto'),
  DetailFieldOverride(key: 'mensaje', label: 'Mensaje'),
  DetailFieldOverride(key: 'prioridad', label: 'Prioridad'),
  DetailFieldOverride(key: 'estado', label: 'Estado'),
  DetailFieldOverride(key: 'registrado_at', label: 'Registrado'),
];

Map<String, dynamic> comunicacionesRowTransformer(Map<String, dynamic> row) {
  final transformed = Map<String, dynamic>.from(row);
  final estado = (row['estado']?.toString() ?? '').trim().toLowerCase();
  if (estado.isEmpty) {
    transformed['estado'] = 'pendiente';
    return transformed;
  }
  if (estado == 'pendiente' || estado == 'finalizado') {
    return transformed;
  }
  transformed['estado'] = 'finalizado';
  return transformed;
}
