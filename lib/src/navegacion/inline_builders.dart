import 'package:erp_app/src/navegacion/inline_types.dart';
import 'package:erp_app/src/tablas/vistas/pagos/pagos_vista_inline.dart';
import 'package:erp_app/src/tablas/vistas/compras/compras_pagos_inline.dart';
import 'package:erp_app/src/tablas/vistas/compras/compras_historial_contable_inline.dart';
import 'package:erp_app/src/tablas/datos/ajustes/ajustes_detalle_inline_view.dart';
import 'package:erp_app/src/tablas/vistas/pedidos_detalle/pedidos_detalle_inline_view.dart';
import 'package:erp_app/src/tablas/vistas/pedidos/pedidos_movimientos_inline_view.dart';
import 'package:erp_app/src/tablas/vistas/movimientos/movimientos_detalle_inline_view.dart';
import 'package:erp_app/src/tablas/vistas/viajes/viajes_detalle_inline_view.dart';

export 'inline_types.dart';

final Map<String, InlineSectionViewBuilder> kInlineSectionViewBuilders = {
  'pedidos_detalle': buildPedidosDetalleInlineView,
  'pedidos_pagos': buildPagosVistaInlineView,
  'pedidos_movimientos': buildPedidosMovimientosInlineView,
  'movimientos_detalle': buildMovimientosDetalleInlineView,
  'compras_movimiento_detalle': buildMovimientosDetalleInlineView,
  'compras_historial_contable': buildComprasHistorialContableInlineView,
  'viajes_detalle': buildViajesDetalleInlineView,
  'ajustes_detalle': buildAjustesDetalleInlineView,
};

final Map<String, InlinePendingDisplayBuilder> kInlinePendingDisplayBuilders = {
  'pedidos_detalle': buildPedidosDetallePendingDisplay,
  'pedidos_pagos': buildPagosVistaPendingDisplay,
  'compras_pagos': buildComprasPagosPendingDisplay,
  'pedidos_movimientos': buildPedidosMovimientosPendingDisplay,
  'viajes_detalle': buildViajesDetallePendingDisplay,
  'ajustes_detalle': buildAjustesDetallePendingDisplay,
};
