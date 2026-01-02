import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';

typedef SectionContextGetter = Map<String, dynamic> Function(String sectionId);
typedef SectionContextSetter =
    void Function(String sectionId, Map<String, dynamic>? contextValues);
typedef SectionRowResolver = Map<String, dynamic>? Function(String sectionId);
typedef InlineConfigResolver =
    InlineSectionConfig? Function(String sectionId, String inlineId);
typedef ReferenceLoader = Future<void> Function(String sectionId);
typedef MountedResolver = bool Function();
typedef ShellSetState = void Function(VoidCallback fn);

enum MovementDocumentType { none, pedido, compra }

/// Centraliza la lógica de cobertura de movimientos versus pedidos para que la
/// Shell solo orqueste la interacción entre UI y servicios de dominio.
class MovimientoCoverageService {
  MovimientoCoverageService({
    required ModuleRepository moduleRepository,
    required InlineDraftService inlineDraftService,
    required SectionContextGetter sectionContextGetter,
    required SectionContextSetter sectionContextSetter,
    required SectionRowResolver sectionRowResolver,
    required InlineConfigResolver inlineConfigResolver,
    required ReferenceLoader referenceLoader,
    required MountedResolver mountedResolver,
    required ShellSetState setState,
  }) : _moduleRepository = moduleRepository,
       _inlineDraftService = inlineDraftService,
       _getSectionContext = sectionContextGetter,
       _setSectionContext = sectionContextSetter,
       _sectionRowResolver = sectionRowResolver,
       _inlineConfigResolver = inlineConfigResolver,
       _referenceLoader = referenceLoader,
       _mountedResolver = mountedResolver,
       _setState = setState;

  final ModuleRepository _moduleRepository;
  final InlineDraftService _inlineDraftService;
  final SectionContextGetter _getSectionContext;
  final SectionContextSetter _setSectionContext;
  final SectionRowResolver _sectionRowResolver;
  final InlineConfigResolver _inlineConfigResolver;
  final ReferenceLoader _referenceLoader;
  final MountedResolver _mountedResolver;
  final ShellSetState _setState;

  final Map<String, _MovementCoverage> _coverageCache = {};
  final Map<String, Future<_MovementCoverage>> _pendingCoverage = {};

  String _coverageKey(MovementDocumentType type, String id) {
    switch (type) {
      case MovementDocumentType.pedido:
        return 'pedido:$id';
      case MovementDocumentType.compra:
        return 'compra:$id';
      case MovementDocumentType.none:
        return id;
    }
  }

  bool isMovementSection(String sectionId) =>
      sectionId == 'movimientos' ||
      sectionId == 'pedidos_movimientos' ||
      sectionId == 'compras_movimientos';

  MovementDocumentType _movementTypeForSection(String sectionId) {
    if (sectionId == 'pedidos_movimientos') {
      return MovementDocumentType.pedido;
    }
    if (sectionId == 'compras_movimientos') {
      return MovementDocumentType.compra;
    }
    return MovementDocumentType.none;
  }

  String _inlineDetailIdForSection(String sectionId) {
    if (sectionId == 'compras_movimientos') {
      return 'compras_movimiento_detalle';
    }
    return 'movimientos_detalle';
  }

  void prepareMovementDetailContext(
    String sectionId,
    Map<String, dynamic> row,
  ) {
    if (!isMovementSection(sectionId)) return;
    final documentType = _movementTypeForSection(sectionId);
    if (documentType == MovementDocumentType.none) return;
    final contextValues = Map<String, dynamic>.from(
      _getSectionContext(sectionId),
    );
    final pendingTotals = _pendingMovementDetailTotals(sectionId);
    if (sectionId == 'pedidos_movimientos') {
      final excludePendingId = row['__pending_id']?.toString();
      final nestedPendingTotals = _pendingMovementDetailTotalsFromPedidoDraft(
        excludePendingId: excludePendingId,
      );
      nestedPendingTotals.forEach((productId, qty) {
        pendingTotals[productId] = (pendingTotals[productId] ?? 0) + qty;
      });
    } else if (sectionId == 'compras_movimientos') {
      final excludePendingId = row['__pending_id']?.toString();
      final nestedPendingTotals = _pendingMovementDetailTotalsFromCompraDraft(
        excludePendingId: excludePendingId,
      );
      nestedPendingTotals.forEach((productId, qty) {
        pendingTotals[productId] = (pendingTotals[productId] ?? 0) + qty;
      });
    }
    final documentId = documentType == MovementDocumentType.pedido
        ? resolvePedidoIdFromMovement(sectionId, row)
        : resolveCompraIdFromMovement(sectionId, row);
    debugPrint(
      '[mov-det] prepare context section=$sectionId rowId=${row['id']} '
      'document=$documentId type=$documentType',
    );
    final bool hasDocumentId = documentId != null && documentId.isNotEmpty;
    if (!hasDocumentId) {
      if (documentType == MovementDocumentType.pedido &&
          sectionId == 'pedidos_movimientos') {
        _applyDraftCoverageContext(
          sectionId: sectionId,
          contextValues: contextValues,
          draftTotals: _pendingPedidoDetailTotals(),
          pendingTotals: pendingTotals,
          parentRow: row,
        );
        return;
      }
      if (documentType == MovementDocumentType.compra &&
          sectionId == 'compras_movimientos') {
        _applyDraftCoverageContext(
          sectionId: sectionId,
          contextValues: contextValues,
          draftTotals: _pendingCompraDetailTotals(),
          pendingTotals: pendingTotals,
          parentRow: row,
        );
        return;
      }
      return;
    }
    if (documentType == MovementDocumentType.pedido) {
      contextValues['movimiento_pedido_id'] = documentId;
    } else if (documentType == MovementDocumentType.compra) {
      contextValues['movimiento_compra_id'] = documentId;
    }
    contextValues['movimientos_detalle_pending_totals'] = pendingTotals;
    final cacheKey = _coverageKey(documentType, documentId);
    final coverage = _coverageCache[cacheKey];
    if (coverage == null) {
      _scheduleMovementCoverageLoad(
        type: documentType,
        documentId: documentId,
        sectionId: sectionId,
        row: row,
      );
      contextValues['movimientos_detalle_remaining'] = const <String, double>{};
      contextValues.remove('movimientos_detalle_hasRemaining');
      contextValues.remove('movimientos_detalle_complete_action');
      _setSectionContext(sectionId, contextValues);
      _inlineDraftService.notifyInlineDataChanged();
      return;
    }
    final Map<String, double> totalsWithDraft = Map<String, double>.from(
      coverage.orderTotals,
    );
    if (documentType == MovementDocumentType.pedido) {
      final draftTotals = _pendingPedidoDetailTotals();
      _mergeDraftTotals(totalsWithDraft, draftTotals);
    } else if (documentType == MovementDocumentType.compra) {
      final draftTotals = _pendingCompraDetailTotals();
      _mergeDraftTotals(totalsWithDraft, draftTotals);
    }
    final remaining = _calculateMovementRemaining(
      totalsWithDraft,
      coverage.assignedTotals,
      pendingTotals,
    );
    final hasRemaining = remaining.values.any((value) => value > 0.0001);
    contextValues['movimientos_detalle_remaining'] = remaining;
    contextValues['movimientos_detalle_hasRemaining'] = hasRemaining;
    contextValues['movimientos_detalle_complete_action'] = hasRemaining
        ? () => completeMovementDetails(sectionId: sectionId, parentRow: row)
        : null;
    _setSectionContext(sectionId, contextValues);
    _inlineDraftService.notifyInlineDataChanged();
  }

  void _applyDraftCoverageContext({
    required String sectionId,
    required Map<String, dynamic> contextValues,
    required Map<String, double> draftTotals,
    required Map<String, double> pendingTotals,
    required Map<String, dynamic> parentRow,
  }) {
    if (draftTotals.isEmpty) {
      contextValues['movimientos_detalle_remaining'] = const <String, double>{};
      contextValues.remove('movimientos_detalle_hasRemaining');
      contextValues.remove('movimientos_detalle_complete_action');
      _setSectionContext(sectionId, contextValues);
      _inlineDraftService.notifyInlineDataChanged();
      return;
    }
    final remaining = _calculateMovementRemaining(
      draftTotals,
      const <String, double>{},
      pendingTotals,
    );
    final hasRemaining = remaining.values.any((value) => value > 0.0001);
    contextValues['movimientos_detalle_remaining'] = remaining;
    contextValues['movimientos_detalle_hasRemaining'] = hasRemaining;
    contextValues['movimientos_detalle_complete_action'] = hasRemaining
        ? () => completeMovementDetails(
            sectionId: sectionId,
            parentRow: parentRow,
          )
        : null;
    _setSectionContext(sectionId, contextValues);
    _inlineDraftService.notifyInlineDataChanged();
  }

  void _mergeDraftTotals(Map<String, double> base, Map<String, double> draft) {
    if (draft.isEmpty) return;
    draft.forEach((productId, qty) {
      base[productId] = (base[productId] ?? 0) + qty;
    });
  }

  Map<String, double>? movementRemainingForSection(String sectionId) {
    final contextValues = _getSectionContext(sectionId);
    final bool? hasRemaining =
        contextValues['movimientos_detalle_hasRemaining'] as bool?;
    final remaining =
        contextValues['movimientos_detalle_remaining']
            as Map<dynamic, dynamic>?;
    if (hasRemaining == null || remaining == null) return null;
    final result = <String, double>{};
    remaining.forEach((key, value) {
      final productId = key?.toString();
      if (productId == null) return;
      final qty = value is num
          ? value.toDouble()
          : double.tryParse(value?.toString() ?? '') ?? 0;
      if (qty <= 0) return;
      result[productId] = qty;
    });
    return result;
  }

  Future<void> completeMovementDetails({
    required String sectionId,
    required Map<String, dynamic> parentRow,
  }) async {
    final contextValues = _getSectionContext(sectionId);
    final remainingMap =
        (contextValues['movimientos_detalle_remaining'] as Map?)
            ?.cast<String, double>() ??
        const <String, double>{};
    if (remainingMap.isEmpty) return;
    final detailInlineId = _inlineDetailIdForSection(sectionId);
    final inlineConfig = _inlineConfigResolver(sectionId, detailInlineId);
    final targetSectionId = inlineConfig?.formSectionId;
    if (inlineConfig == null || targetSectionId == null) return;
    await _referenceLoader(targetSectionId);
    final entries = remainingMap.entries
        .where((entry) => entry.value > 0.0001)
        .toList();
    if (entries.isEmpty) return;
    for (final entry in entries) {
      final values = {'idproducto': entry.key, 'cantidad': entry.value};
      _inlineDraftService.addPendingInlineRow(
        sectionId,
        inlineConfig,
        values,
        targetSectionId,
      );
    }
    prepareMovementDetailContext(sectionId, parentRow);
    if (_mountedResolver()) {
      _setState(() {});
    }
  }

  void invalidateCoverage(
    String? documentId, {
    MovementDocumentType type = MovementDocumentType.pedido,
  }) {
    final id = documentId ?? '';
    if (id.isEmpty) return;
    final key = _coverageKey(type, id);
    _coverageCache.remove(key);
    _pendingCoverage.remove(key);
  }

  String? resolvePedidoIdFromMovement(
    String sectionId,
    Map<String, dynamic> row,
  ) {
    final direct = row['idpedido']?.toString();
    debugPrint('[mov-det] resolve pedidoId direct=$direct section=$sectionId');
    if (direct != null && direct.isNotEmpty) return direct;
    final contextValues = _getSectionContext(sectionId);
    final contextId =
        contextValues['idpedido']?.toString() ??
        contextValues['movimiento_pedido_id']?.toString();
    debugPrint('[mov-det] resolve pedidoId context=$contextId');
    if (contextId != null && contextId.isNotEmpty) return contextId;
    return null;
  }

  String? resolveCompraIdFromMovement(
    String sectionId,
    Map<String, dynamic> row,
  ) {
    final direct = row['idcompra']?.toString();
    if (direct != null && direct.isNotEmpty) return direct;
    final contextValues = _getSectionContext(sectionId);
    final contextId =
        contextValues['idcompra']?.toString() ??
        contextValues['movimiento_compra_id']?.toString();
    if (contextId != null && contextId.isNotEmpty) return contextId;
    return null;
  }

  Map<String, double> pendingMovementDetailTotals(String sectionId) {
    return _pendingMovementDetailTotals(sectionId);
  }

  Map<String, double> pendingOrderDetailTotals() {
    return _pendingPedidoDetailTotals();
  }

  void _scheduleMovementCoverageLoad({
    required MovementDocumentType type,
    required String documentId,
    required String sectionId,
    required Map<String, dynamic> row,
  }) {
    final cacheKey = _coverageKey(type, documentId);
    if (_coverageCache.containsKey(cacheKey) ||
        _pendingCoverage.containsKey(cacheKey)) {
      return;
    }
    final future = _fetchMovementCoverage(documentId, type);
    _pendingCoverage[cacheKey] = future;
    future
        .then((coverage) {
          if (!_mountedResolver()) return;
          _setState(() {
            _coverageCache[cacheKey] = coverage;
            final currentRow = _sectionRowResolver(sectionId) ?? row;
            prepareMovementDetailContext(sectionId, currentRow);
          });
        })
        .catchError((error) {
          debugPrint('Error cargando cobertura $documentId tipo=$type: $error');
        })
        .whenComplete(() {
          _pendingCoverage.remove(cacheKey);
        });
  }

  Future<_MovementCoverage> _fetchMovementCoverage(
    String documentId,
    MovementDocumentType type,
  ) async {
    switch (type) {
      case MovementDocumentType.compra:
        final compraTotals = await _moduleRepository.fetchCompraDetalleTotals(
          documentId,
        );
        final assignedCompraTotals = await _moduleRepository
            .fetchCompraMovimientoDetalleTotals(documentId);
        return _MovementCoverage(
          orderTotals: compraTotals,
          assignedTotals: assignedCompraTotals,
        );
      case MovementDocumentType.pedido:
        final pedidoTotals = await _moduleRepository.fetchPedidoDetalleTotals(
          documentId,
        );
        final assignedTotals = await _moduleRepository
            .fetchMovimientoDetalleTotalsByPedido(documentId);
        return _MovementCoverage(
          orderTotals: pedidoTotals,
          assignedTotals: assignedTotals,
        );
      case MovementDocumentType.none:
        return const _MovementCoverage(
          orderTotals: <String, double>{},
          assignedTotals: <String, double>{},
        );
    }
  }

  Map<String, double> _calculateMovementRemaining(
    Map<String, double> orderTotals,
    Map<String, double> assignedTotals,
    Map<String, double> pendingTotals,
  ) {
    final result = <String, double>{};
    for (final entry in orderTotals.entries) {
      final productId = entry.key;
      final total = entry.value;
      final assigned = assignedTotals[productId] ?? 0;
      final pending = pendingTotals[productId] ?? 0;
      final remaining = total - assigned - pending;
      if (remaining > 0.0001) {
        result[productId] = double.parse(remaining.toStringAsFixed(2));
      }
    }
    return result;
  }

  Map<String, double> _pendingMovementDetailTotals(String sectionId) {
    final inlineId = _inlineDetailIdForSection(sectionId);
    final pendingRows = _inlineDraftService.findPendingRows(
      sectionId,
      inlineId,
    );
    final totals = <String, double>{};
    for (final row in pendingRows) {
      final raw = row.rawValues;
      final productId = raw['idproducto']?.toString();
      if (productId == null || productId.isEmpty) continue;
      final quantity = raw['cantidad'];
      final parsed = quantity is num
          ? quantity.toDouble()
          : double.tryParse(quantity?.toString() ?? '') ?? 0;
      if (parsed <= 0) continue;
      totals[productId] = (totals[productId] ?? 0) + parsed;
    }
    return totals;
  }

  Map<String, double> _pendingMovementDetailTotalsFromPedidoDraft({
    String? excludePendingId,
  }) {
    final pendingMovements = _inlineDraftService.findPendingRows(
      'pedidos_tabla',
      'pedidos_movimientos',
    );
    if (pendingMovements.isEmpty) return const {};
    final totals = <String, double>{};
    for (final movement in pendingMovements) {
      if (excludePendingId != null && movement.pendingId == excludePendingId) {
        continue;
      }
      final nested = movement.nestedInlineRows['movimientos_detalle'];
      if (nested == null || nested.isEmpty) continue;
      for (final detail in nested) {
        final raw = detail.rawValues;
        final productId = raw['idproducto']?.toString();
        if (productId == null || productId.isEmpty) continue;
        final quantity = raw['cantidad'];
        final parsed = quantity is num
            ? quantity.toDouble()
            : double.tryParse(quantity?.toString() ?? '') ?? 0;
        if (parsed <= 0) continue;
        totals[productId] = (totals[productId] ?? 0) + parsed;
      }
    }
    return totals;
  }

  Map<String, double> _pendingMovementDetailTotalsFromCompraDraft({
    String? excludePendingId,
  }) {
    final pendingMovements = _inlineDraftService.findPendingRows(
      'compras',
      'compras_movimientos',
    );
    if (pendingMovements.isEmpty) return const {};
    final totals = <String, double>{};
    for (final movement in pendingMovements) {
      if (excludePendingId != null && movement.pendingId == excludePendingId) {
        continue;
      }
      final nested = movement.nestedInlineRows['compras_movimiento_detalle'];
      if (nested == null || nested.isEmpty) continue;
      for (final detail in nested) {
        final raw = detail.rawValues;
        final productId = raw['idproducto']?.toString();
        if (productId == null || productId.isEmpty) continue;
        final quantity = raw['cantidad'];
        final parsed = quantity is num
            ? quantity.toDouble()
            : double.tryParse(quantity?.toString() ?? '') ?? 0;
        if (parsed <= 0) continue;
        totals[productId] = (totals[productId] ?? 0) + parsed;
      }
    }
    return totals;
  }

  Map<String, double> _pendingPedidoDetailTotals() {
    final pendingRows = _inlineDraftService.findPendingRows(
      'pedidos_tabla',
      'pedidos_detalle',
    );
    final totals = <String, double>{};
    for (final row in pendingRows) {
      final raw = row.rawValues;
      final productId = raw['idproducto']?.toString();
      if (productId == null || productId.isEmpty) continue;
      final quantity = raw['cantidad'];
      final parsed = quantity is num
          ? quantity.toDouble()
          : double.tryParse(quantity?.toString() ?? '') ?? 0;
      if (parsed <= 0) continue;
      totals[productId] = (totals[productId] ?? 0) + parsed;
    }
    return totals;
  }

  Map<String, double> _pendingCompraDetailTotals() {
    final pendingRows = _inlineDraftService.findPendingRows(
      'compras',
      'compras_detalle',
    );
    final totals = <String, double>{};
    for (final row in pendingRows) {
      final raw = row.rawValues;
      final productId = raw['idproducto']?.toString();
      if (productId == null || productId.isEmpty) continue;
      final quantity = raw['cantidad'];
      final parsed = quantity is num
          ? quantity.toDouble()
          : double.tryParse(quantity?.toString() ?? '') ?? 0;
      if (parsed <= 0) continue;
      totals[productId] = (totals[productId] ?? 0) + parsed;
    }
    return totals;
  }
}

class _MovementCoverage {
  const _MovementCoverage({
    required this.orderTotals,
    required this.assignedTotals,
  });

  final Map<String, double> orderTotals;
  final Map<String, double> assignedTotals;
}
