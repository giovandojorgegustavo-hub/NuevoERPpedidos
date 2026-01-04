import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/section_action_controller.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:flutter/material.dart';

import 'detail_field_override.dart';
import 'package:erp_app/src/tablas/datos/asistencias/asistencias_vista_config.dart';
import 'package:erp_app/src/tablas/datos/asistencias/asistencias_vista_form.dart';
import 'package:erp_app/src/tablas/datos/reportes/reportes_vista_config.dart';
import 'package:erp_app/src/tablas/datos/bases/bases_vista_config.dart';
import 'package:erp_app/src/tablas/datos/bases/bases_vista_form.dart';
import 'package:erp_app/src/tablas/datos/bases/base_packings_vista_form.dart';
import 'package:erp_app/src/tablas/datos/categorias/categorias_vista_config.dart';
import 'package:erp_app/src/tablas/datos/categorias/categorias_vista_form.dart';
import 'package:erp_app/src/tablas/datos/clientes/clientes_vista_config.dart';
import 'package:erp_app/src/tablas/datos/clientes/clientes_vista_form.dart';
import 'package:erp_app/src/tablas/datos/contabilidad/contabilidad_vista_config.dart';
import 'package:erp_app/src/tablas/datos/cuentas_bancarias/cuentas_bancarias_vista_config.dart';
import 'package:erp_app/src/tablas/datos/cuentas_bancarias/cuentas_bancarias_vista_form.dart';
import 'package:erp_app/src/tablas/datos/cuentas_bancarias_asignadas/cuentas_bancarias_asignadas_vista_config.dart';
import 'package:erp_app/src/tablas/datos/cuentas_bancarias_asignadas/cuentas_bancarias_asignadas_vista_form.dart';
import 'package:erp_app/src/tablas/datos/direccion/direccion_vista_config.dart';
import 'package:erp_app/src/tablas/datos/direccion/direccion_vista_form.dart';
import 'package:erp_app/src/tablas/datos/direccion_provincia/direccion_provincia_vista_config.dart';
import 'package:erp_app/src/tablas/datos/direccion_provincia/direccion_provincia_vista_form.dart';
import 'package:erp_app/src/tablas/datos/finanzas/finanzas_vista_config.dart';
import 'package:erp_app/src/tablas/datos/finanzas/finanzas_vista_form.dart';
import 'package:erp_app/src/tablas/datos/historial_operaciones/historial_operaciones_vista_config.dart';
import 'package:erp_app/src/tablas/datos/movimientos/movimientos_pedidos_inline_form.dart';
import 'package:erp_app/src/tablas/datos/movimientos/movimientos_vista_config.dart';
import 'package:erp_app/src/tablas/datos/movimientos/movimientos_vista_form.dart';
import 'package:erp_app/src/tablas/datos/movimientos_detalle/movimientos_detalle_vista_config.dart';
import 'package:erp_app/src/tablas/datos/movimientos_detalle/movimientos_detalle_vista_form.dart';
import 'package:erp_app/src/tablas/datos/usuarios/usuarios_vista_config.dart';
import 'package:erp_app/src/tablas/datos/usuarios/usuarios_vista_form.dart';
import 'package:erp_app/src/tablas/datos/viajes/viajes_vista_config.dart';
import 'package:erp_app/src/tablas/datos/viajes/viajes_vista_form.dart';
import 'package:erp_app/src/tablas/datos/viajes/viajes_detalle_vista_form.dart';
import 'package:erp_app/src/tablas/datos/viajes/viajes_devueltos_vista_config.dart';
import 'package:erp_app/src/tablas/datos/viajes/viajes_devueltos_detalle_vista_form.dart';
import 'package:erp_app/src/tablas/datos/viajes/viajes_devueltos_vista_form.dart';
import 'package:erp_app/src/tablas/datos/viajes/viajes_incidentes_vista_config.dart';
import 'package:erp_app/src/tablas/datos/viajes/viajes_incidentes_detalle_vista_form.dart';
import 'package:erp_app/src/tablas/datos/viajes/viajes_incidentes_vista_form.dart';
import 'package:erp_app/src/tablas/datos/numrecibe/numrecibe_vista_config.dart';
import 'package:erp_app/src/tablas/datos/numrecibe/numrecibe_vista_form.dart';
import 'package:erp_app/src/tablas/datos/pagos/pagos_vista_config.dart';
import 'package:erp_app/src/tablas/datos/pagos/pagos_vista_form.dart';
import 'package:erp_app/src/tablas/datos/pedidos/pedidos_vista_form.dart';
import 'package:erp_app/src/tablas/vistas/pedidos/pedidos_vista_tabla.dart';
import 'package:erp_app/src/tablas/datos/pedidos/pedidos_vista_config.dart';
import 'package:erp_app/src/tablas/datos/pedidos_detalle/pedidos_detalle_vista_config.dart';
import 'package:erp_app/src/tablas/datos/pedidos_detalle/pedidos_detalle_vista_form.dart';
import 'package:erp_app/src/tablas/datos/pedidos/pedido_rectificaciones_vista_config.dart';
import 'package:erp_app/src/tablas/datos/pedidos/pedido_reembolsos_vista_config.dart';
import 'package:erp_app/src/tablas/datos/productos/productos_vista_config.dart';
import 'package:erp_app/src/tablas/datos/productos/productos_vista_form.dart';
import 'package:erp_app/src/tablas/datos/recetas/recetas_vista_config.dart';
import 'package:erp_app/src/tablas/datos/recetas/recetas_vista_form.dart';
import 'package:erp_app/src/tablas/datos/compras/compras_vista_config.dart';
import 'package:erp_app/src/tablas/datos/compras/compras_vista_form.dart';
import 'package:erp_app/src/tablas/datos/compras/compras_detalle_vista_config.dart';
import 'package:erp_app/src/tablas/datos/compras/compras_detalle_vista_form.dart';
import 'package:erp_app/src/tablas/datos/compras/compras_pagos_vista_config.dart';
import 'package:erp_app/src/tablas/datos/compras/compras_pagos_vista_form.dart';
import 'package:erp_app/src/tablas/datos/compras/compras_movimientos_vista_config.dart';
import 'package:erp_app/src/tablas/datos/compras/compras_movimientos_vista_form.dart';
import 'package:erp_app/src/tablas/datos/compras/compras_movimiento_detalle_vista_form.dart';
import 'package:erp_app/src/tablas/datos/stock/stock_vista_config.dart';
import 'package:erp_app/src/tablas/datos/proveedores/proveedores_vista_config.dart';
import 'package:erp_app/src/tablas/datos/proveedores/proveedores_vista_form.dart';
import 'package:erp_app/src/tablas/datos/comunicaciones/comunicaciones_vista_config.dart';
import 'package:erp_app/src/tablas/datos/comunicaciones/comunicaciones_vista_form.dart';
import 'package:erp_app/src/tablas/datos/fabricaciones/fabricaciones_internas_vista_config.dart';
import 'package:erp_app/src/tablas/datos/ajustes/ajustes_vista_config.dart';
import 'package:erp_app/src/tablas/datos/ajustes/ajustes_vista_form.dart';
import 'package:erp_app/src/tablas/datos/transferencias/transferencias_vista_config.dart';
import 'package:erp_app/src/tablas/datos/transferencias/transferencias_vista_form.dart';
import 'package:erp_app/src/tablas/datos/costos_historial/costos_historial_vista_config.dart';
import 'package:erp_app/src/tablas/datos/fabricaciones/fabricaciones_internas_vista_form.dart';
import 'package:erp_app/src/tablas/datos/fabricaciones/fabricaciones_maquila_vista_config.dart';
import 'package:erp_app/src/tablas/datos/fabricaciones/fabricaciones_maquila_vista_form.dart';

typedef SectionRowTransformer =
    Map<String, dynamic> Function(Map<String, dynamic> row);

class SectionOverrides {
  const SectionOverrides({
    this.formFields,
    this.dataSource,
    this.tableColumns,
    this.rowTransformer,
    this.detailFields,
    this.detailSubtitleBuilder,
    this.rowTapActionBuilder,
    this.rowActionsBuilder,
    this.bulkActionsBuilder,
    this.primaryActionBuilder,
    this.inlineSections,
    this.groupByColumn,
  });

  final List<SectionField>? formFields;
  final SectionDataSource? dataSource;
  final List<TableColumnConfig>? tableColumns;
  final SectionRowTransformer? rowTransformer;
  final List<DetailFieldOverride>? detailFields;
  final String? Function(Map<String, dynamic> row)? detailSubtitleBuilder;
  final TableAction? Function(SectionActionController controller)?
  rowTapActionBuilder;
  final List<TableAction> Function(SectionActionController controller)?
  rowActionsBuilder;
  final List<TableAction> Function(SectionActionController controller)?
  bulkActionsBuilder;
  final TableAction? Function(SectionActionController controller)?
  primaryActionBuilder;
  final List<InlineSectionConfig>? inlineSections;
  final String? groupByColumn;
}

final Map<String, SectionOverrides> kSectionOverrides = {
  'pedidos_tabla': SectionOverrides(
    formFields: pedidosVistaFormFields,
    dataSource: pedidosDataSource,
    tableColumns: pedidosColumnas,
    rowTransformer: pedidosTransformer,
    detailFields: pedidosCamposDetalle,
    detailSubtitleBuilder: pedidosVistaTablaSubtitleBuilder,
    inlineSections: pedidosInlineSections,
    bulkActionsBuilder: (_) => const [],
    groupByColumn: 'estado_general',
  ),

  'pedidos_detalle': SectionOverrides(
    formFields: detallePedidosInlineFields,
    dataSource: pedidosDetalleDataSource,
    detailFields: pedidosDetalleCamposDetalle,
  ),
  'pedidos_pagos': SectionOverrides(
    formFields: pagosVistaFormFields,
    dataSource: pedidosPagosDataSource,
    detailFields: pagosCamposDetalle,
  ),
  'pedidos_movimientos': SectionOverrides(
    formFields: movimientosInlineFields,
    dataSource: pedidosMovimientosDataSource,
    detailFields: pedidosMovimientosCamposDetalle,
    inlineSections: const [movimientosDetalleInlineSection],
  ),
  'pedido_rectificaciones': SectionOverrides(
    formFields: pedidoRectificacionesFormFields,
    dataSource: pedidoRectificacionesDataSource,
    detailFields: pedidoRectificacionesCamposDetalle,
  ),
  'pedido_reembolsos': SectionOverrides(
    formFields: pedidoReembolsosFormFields,
    dataSource: pedidoReembolsosDataSource,
    detailFields: pedidoReembolsosCamposDetalle,
  ),
  'movimientos': SectionOverrides(
    formFields: movimientosLecturaFormFields,
    tableColumns: movimientosLecturaColumnas,
    rowTransformer: movimientosLecturaRowTransformer,
    inlineSections: const [movimientosDetalleLecturaInlineSection],
    groupByColumn: 'estado_grupo',
    dataSource: const SectionDataSource(
      sectionId: 'movimientos',
      listSchema: 'public',
      listRelation: 'v_movimiento_vistageneral',
      listIsView: true,
      formSchema: '',
      formRelation: '',
      formIsView: false,
      detailSchema: null,
      detailRelation: null,
      detailIsView: null,
      listOrderBy: 'fecharegistro',
      listOrderAscending: false,
      listLimit: 150,
    ),
  ),
  'movimientos_detalle': SectionOverrides(
    formFields: movimientosDetalleVistaFormFields,
    dataSource: movimientosDetalleDataSource,
    detailFields: movimientosDetalleCamposDetalle,
  ),
  'viajes': SectionOverrides(
    formFields: viajesVistaFormFields,
    dataSource: viajesDataSource,
    tableColumns: viajesColumnas,
    detailFields: viajesCamposDetalle,
    detailSubtitleBuilder: (row) =>
        row['base_nombre']?.toString() ?? row['idbase']?.toString() ?? '',
    inlineSections: const [viajesDetalleInlineSection],
    rowTransformer: viajesRowTransformer,
    groupByColumn: 'estado_grupo',
  ),
  'viajes_bases': SectionOverrides(
    formFields: viajesBasesVistaFormFields,
    dataSource: viajesBasesDataSource,
    tableColumns: viajesColumnas,
    detailFields: viajesCamposDetalle,
    detailSubtitleBuilder: (row) =>
        row['base_nombre']?.toString() ?? row['idbase']?.toString() ?? '',
    inlineSections: const [viajesDetalleInlineSection],
    rowTransformer: viajesRowTransformer,
    groupByColumn: 'estado_grupo',
  ),
  'comunicaciones_base': SectionOverrides(
    formFields: comunicacionesBaseFormFields,
    dataSource: comunicacionesBaseDataSource,
    tableColumns: comunicacionesColumnas,
    detailFields: comunicacionesDetalleCampos,
    rowTransformer: comunicacionesRowTransformer,
    bulkActionsBuilder: (_) => const [],
    groupByColumn: 'estado',
  ),
  'comunicaciones': SectionOverrides(
    formFields: comunicacionesVistaFormFields,
    dataSource: comunicacionesDataSource,
    tableColumns: comunicacionesColumnas,
    detailFields: comunicacionesDetalleCampos,
    rowTransformer: comunicacionesRowTransformer,
    bulkActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
    groupByColumn: 'estado',
  ),
  'viajes_detalle': SectionOverrides(
    formFields: viajesDetalleVistaFormFields,
    dataSource: viajesDetalleDataSource,
    detailFields: viajesDetalleCamposDetalle,
    tableColumns: viajesDetalleTablaColumnas,
    groupByColumn: 'estado_detalle',
    inlineSections: const [
      viajesMovimientoDetalleInlineSection,
      viajesIncidentesInlineSection,
    ],
    bulkActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'viajes_devueltos': SectionOverrides(
    formFields: viajesDevueltosVistaFormFields,
    dataSource: viajesDevueltosDataSource,
    tableColumns: viajesDevueltosColumnas,
    detailFields: viajesDevueltosCamposDetalle,
    rowTransformer: viajesDevueltosRowTransformer,
    groupByColumn: 'estado_grupo',
    inlineSections: const [viajesDevueltosDetalleInlineSection],
    bulkActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'viajes_devueltos_detalle': SectionOverrides(
    formFields: viajesDevueltosDetalleVistaFormFields,
    dataSource: const SectionDataSource(
      sectionId: 'viajes_devueltos_detalle',
      listSchema: 'public',
      listRelation: 'v_viajes_devueltos_detalle_vistageneral',
      listIsView: true,
      formSchema: 'public',
      formRelation: 'viajes_devueltos_detalle',
      formIsView: false,
      detailSchema: 'public',
      detailRelation: 'v_viajes_devueltos_detalle_vistageneral',
      detailIsView: true,
    ),
  ),
  'viajes_incidentes': SectionOverrides(
    formFields: viajesIncidentesVistaFormFields,
    dataSource: viajesIncidentesDataSource,
    tableColumns: viajesIncidentesColumnas,
    detailFields: viajesIncidentesCamposDetalle,
    inlineSections: const [viajesIncidentesProductosInlineSection],
    bulkActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'viajes_incidentes_detalle': SectionOverrides(
    formFields: viajesIncidentesDetalleVistaFormFields,
    dataSource: SectionDataSource(
      sectionId: 'viajes_incidentes_detalle',
      listSchema: 'public',
      listRelation: 'v_viajes_incidentes_detalle_vistageneral',
      listIsView: true,
      formSchema: 'public',
      formRelation: 'viajes_incidentes_detalle',
      formIsView: false,
      detailSchema: 'public',
      detailRelation: 'v_viajes_incidentes_detalle_vistageneral',
      detailIsView: true,
    ),
  ),
  'usuarios': SectionOverrides(
    formFields: usuariosVistaFormFields,
    dataSource: usuariosDataSource,
    tableColumns: usuariosColumnas,
    detailFields: usuariosCamposDetalle,
    rowTransformer: usuariosRowTransformer,
    groupByColumn: null,
  ),
  'cuentas_bancarias_asignadas': SectionOverrides(
    formFields: cuentasBancariasAsignadasFormFields,
    dataSource: cuentasBancariasAsignadasDataSource,
    tableColumns: cuentasBancariasAsignadasColumnas,
    detailFields: cuentasBancariasAsignadasDetalle,
  ),
  'clientes_form': SectionOverrides(
    formFields: clientesVistaFormFields,
    dataSource: clientesDataSource,
  ),
  'direccion_form': SectionOverrides(
    formFields: direccionVistaFormFields,
    dataSource: direccionDataSource,
  ),
  'direccion_provincia_form': SectionOverrides(
    formFields: direccionProvinciaVistaFormFields,
    dataSource: direccionProvinciaDataSource,
  ),
  'numrecibe_form': SectionOverrides(
    formFields: numrecibeVistaFormFields,
    dataSource: numrecibeDataSource,
  ),
  'proveedores_form': SectionOverrides(
    formFields: proveedoresVistaFormFields,
    dataSource: proveedoresDataSource,
  ),
  'productos': SectionOverrides(
    formFields: productosVistaFormFields,
    dataSource: productosCatalogoDataSource,
    tableColumns: productosColumnas,
    detailFields: productosCamposDetalle,
    rowTransformer: productosRowTransformer,
    detailSubtitleBuilder: (row) => row['nombre']?.toString(),
  ),
  'productos_form': SectionOverrides(
    formFields: productosVistaFormFields,
    dataSource: productosDataSource,
  ),
  'categorias_form': SectionOverrides(
    formFields: categoriasVistaFormFields,
    dataSource: categoriasDataSource,
  ),
  'cuentas_bancarias_form': SectionOverrides(
    formFields: cuentasBancariasVistaFormFields,
    dataSource: cuentasBancariasDataSource,
  ),
  'bases_form': SectionOverrides(
    formFields: basesVistaFormFields,
    dataSource: basesDataSource,
  ),
  'bases': SectionOverrides(
    formFields: basesVistaFormFields,
    dataSource: basesSectionDataSource,
    tableColumns: basesColumnas,
    inlineSections: const [basePackingsInlineSection],
  ),
  'bases_lectura': SectionOverrides(
    dataSource: basesLecturaSectionDataSource,
    tableColumns: basesColumnas,
    inlineSections: const [basePackingsInlineSection],
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'base_packings_form': SectionOverrides(
    formFields: basePackingsVistaFormFields,
    dataSource: basePackingsDataSource,
  ),
  'operaciones_stock': SectionOverrides(
    dataSource: stockDataSource,
    tableColumns: stockOperacionesColumnas,
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'stock_admin': SectionOverrides(
    dataSource: stockAdminDataSource,
    tableColumns: stockAdminColumnas,
    rowTransformer: stockAdminRowTransformer,
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'finanzas_saldos': SectionOverrides(
    dataSource: finanzasSaldosDataSource,
    tableColumns: finanzasSaldosColumnas,
    detailFields: finanzasSaldosDetalle,
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'finanzas_historial': SectionOverrides(
    dataSource: finanzasHistorialDataSource,
    tableColumns: finanzasHistorialColumnas,
    detailFields: finanzasHistorialDetalle,
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'finanzas_movimientos': SectionOverrides(
    formFields: finanzasMovimientosFormFields,
    dataSource: finanzasMovimientosDataSource,
    tableColumns: finanzasMovimientosColumnas,
    detailFields: finanzasMovimientosDetalle,
    bulkActionsBuilder: (_) => const [],
  ),
  'finanzas_gastos': SectionOverrides(
    formFields: finanzasGastosFormFields,
    dataSource: finanzasGastosDataSource,
    tableColumns: finanzasGastosColumnas,
    detailFields: finanzasGastosDetalle,
    bulkActionsBuilder: (_) => const [],
  ),
  'finanzas_cuentas': SectionOverrides(
    formFields: finanzasCuentasFormFields,
    dataSource: finanzasCuentasDataSource,
    tableColumns: finanzasCuentasColumnas,
    detailFields: finanzasCuentasDetalle,
    bulkActionsBuilder: (_) => const [],
  ),
  'contabilidad_trial_balance': SectionOverrides(
    dataSource: contabilidadBalanceComprobacionDataSource,
    tableColumns: contabilidadBalanceComprobacionColumnas,
    detailFields: contabilidadBalanceComprobacionDetalle,
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'contabilidad_profit_loss': SectionOverrides(
    dataSource: contabilidadEstadoResultadosDataSource,
    tableColumns: contabilidadEstadoResultadosColumnas,
    detailFields: contabilidadEstadoResultadosDetalle,
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'contabilidad_balance_sheet': SectionOverrides(
    dataSource: contabilidadBalanceGeneralDataSource,
    tableColumns: contabilidadBalanceGeneralColumnas,
    detailFields: contabilidadBalanceGeneralDetalle,
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'contabilidad_historial': SectionOverrides(
    dataSource: contabilidadHistorialDataSource,
    tableColumns: contabilidadHistorialColumnas,
    detailFields: contabilidadHistorialDetalle,
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'historial_operaciones': SectionOverrides(
    dataSource: historialOperacionesDataSource,
    tableColumns: historialOperacionesColumnas,
    detailFields: historialOperacionesCamposDetalle,
    rowTransformer: historialOperacionesRowTransformer,
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'transferencias': SectionOverrides(
    formFields: transferenciasFormFields,
    dataSource: transferenciasDataSource,
    tableColumns: transferenciasColumnas,
    detailFields: transferenciasCamposDetalle,
    rowTransformer: transferenciasRowTransformer,
    inlineSections: transferenciasInlineSections,
    bulkActionsBuilder: (_) => const [],
  ),
  'transferencias_detalle': SectionOverrides(
    formFields: transferenciasDetalleFormFields,
    dataSource: transferenciasDetalleDataSource,
    detailFields: transferenciasDetalleCamposDetalle,
  ),
  'costos_historial': SectionOverrides(
    dataSource: costosHistorialDataSource,
    tableColumns: costosHistorialColumnas,
    detailFields: costosHistorialCamposDetalle,
    rowTransformer: costosHistorialRowTransformer,
    bulkActionsBuilder: (_) => const [],
    rowActionsBuilder: (_) => const [],
    primaryActionBuilder: (_) => null,
  ),
  'ajustes': SectionOverrides(
    formFields: ajustesFormFields,
    dataSource: ajustesDataSource,
    tableColumns: ajustesColumnas,
    detailFields: ajustesCamposDetalle,
    rowTransformer: ajustesRowTransformer,
    inlineSections: ajustesInlineSections,
    bulkActionsBuilder: (_) => const [],
  ),
  'ajustes_detalle': SectionOverrides(
    formFields: ajustesDetalleFormFields,
    dataSource: ajustesDetalleDataSource,
    detailFields: ajustesDetalleCamposDetalle,
  ),
  'compras': SectionOverrides(
    formFields: comprasVistaFormFields,
    dataSource: comprasDataSource,
    tableColumns: comprasColumnas,
    detailFields: comprasCamposDetalle,
    rowTransformer: comprasRowTransformer,
    inlineSections: comprasInlineSections,
    bulkActionsBuilder: (controller) => _buildCancelActions(controller, 'compras'),
  ),
  'compras_detalle': SectionOverrides(
    formFields: comprasDetalleFormFields,
    dataSource: comprasDetalleDataSource,
    detailFields: comprasDetalleCamposDetalle,
    bulkActionsBuilder: (_) => const [],
  ),
  'compras_pagos': SectionOverrides(
    formFields: comprasPagosFormFields,
    dataSource: comprasPagosDataSource,
    detailFields: comprasPagosCamposDetalle,
    bulkActionsBuilder: (_) => const [],
  ),
  'compras_movimientos': SectionOverrides(
    formFields: comprasMovimientosFormFields,
    dataSource: comprasMovimientosDataSource,
    tableColumns: comprasMovimientosColumnas,
    detailFields: comprasMovimientosCamposDetalle,
    inlineSections: const [comprasMovimientosDetalleInlineSection],
    bulkActionsBuilder: (_) => const [],
  ),
  'compras_movimiento_detalle': SectionOverrides(
    formFields: comprasMovimientosDetalleFormFields,
    dataSource: comprasMovimientosDetalleDataSource,
    detailFields: comprasMovimientosDetalleCamposDetalle,
    bulkActionsBuilder: (_) => const [],
  ),
  'recetas': SectionOverrides(
    formFields: recetasFormFields,
    dataSource: recetasDataSource,
    tableColumns: recetasColumnas,
    detailFields: recetasCamposDetalle,
    rowTransformer: recetasRowTransformer,
    inlineSections: recetasInlineSections,
  ),
  'recetas_insumos': SectionOverrides(
    formFields: recetasInsumosFormFields,
    dataSource: recetasInsumosDataSource,
  ),
  'recetas_resultados': SectionOverrides(
    formFields: recetasResultadosFormFields,
    dataSource: recetasResultadosDataSource,
  ),
  'fabricaciones_internas': SectionOverrides(
    formFields: fabricacionesInternasFormFields,
    dataSource: fabricacionesInternasDataSource,
    tableColumns: fabricacionesInternasColumnas,
    detailFields: fabricacionesInternasCamposDetalle,
    rowTransformer: fabricacionesInternasRowTransformer,
    inlineSections: fabricacionesInternasInlineSections,
    bulkActionsBuilder: (controller) =>
        _buildCancelActions(controller, 'fabricaciones_internas'),
  ),
  'fabricaciones_internas_consumos': SectionOverrides(
    formFields: fabricacionesInternasConsumosFormFields,
    dataSource: fabricacionesInternasConsumosDataSource,
  ),
  'fabricaciones_internas_resultados': SectionOverrides(
    formFields: fabricacionesInternasResultadosFormFields,
    dataSource: fabricacionesInternasResultadosDataSource,
  ),
  'fabricaciones_maquila': SectionOverrides(
    formFields: fabricacionesMaquilaFormFields,
    dataSource: fabricacionesMaquilaDataSource,
    tableColumns: fabricacionesMaquilaColumnas,
    detailFields: fabricacionesMaquilaCamposDetalle,
    rowTransformer: fabricacionesMaquilaRowTransformer,
    inlineSections: fabricacionesMaquilaInlineSections,
    bulkActionsBuilder: (controller) =>
        _buildCancelActions(controller, 'fabricaciones_maquila'),
  ),
  'fabricaciones_maquila_consumos': SectionOverrides(
    formFields: fabricacionesMaquilaConsumosFormFields,
    dataSource: fabricacionesMaquilaConsumosDataSource,
  ),
  'fabricaciones_maquila_resultados': SectionOverrides(
    formFields: fabricacionesMaquilaResultadosFormFields,
    dataSource: fabricacionesMaquilaResultadosDataSource,
  ),
  'fabricaciones_maquila_costos': SectionOverrides(
    formFields: fabricacionesMaquilaCostosFormFields,
    dataSource: fabricacionesMaquilaCostosDataSource,
  ),
  'asistencias_slots': SectionOverrides(
    formFields: asistenciasSlotsFormFields,
    dataSource: asistenciasSlotsDataSource,
    tableColumns: asistenciasSlotsColumnas,
    detailFields: asistenciasSlotsCamposDetalle,
  ),
  'asistencias_base_slots': SectionOverrides(
    formFields: asistenciasBaseSlotsFormFields,
    dataSource: asistenciasBaseSlotsDataSource,
    tableColumns: asistenciasBaseSlotsColumnas,
    detailFields: asistenciasBaseSlotsCamposDetalle,
    groupByColumn: 'base_nombre',
  ),
  'asistencias_pendientes': SectionOverrides(
    formFields: asistenciasPendientesFormFields,
    dataSource: asistenciasPendientesDataSource,
    tableColumns: asistenciasPendientesColumnas,
    detailFields: asistenciasRegistroCamposDetalle,
    groupByColumn: 'base_nombre',
  ),
  'asistencias_permisos': SectionOverrides(
    formFields: asistenciasPermisosFormFields,
    dataSource: asistenciasPermisosDataSource,
    tableColumns: asistenciasPermisosColumnas,
    detailFields: asistenciasExcepcionesCamposDetalle,
    groupByColumn: 'base_nombre',
  ),
  'asistencias_historial': SectionOverrides(
    dataSource: asistenciasHistorialDataSource,
    tableColumns: asistenciasHistorialColumnas,
    detailFields: asistenciasRegistroCamposDetalle,
    groupByColumn: 'base_nombre',
  ),
  'reporte_asistencia_tablero': SectionOverrides(
    formFields: asistenciasPendientesFormFields,
    dataSource: reporteAsistenciaTableroDataSource,
    tableColumns: reporteAsistenciaTableroColumnas,
    detailFields: reporteAsistenciaTableroDetalle,
    groupByColumn: 'base_nombre',
  ),
  'reportes_pedidos': SectionOverrides(
    dataSource: reportesPedidosDataSource,
    tableColumns: reportesPedidosColumnas,
    detailFields: reportesPedidosDetalle,
  ),
  'reportes_pedidos_detalle': SectionOverrides(
    dataSource: reportesPedidosDetalleDataSource,
    tableColumns: reportesPedidosDetalleColumnas,
    detailFields: reportesPedidosDetalleDetalle,
  ),
  'reportes_ganancia_diaria': SectionOverrides(
    dataSource: reportesGananciaDiariaDataSource,
    tableColumns: reportesGananciaDiariaColumnas,
    detailFields: reportesGananciaDetalle,
  ),
  'reportes_ganancia_mensual': SectionOverrides(
    dataSource: reportesGananciaMensualDataSource,
    tableColumns: reportesGananciaMensualColumnas,
    detailFields: reportesGananciaDetalle,
  ),
  'reportes_ganancia_clientes_meses': SectionOverrides(
    dataSource: reportesGananciaClientesMesesDataSource,
    tableColumns: reportesMesesColumnas,
    detailFields: reportesMesesDetalle,
    inlineSections: const [reportesClientesInlineSection],
  ),
  'reportes_ganancia_productos_meses': SectionOverrides(
    dataSource: reportesGananciaProductosMesesDataSource,
    tableColumns: reportesMesesColumnas,
    detailFields: reportesMesesDetalle,
    inlineSections: const [reportesProductosInlineSection],
  ),
  'reportes_ganancia_bases_meses': SectionOverrides(
    dataSource: reportesGananciaBasesMesesDataSource,
    tableColumns: reportesMesesColumnas,
    detailFields: reportesMesesDetalle,
    inlineSections: const [reportesBasesInlineSection],
  ),
};

List<TableAction> _buildCancelActions(
  SectionActionController controller,
  String sectionId,
) {
  return [
    TableAction(
      label: 'Cancelar',
      icon: Icons.cancel_outlined,
      onSelected: (rows) => controller.cancelRows(sectionId, rows),
    ),
  ];
}
