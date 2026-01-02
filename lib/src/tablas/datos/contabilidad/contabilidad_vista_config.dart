import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:flutter/material.dart';

const SectionDataSource contabilidadBalanceComprobacionDataSource =
    SectionDataSource(
      sectionId: 'contabilidad_trial_balance',
      listSchema: 'public',
      listRelation: 'v_contabilidad_balance_comprobacion',
      listIsView: true,
      formSchema: 'public',
      formRelation: '',
      formIsView: false,
      detailSchema: 'public',
      detailRelation: 'v_contabilidad_balance_comprobacion',
      detailIsView: true,
    );

const SectionDataSource contabilidadEstadoResultadosDataSource =
    SectionDataSource(
      sectionId: 'contabilidad_profit_loss',
      listSchema: 'public',
      listRelation: 'v_contabilidad_estado_resultados',
      listIsView: true,
      formSchema: 'public',
      formRelation: '',
      formIsView: false,
      detailSchema: 'public',
      detailRelation: 'v_contabilidad_estado_resultados',
      detailIsView: true,
    );

const SectionDataSource contabilidadBalanceGeneralDataSource = SectionDataSource(
  sectionId: 'contabilidad_balance_sheet',
  listSchema: 'public',
  listRelation: 'v_contabilidad_balance_general',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_contabilidad_balance_general',
  detailIsView: true,
);

const SectionDataSource contabilidadHistorialDataSource = SectionDataSource(
  sectionId: 'contabilidad_historial',
  listSchema: 'public',
  listRelation: 'v_contabilidad_historial',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_contabilidad_historial',
  detailIsView: true,
);

const List<TableColumnConfig> contabilidadBalanceComprobacionColumnas = [
  TableColumnConfig(key: 'periodo', label: 'Periodo'),
  TableColumnConfig(key: 'cuenta_contable_codigo', label: 'Codigo'),
  TableColumnConfig(key: 'cuenta_contable_nombre', label: 'Cuenta'),
  TableColumnConfig(key: 'tipo', label: 'Tipo'),
  TableColumnConfig(key: 'debe', label: 'Debe', textAlign: TextAlign.right),
  TableColumnConfig(key: 'haber', label: 'Haber', textAlign: TextAlign.right),
];

const List<DetailFieldOverride> contabilidadBalanceComprobacionDetalle = [
  DetailFieldOverride(key: 'periodo', label: 'Periodo'),
  DetailFieldOverride(key: 'cuenta_contable_codigo', label: 'Codigo'),
  DetailFieldOverride(key: 'cuenta_contable_nombre', label: 'Cuenta'),
  DetailFieldOverride(key: 'tipo', label: 'Tipo'),
  DetailFieldOverride(key: 'debe', label: 'Debe'),
  DetailFieldOverride(key: 'haber', label: 'Haber'),
];

const List<TableColumnConfig> contabilidadEstadoResultadosColumnas = [
  TableColumnConfig(key: 'periodo', label: 'Periodo'),
  TableColumnConfig(key: 'cuenta_contable_codigo', label: 'Codigo'),
  TableColumnConfig(key: 'cuenta_contable_nombre', label: 'Cuenta'),
  TableColumnConfig(key: 'tipo', label: 'Tipo'),
  TableColumnConfig(key: 'monto', label: 'Monto', textAlign: TextAlign.right),
];

const List<DetailFieldOverride> contabilidadEstadoResultadosDetalle = [
  DetailFieldOverride(key: 'periodo', label: 'Periodo'),
  DetailFieldOverride(key: 'cuenta_contable_codigo', label: 'Codigo'),
  DetailFieldOverride(key: 'cuenta_contable_nombre', label: 'Cuenta'),
  DetailFieldOverride(key: 'tipo', label: 'Tipo'),
  DetailFieldOverride(key: 'monto', label: 'Monto'),
];

const List<TableColumnConfig> contabilidadBalanceGeneralColumnas = [
  TableColumnConfig(key: 'periodo', label: 'Periodo'),
  TableColumnConfig(key: 'cuenta_contable_codigo', label: 'Codigo'),
  TableColumnConfig(key: 'cuenta_contable_nombre', label: 'Cuenta'),
  TableColumnConfig(key: 'tipo', label: 'Tipo'),
  TableColumnConfig(key: 'saldo', label: 'Saldo', textAlign: TextAlign.right),
];

const List<DetailFieldOverride> contabilidadBalanceGeneralDetalle = [
  DetailFieldOverride(key: 'periodo', label: 'Periodo'),
  DetailFieldOverride(key: 'cuenta_contable_codigo', label: 'Codigo'),
  DetailFieldOverride(key: 'cuenta_contable_nombre', label: 'Cuenta'),
  DetailFieldOverride(key: 'tipo', label: 'Tipo'),
  DetailFieldOverride(key: 'saldo', label: 'Saldo'),
];

const List<TableColumnConfig> contabilidadHistorialColumnas = [
  TableColumnConfig(key: 'fecha', label: 'Fecha'),
  TableColumnConfig(key: 'tipo', label: 'Tipo'),
  TableColumnConfig(
    key: 'alerta',
    label: 'Alerta',
    textAlign: TextAlign.center,
  ),
  TableColumnConfig(key: 'cuenta_contable_codigo', label: 'Codigo'),
  TableColumnConfig(key: 'cuenta_contable_nombre', label: 'Cuenta'),
  TableColumnConfig(key: 'descripcion', label: 'Descripcion'),
  TableColumnConfig(key: 'debe', label: 'Debe', textAlign: TextAlign.right),
  TableColumnConfig(key: 'haber', label: 'Haber', textAlign: TextAlign.right),
];

const List<DetailFieldOverride> contabilidadHistorialDetalle = [
  DetailFieldOverride(key: 'fecha', label: 'Fecha'),
  DetailFieldOverride(key: 'tipo', label: 'Tipo'),
  DetailFieldOverride(key: 'alerta', label: 'Alerta'),
  DetailFieldOverride(key: 'cuenta_contable_codigo', label: 'Codigo'),
  DetailFieldOverride(key: 'cuenta_contable_nombre', label: 'Cuenta'),
  DetailFieldOverride(key: 'cuenta_tipo', label: 'Tipo cuenta'),
  DetailFieldOverride(key: 'descripcion', label: 'Descripcion'),
  DetailFieldOverride(key: 'memo', label: 'Memo'),
  DetailFieldOverride(key: 'debe', label: 'Debe'),
  DetailFieldOverride(key: 'haber', label: 'Haber'),
  DetailFieldOverride(key: 'estado', label: 'Estado'),
  DetailFieldOverride(key: 'source_prefix', label: 'Origen'),
  DetailFieldOverride(key: 'source_id', label: 'Origen ID'),
  DetailFieldOverride(key: 'source_key', label: 'Origen llave'),
  DetailFieldOverride(key: 'entry_id', label: 'Asiento ID'),
];
