import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:flutter/material.dart';

const SectionDataSource pedidosDataSource = SectionDataSource(
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
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
  listLimit: 80,
);

const List<TableColumnConfig> pedidosColumnas = [
  TableColumnConfig(key: 'codigo', label: 'Código'),
  TableColumnConfig(key: 'registrado_at', label: 'Fecha de registro'),
  TableColumnConfig(key: 'cliente_nombre', label: 'Cliente'),
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

const List<DetailFieldOverride> pedidosCamposDetalle = [
  DetailFieldOverride(key: 'codigo', label: 'Código'),
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha de registro'),
  DetailFieldOverride(key: 'cliente_nombre', label: 'Cliente'),
  DetailFieldOverride(key: 'cliente_numero', label: 'Número de cliente'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
];

const List<InlineSectionConfig> pedidosInlineSections = [
  InlineSectionConfig(
    id: 'pedidos_detalle',
    title: 'Detalle del pedido',
    dataSource: InlineSectionDataSource(
      schema: 'public',
      relation: 'v_detallepedidos_vistageneral',
      orderBy: 'registrado_at',
    ),
    foreignKeyColumn: 'idpedido',
    columns: [
      InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
      InlineSectionColumn(key: 'cantidad', label: 'Cantidad'),
      InlineSectionColumn(key: 'precioventa', label: 'Precio total'),
    ],
    showInForm: true,
    enableCreate: true,
    formSectionId: 'pedidos_detalle',
    formForeignKeyField: 'idpedido',
    pendingFieldMapping: {
      'producto_nombre': 'idproducto',
      'cantidad': 'cantidad',
      'precioventa': 'precioventa',
    },
  ),
  InlineSectionConfig(
    id: 'pedidos_pagos',
    title: 'Pagos registrados',
    dataSource: InlineSectionDataSource(
      schema: 'public',
      relation: 'v_pagos_vistageneral',
      orderBy: 'fechapago',
    ),
    foreignKeyColumn: 'idpedido',
    columns: [
      InlineSectionColumn(key: 'codigo', label: 'Código'),
      InlineSectionColumn(key: 'fechapago', label: 'Fecha'),
      InlineSectionColumn(key: 'cuenta_nombre', label: 'Cuenta'),
      InlineSectionColumn(key: 'monto', label: 'Monto'),
    ],
    emptyPlaceholder: 'Sin pagos registrados.',
    showInForm: true,
    enableCreate: true,
    formSectionId: 'pedidos_pagos',
    formForeignKeyField: 'idpedido',
    pendingFieldMapping: {
      'fechapago': 'fechapago',
      'cuenta_nombre': 'idcuenta',
      'monto': 'monto',
    },
  ),
  InlineSectionConfig(
    id: 'pedidos_movimientos',
    title: 'Movimientos asociados',
    dataSource: InlineSectionDataSource(
      schema: 'public',
      relation: 'v_movimiento_resumen',
      orderBy: 'fecharegistro',
    ),
    foreignKeyColumn: 'idpedido',
    columns: [
      InlineSectionColumn(key: 'codigo', label: 'Movimiento'),
      InlineSectionColumn(key: 'base_nombre', label: 'Base'),
      InlineSectionColumn(key: 'direccion_display', label: 'Dirección'),
      InlineSectionColumn(key: 'referencia_display', label: 'Referencia'),
      InlineSectionColumn(
        key: 'contacto_numero_display',
        label: 'Número / DNI',
      ),
      InlineSectionColumn(
        key: 'contacto_nombre_display',
        label: 'Nombre que recibe',
      ),
    ],
    emptyPlaceholder: 'Sin movimientos generados.',
    showInForm: true,
    enableCreate: true,
    formSectionId: 'pedidos_movimientos',
    formForeignKeyField: 'idpedido',
    pendingFieldMapping: {
      'base_nombre': 'idbase',
      'estado_texto': 'es_provincia',
      'observacion': 'observacion',
    },
    rowTapSectionId: 'movimientos',
    formTitle: 'Movimiento',
  ),
];

Map<String, dynamic> pedidosTransformer(Map<String, dynamic> row) {
  return Map<String, dynamic>.from(row);
}
