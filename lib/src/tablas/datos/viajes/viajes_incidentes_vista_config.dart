import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:flutter/material.dart';

const SectionDataSource viajesIncidentesDataSource = SectionDataSource(
  sectionId: 'viajes_incidentes',
  listSchema: 'public',
  listRelation: 'v_viajes_incidentes_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'viajes_incidentes',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_viajes_incidentes_vistageneral',
  detailIsView: true,
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
  listLimit: 100,
);

const List<TableColumnConfig> viajesIncidentesColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Registrado'),
  TableColumnConfig(key: 'movimiento_codigo', label: 'Movimiento'),
  TableColumnConfig(key: 'cliente_nombre', label: 'Cliente'),
  TableColumnConfig(key: 'cliente_numero', label: 'Número cliente'),
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'nombre_motorizado', label: 'Motorizado'),
  TableColumnConfig(
    key: 'tipo',
    label: 'Tipo',
    textAlign: TextAlign.center,
  ),
  TableColumnConfig(
    key: 'productos_afectados',
    label: 'Productos',
    textAlign: TextAlign.end,
  ),
  TableColumnConfig(
    key: 'cantidad_afectada',
    label: 'Cantidad',
    textAlign: TextAlign.end,
  ),
];

const List<DetailFieldOverride> viajesIncidentesCamposDetalle = [
  DetailFieldOverride(key: 'movimiento_codigo', label: 'Movimiento'),
  DetailFieldOverride(key: 'cliente_nombre', label: 'Cliente'),
  DetailFieldOverride(key: 'cliente_numero', label: 'Número cliente'),
  DetailFieldOverride(key: 'base_nombre', label: 'Base origen'),
  DetailFieldOverride(key: 'contacto_display', label: 'Contacto'),
  DetailFieldOverride(key: 'direccion_display', label: 'Dirección'),
  DetailFieldOverride(key: 'nombre_motorizado', label: 'Motorizado'),
  DetailFieldOverride(key: 'tipo', label: 'Tipo'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
  DetailFieldOverride(
    key: 'productos_afectados',
    label: 'Productos afectados',
  ),
  DetailFieldOverride(
    key: 'cantidad_afectada',
    label: 'Cantidad afectada',
  ),
  DetailFieldOverride(
    key: 'pedido_registrado_at',
    label: 'Pedido registrado',
  ),
  DetailFieldOverride(
    key: 'registrado_at',
    label: 'Incidente registrado',
  ),
];

const InlineSectionConfig viajesIncidentesProductosInlineSection =
    InlineSectionConfig(
  id: 'viajes_incidentes_detalle_listado',
  title: 'Productos afectados',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_viajes_incidentes_detalle_vistageneral',
    orderBy: 'producto_nombre',
  ),
  foreignKeyColumn: 'idincidente',
  columns: [
    InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
    InlineSectionColumn(
      key: 'cantidad_movimiento',
      label: 'Cantidad enviada',
    ),
    InlineSectionColumn(key: 'cantidad', label: 'Cantidad incidente'),
  ],
  showInForm: true,
  showInDetail: true,
  enableCreate: false,
  enableView: false,
  formSectionId: 'viajes_incidentes_detalle',
  formForeignKeyField: 'idincidente',
  requiresPersistedParent: true,
  emptyPlaceholder: 'Sin productos afectados.',
);
