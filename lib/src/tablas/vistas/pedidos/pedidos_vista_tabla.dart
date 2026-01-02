import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:flutter/material.dart';

/// DataSource reutilizado por la vista de tabla y formulario.
const SectionDataSource pedidosVistaTablaDataSource = SectionDataSource(
  sectionId: 'pedidos_tabla',
  listSchema: 'public',
  listRelation: 'v_pedido_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'pedidos',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<TableColumnConfig> pedidosVistaTablaColumns = [
  TableColumnConfig(
    key: 'registrado_at',
    label: 'Fecha de registro',
  ),
  TableColumnConfig(
    key: 'cliente_nombre',
    label: 'Cliente',
  ),
  TableColumnConfig(
    key: 'estado_pago',
    label: 'Estado de pago',
    textAlign: TextAlign.center,
  ),
  TableColumnConfig(
    key: 'estado_entrega',
    label: 'Estado de entrega',
    textAlign: TextAlign.center,
  ),
  TableColumnConfig(
    key: 'estado_general',
    label: 'Estado general',
    textAlign: TextAlign.center,
  ),
];

const List<DetailFieldOverride> pedidosVistaTablaDetailFields = [
  DetailFieldOverride(
    key: 'registrado_at',
    label: 'Fecha de registro',
  ),
  DetailFieldOverride(
    key: 'cliente_nombre',
    label: 'Cliente',
  ),
  DetailFieldOverride(
    key: 'cliente_numero',
    label: 'Número de cliente',
  ),
  DetailFieldOverride(
    key: 'observacion',
    label: 'Observación',
  ),
];

Map<String, dynamic> pedidosVistaTablaRowTransformer(
    Map<String, dynamic> row) {
  return Map<String, dynamic>.from(row);
}

String? pedidosVistaTablaSubtitleBuilder(Map<String, dynamic> row) => '';
