import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource fabricacionesMenuDataSource = SectionDataSource(
  sectionId: 'fabricaciones',
  listSchema: 'public',
  listRelation: 'v_fabricaciones_tipos',
  listIsView: true,
  formSchema: '',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_fabricaciones_tipos',
  detailIsView: true,
);

const List<TableColumnConfig> fabricacionesMenuColumnas = [
  TableColumnConfig(key: 'nombre', label: 'Tipo de fabricación'),
  TableColumnConfig(key: 'descripcion', label: 'Descripción'),
];

const List<DetailFieldOverride> fabricacionesMenuCamposDetalle = [
  DetailFieldOverride(key: 'nombre', label: 'Tipo'),
  DetailFieldOverride(key: 'descripcion', label: 'Descripción'),
  DetailFieldOverride(key: 'section_id', label: 'Sección destino'),
];
