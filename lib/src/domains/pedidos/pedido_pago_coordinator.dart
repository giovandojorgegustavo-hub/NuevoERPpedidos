import 'package:erp_app/src/domains/pedidos/pedido_inline_service.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/models.dart';

class PedidoPagoCoordinator {
  const PedidoPagoCoordinator({
    required PedidoInlineService pedidoInlineService,
    required InlineDraftService inlineDraftService,
  })  : _pedidoInlineService = pedidoInlineService,
        _inlineDraftService = inlineDraftService;

  final PedidoInlineService _pedidoInlineService;
  final InlineDraftService _inlineDraftService;

  PedidoPagoBalance buildPagoBalance(
    Map<String, dynamic> parentRow, {
    String? excludePendingId,
    dynamic excludeRowId,
  }) {
    final detallePersisted = _persistedInlineRows(
      'pedidos_tabla',
      parentRow,
      'pedidos_detalle',
    );
    final detallePending = _inlineDraftService.findPendingRows(
      'pedidos_tabla',
      'pedidos_detalle',
    );
    final pagosPersisted = _persistedInlineRows(
      'pedidos_tabla',
      parentRow,
      'pedidos_pagos',
    );
    final pagosPending = _inlineDraftService.findPendingRows(
      'pedidos_tabla',
      'pedidos_pagos',
    );
    final inlineBalance = _pedidoInlineService.buildPagoBalance(
      detallePersisted: detallePersisted,
      detallePending: detallePending,
      pagosPersisted: pagosPersisted,
      pagosPending: pagosPending,
      excludePagoPendingId: excludePendingId,
      excludePagoRowId: excludeRowId,
    );
    final dbTotal = _readRowAmount(parentRow, 'total_con_cargos');
    final dbSaldo = _readRowAmount(parentRow, 'saldo');
    if (dbTotal != null && dbSaldo != null) {
      // La DB es la autoridad del total con cargos; usa esa base al calcular.
      final dbPagado =
          _readRowAmount(parentRow, 'total_pagado') ?? (dbTotal - dbSaldo);
      var paid = inlineBalance.paid;
      final hasInlinePagos =
          pagosPersisted.isNotEmpty || pagosPending.isNotEmpty;
      final hasExclusions =
          excludePendingId != null || excludeRowId != null;
      if (!hasInlinePagos && !hasExclusions) {
        paid = dbPagado;
      }
      final remaining =
          (dbTotal - paid).clamp(0, double.infinity).toDouble();
      return PedidoPagoBalance(
        total: dbTotal,
        paid: paid,
        remaining: _roundAmount(remaining),
      );
    }
    return inlineBalance;
  }

  Map<String, dynamic> buildPagoContext(Map<String, dynamic> pedidoRow) {
    final balance = buildPagoBalance(pedidoRow);
    final dbTotal = _readRowAmount(pedidoRow, 'total_con_cargos');
    final dbSaldo = _readRowAmount(pedidoRow, 'saldo');
    if (dbTotal != null && dbSaldo != null) {
      // La DB manda sobre el total/saldo del pedido; el contexto parte de ahi.
      final remaining = (dbTotal - balance.paid)
          .clamp(0, double.infinity)
          .toDouble();
      return {
        'pedido_total': dbTotal,
        'pedido_pagado': balance.paid,
        'pedido_saldo': _roundAmount(remaining),
      };
    }
    return {
      'pedido_total': balance.total,
      'pedido_pagado': balance.paid,
      'pedido_saldo': balance.remaining,
    };
  }

  double parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _readRowAmount(Map<String, dynamic> row, String key) {
    if (!row.containsKey(key)) return null;
    final value = row[key];
    if (value == null) return null;
    return parseAmount(value);
  }

  double _roundAmount(double value) =>
      double.parse(value.toStringAsFixed(2));

  String? validateInlineCreation({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required String? clientId,
    required bool hasDetalle,
  }) {
    final result = _pedidoInlineService.validateInlineCreation(
      parentSectionId: parentSectionId,
      inline: inline,
      clientId: clientId,
      hasDetalle: hasDetalle,
    );
    return result.message;
  }

  String? validateUniquePedidoProducto({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
    required String productId,
    String? excludePendingId,
    dynamic excludeRowId,
  }) {
    if (productId.isEmpty) return null;
    final persisted = _persistedInlineRows(
      parentSectionId,
      parentRow,
      inline.id,
    );
    final pending = _inlineDraftService.findPendingRows(
      parentSectionId,
      inline.id,
    );
    return _pedidoInlineService.validateUniquePedidoProducto(
      persistedRows: persisted,
      pendingRows: pending,
      productId: productId,
      inlineTitle: inline.title,
      excludePendingId: excludePendingId,
      excludeRowId: excludeRowId,
    );
  }

  String? validatePagoAmount({
    required Map<String, dynamic> parentRow,
    required double amount,
    String? excludePendingId,
    dynamic excludeRowId,
  }) {
    final balance = buildPagoBalance(
      parentRow,
      excludePendingId: excludePendingId,
      excludeRowId: excludeRowId,
    );
    return _pedidoInlineService.validatePagoAmount(
      amount: amount,
      remaining: balance.remaining,
    );
  }

  List<Map<String, dynamic>> _persistedInlineRows(
    String parentSectionId,
    Map<String, dynamic> parentRow,
    String inlineId,
  ) {
    final parentId = parentRow['id'];
    if (parentId == null) return const [];
    final key = _inlineDraftService.inlineKey(
      parentSectionId,
      parentId,
      inlineId,
    );
    final rows = _inlineDraftService.inlineSectionData[key];
    if (rows == null) return const [];
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }
}
