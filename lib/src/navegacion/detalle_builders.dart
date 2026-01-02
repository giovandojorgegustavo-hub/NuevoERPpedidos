import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:flutter/material.dart';

import 'package:erp_app/src/tablas/vistas/movimientos/movimientos_vista_detail.dart';
import 'package:erp_app/src/tablas/vistas/pagos/pagos_vista_detail.dart';
import 'package:erp_app/src/tablas/vistas/pedidos_detalle/pedidos_detalle_detail_view.dart';
import 'package:erp_app/src/tablas/vistas/pedidos/pedidos_vista_detail.dart';
import 'package:erp_app/src/tablas/vistas/viajes/viajes_detalle_detail_view.dart';
import 'package:erp_app/src/tablas/vistas/stock/stock_detail_view.dart';

typedef ModuleDetailViewBuilder = DetailViewConfig Function({
  required Map<String, dynamic> row,
  required List<InlineTableConfig> inlineTables,
  VoidCallback? onBack,
  DetailActionConfig? floatingAction,
});

final Map<String, ModuleDetailViewBuilder> kModuleDetailViewBuilders = {
  'pedidos_tabla': buildPedidosVistaDetail,
  'pedidos_detalle': buildPedidosDetalleDetailView,
  'pedidos_pagos': buildPagosVistaDetail,
  'pedidos_movimientos': buildMovimientosDetailView,
  'movimientos': buildMovimientosDetailView,
  'viajes_detalle': buildViajesDetalleReadonlyDetail,
  'operaciones_stock': buildStockDetalleView,
  'stock_admin': buildStockAdminDetalleView,
};
