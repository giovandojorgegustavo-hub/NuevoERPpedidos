import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:flutter/material.dart';

const SectionDataSource finanzasMovimientosDataSource = SectionDataSource(
  sectionId: 'finanzas_movimientos',
  listSchema: 'public',
  listRelation: 'v_movimientos_financieros_historial',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'movimientos_financieros',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_movimientos_financieros_historial',
  detailIsView: true,
);

const SectionDataSource finanzasGastosDataSource = SectionDataSource(
  sectionId: 'finanzas_gastos',
  listSchema: 'public',
  listRelation: 'v_finanzas_gastos_pedidos',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'gastos_operativos',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_finanzas_gastos_pedidos',
  detailIsView: true,
);

const SectionDataSource finanzasHistorialDataSource = SectionDataSource(
  sectionId: 'finanzas_historial',
  listSchema: 'public',
  listRelation: 'v_finanzas_historial_cuentas',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_finanzas_historial_cuentas',
  detailIsView: true,
);

const SectionDataSource finanzasSaldosDataSource = SectionDataSource(
  sectionId: 'finanzas_saldos',
  listSchema: 'public',
  listRelation: 'v_finanzas_saldo_cuentas',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_finanzas_saldo_cuentas',
  detailIsView: true,
);

const SectionDataSource finanzasCuentasDataSource = SectionDataSource(
  sectionId: 'finanzas_cuentas',
  listSchema: 'public',
  listRelation: 'v_cuentas_bancarias_visibles',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'cuentas_bancarias',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_cuentas_bancarias_visibles',
  detailIsView: true,
);

const List<TableColumnConfig> finanzasMovimientosColumnas = [
  TableColumnConfig(key: 'registrado_display', label: 'Fecha'),
  TableColumnConfig(key: 'cuenta_contable_tipo', label: 'Tipo'),
  TableColumnConfig(key: 'cuenta_contable_codigo', label: 'Código'),
  TableColumnConfig(key: 'cuenta_contable_nombre', label: 'Cuenta contable'),
  TableColumnConfig(
    key: 'monto_debe',
    label: 'Debe',
    textAlign: TextAlign.right,
  ),
  TableColumnConfig(
    key: 'monto_haber',
    label: 'Haber',
    textAlign: TextAlign.right,
  ),
  TableColumnConfig(key: 'descripcion', label: 'Descripción'),
];

const List<DetailFieldOverride> finanzasMovimientosDetalle = [
  DetailFieldOverride(key: 'tipo', label: 'Tipo'),
  DetailFieldOverride(key: 'descripcion', label: 'Descripción'),
  DetailFieldOverride(key: 'monto', label: 'Monto registrado'),
  DetailFieldOverride(key: 'cuenta_origen_nombre', label: 'Cuenta origen'),
  DetailFieldOverride(key: 'cuenta_destino_nombre', label: 'Cuenta destino'),
  DetailFieldOverride(key: 'cuenta_contable_nombre', label: 'Cuenta contable'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
  DetailFieldOverride(key: 'registrado_display', label: 'Registrado el'),
];

const List<TableColumnConfig> finanzasGastosColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Fecha'),
  TableColumnConfig(key: 'cliente_nombre', label: 'Cliente'),
  TableColumnConfig(key: 'descripcion', label: 'Descripción'),
  TableColumnConfig(key: 'monto', label: 'Monto', textAlign: TextAlign.right),
  TableColumnConfig(key: 'cuenta_nombre', label: 'Cuenta bancaria'),
  TableColumnConfig(key: 'cuenta_contable_codigo', label: 'Cuenta contable'),
];

const List<DetailFieldOverride> finanzasGastosDetalle = [
  DetailFieldOverride(key: 'tipo', label: 'Tipo'),
  DetailFieldOverride(key: 'cliente_nombre', label: 'Cliente'),
  DetailFieldOverride(key: 'descripcion', label: 'Descripción'),
  DetailFieldOverride(key: 'monto', label: 'Monto'),
  DetailFieldOverride(key: 'cuenta_nombre', label: 'Cuenta bancaria'),
  DetailFieldOverride(key: 'cuenta_contable_nombre', label: 'Cuenta contable'),
  DetailFieldOverride(key: 'pedido_registrado_at', label: 'Fecha del pedido'),
];

const List<TableColumnConfig> finanzasHistorialColumnas = [
  TableColumnConfig(key: 'registrado_at', label: 'Fecha'),
  TableColumnConfig(key: 'cuenta_nombre', label: 'Cuenta'),
  TableColumnConfig(key: 'descripcion', label: 'Descripción'),
  TableColumnConfig(key: 'monto', label: 'Monto', textAlign: TextAlign.right),
  TableColumnConfig(key: 'sentido', label: 'Sentido'),
];

const List<DetailFieldOverride> finanzasHistorialDetalle = [
  DetailFieldOverride(key: 'origen', label: 'Origen'),
  DetailFieldOverride(key: 'descripcion', label: 'Descripción'),
  DetailFieldOverride(key: 'monto', label: 'Monto'),
  DetailFieldOverride(key: 'sentido', label: 'Sentido'),
  DetailFieldOverride(key: 'cuenta_contable_nombre', label: 'Cuenta contable'),
  DetailFieldOverride(key: 'contracuenta_nombre', label: 'Contracuenta'),
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha de registro'),
];

const List<TableColumnConfig> finanzasSaldosColumnas = [
  TableColumnConfig(key: 'cuenta_nombre', label: 'Cuenta'),
  TableColumnConfig(key: 'cuenta_banco', label: 'Banco'),
  TableColumnConfig(key: 'saldo', label: 'Saldo', textAlign: TextAlign.right),
  TableColumnConfig(key: 'ultimo_movimiento_at', label: 'Último movimiento'),
  TableColumnConfig(key: 'activa', label: 'Activa'),
];

const List<DetailFieldOverride> finanzasSaldosDetalle = [
  DetailFieldOverride(key: 'cuenta_nombre', label: 'Cuenta'),
  DetailFieldOverride(key: 'cuenta_banco', label: 'Banco'),
  DetailFieldOverride(key: 'saldo', label: 'Saldo actual'),
  DetailFieldOverride(key: 'ultimo_movimiento_at', label: 'Último movimiento'),
  DetailFieldOverride(key: 'activa', label: 'Activa'),
];

const List<TableColumnConfig> finanzasCuentasColumnas = [
  TableColumnConfig(key: 'nombre', label: 'Cuenta bancaria'),
  TableColumnConfig(key: 'banco', label: 'Banco'),
  TableColumnConfig(key: 'cuenta_contable_codigo', label: 'Cuenta contable'),
  TableColumnConfig(key: 'activa', label: 'Activa'),
  TableColumnConfig(key: 'registrado_at', label: 'Registrado el'),
];

const List<DetailFieldOverride> finanzasCuentasDetalle = [
  DetailFieldOverride(key: 'nombre', label: 'Cuenta bancaria'),
  DetailFieldOverride(key: 'banco', label: 'Banco'),
  DetailFieldOverride(key: 'cuenta_contable_nombre', label: 'Cuenta contable'),
  DetailFieldOverride(key: 'activa', label: 'Activa'),
  DetailFieldOverride(key: 'registrado_at', label: 'Registrado el'),
];
