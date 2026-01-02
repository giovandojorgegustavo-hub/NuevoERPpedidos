import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource asistenciasSlotsDataSource = SectionDataSource(
  sectionId: 'asistencias_slots',
  listSchema: 'public',
  listRelation: 'v_asistencias_slots',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'asistencias_slots',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_asistencias_slots',
  detailIsView: true,
  listOrderBy: 'hora',
);

const SectionDataSource asistenciasBaseSlotsDataSource = SectionDataSource(
  sectionId: 'asistencias_base_slots',
  listSchema: 'public',
  listRelation: 'v_asistencias_base_slots',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'asistencias_base_slots',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_asistencias_base_slots',
  detailIsView: true,
  listOrderBy: 'base_nombre',
);

const SectionDataSource asistenciasPendientesDataSource = SectionDataSource(
  sectionId: 'asistencias_pendientes',
  listSchema: 'public',
  listRelation: 'v_asistencias_pendientes',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'asistencias_registro',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_asistencias_pendientes',
  detailIsView: true,
  listOrderBy: 'slot_hora',
  listOrderAscending: true,
);

const SectionDataSource asistenciasPermisosDataSource = SectionDataSource(
  sectionId: 'asistencias_permisos',
  listSchema: 'public',
  listRelation: 'v_asistencias_permisos',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'asistencias_excepciones',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_asistencias_permisos',
  detailIsView: true,
  listOrderBy: 'fecha',
  listOrderAscending: true,
);

const SectionDataSource asistenciasHistorialDataSource = SectionDataSource(
  sectionId: 'asistencias_historial',
  listSchema: 'public',
  listRelation: 'v_asistencias_historial',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_asistencias_historial',
  detailIsView: true,
  listOrderBy: 'fecha',
  listOrderAscending: false,
);

const List<TableColumnConfig> asistenciasSlotsColumnas = [
  TableColumnConfig(key: 'nombre', label: 'Nombre'),
  TableColumnConfig(key: 'hora', label: 'Hora'),
  TableColumnConfig(key: 'descripcion', label: 'Descripcion'),
  TableColumnConfig(key: 'activo', label: 'Activo'),
];

const List<TableColumnConfig> asistenciasBaseSlotsColumnas = [
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'dia_semana', label: 'Dia'),
  TableColumnConfig(key: 'slot_hora', label: 'Hora'),
  TableColumnConfig(key: 'slot_nombre', label: 'Slot'),
  TableColumnConfig(key: 'activo', label: 'Activo'),
];

const List<TableColumnConfig> asistenciasPendientesColumnas = [
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'dia_semana', label: 'Dia'),
  TableColumnConfig(key: 'fecha', label: 'Fecha'),
  TableColumnConfig(key: 'slot_nombre', label: 'Slot'),
  TableColumnConfig(key: 'slot_hora', label: 'Hora'),
  TableColumnConfig(key: 'estado', label: 'Estado'),
  TableColumnConfig(key: 'observacion', label: 'Observacion'),
];

const List<TableColumnConfig> asistenciasPermisosColumnas = [
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'tipo', label: 'Tipo'),
  TableColumnConfig(key: 'fecha', label: 'Fecha'),
  TableColumnConfig(key: 'dia_semana', label: 'Dia'),
  TableColumnConfig(key: 'slot_nombre', label: 'Slot'),
  TableColumnConfig(key: 'slot_hora', label: 'Hora'),
  TableColumnConfig(key: 'motivo', label: 'Motivo'),
  TableColumnConfig(key: 'activo', label: 'Activo'),
];

const List<TableColumnConfig> asistenciasHistorialColumnas = [
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'fecha', label: 'Fecha'),
  TableColumnConfig(key: 'slot_hora', label: 'Hora'),
  TableColumnConfig(key: 'estado', label: 'Estado'),
  TableColumnConfig(key: 'observacion', label: 'Observacion'),
];

const List<DetailFieldOverride> asistenciasSlotsCamposDetalle = [
  DetailFieldOverride(key: 'nombre', label: 'Nombre'),
  DetailFieldOverride(key: 'hora', label: 'Hora'),
  DetailFieldOverride(key: 'descripcion', label: 'Descripcion'),
  DetailFieldOverride(key: 'activo', label: 'Activo'),
];

const List<DetailFieldOverride> asistenciasBaseSlotsCamposDetalle = [
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'dia_semana', label: 'Dia'),
  DetailFieldOverride(key: 'slot_nombre', label: 'Slot'),
  DetailFieldOverride(key: 'slot_hora', label: 'Hora'),
  DetailFieldOverride(key: 'activo', label: 'Activo'),
];

const List<DetailFieldOverride> asistenciasRegistroCamposDetalle = [
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'dia_semana', label: 'Dia'),
  DetailFieldOverride(key: 'slot_nombre', label: 'Slot'),
  DetailFieldOverride(key: 'slot_hora', label: 'Hora'),
  DetailFieldOverride(key: 'fecha', label: 'Fecha'),
  DetailFieldOverride(key: 'estado', label: 'Estado'),
  DetailFieldOverride(key: 'observacion', label: 'Observacion'),
];

const List<DetailFieldOverride> asistenciasExcepcionesCamposDetalle = [
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'slot_nombre', label: 'Slot'),
  DetailFieldOverride(key: 'slot_hora', label: 'Hora'),
  DetailFieldOverride(key: 'tipo', label: 'Tipo'),
  DetailFieldOverride(key: 'fecha', label: 'Fecha'),
  DetailFieldOverride(key: 'dia_semana', label: 'Dia'),
  DetailFieldOverride(key: 'motivo', label: 'Motivo'),
  DetailFieldOverride(key: 'activo', label: 'Activo'),
];
