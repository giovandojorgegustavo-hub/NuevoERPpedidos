import 'package:erp_app/src/domains/movimientos/movimiento_coverage_service.dart';
import 'package:erp_app/src/shared/inline_table/inline_parsers.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';

class InlineStockResult {
  const InlineStockResult({this.stockByProduct, this.message});

  final Map<String, double>? stockByProduct;
  final String? message;
}

/// Centraliza validaciones de stock relacionadas a flujos inline.
class InlineStockValidator {
  InlineStockValidator({
    required ModuleRepository moduleRepository,
    required InlineDraftService inlineDraftService,
    required MovimientoCoverageService movimientoCoverageService,
  })  : _moduleRepository = moduleRepository,
        _inlineDraftService = inlineDraftService,
        _movimientoCoverageService = movimientoCoverageService;

  final ModuleRepository _moduleRepository;
  final InlineDraftService _inlineDraftService;
  final MovimientoCoverageService _movimientoCoverageService;
  final Map<String, String> _lastValidatedBase = {};

  Future<String?> validateMovimientoBaseSelection({
    required String sectionId,
    required Map<String, String>? values,
  }) async {
    if (sectionId != 'movimientos' && sectionId != 'pedidos_movimientos') {
      _lastValidatedBase.remove(sectionId);
      return null;
    }
    if (values == null) {
      _lastValidatedBase.remove(sectionId);
      return null;
    }
    final baseId = values['idbase']?.trim() ?? '';
    if (baseId.isEmpty) {
      _lastValidatedBase.remove(sectionId);
      return null;
    }
    final remaining =
        _movimientoCoverageService.movementRemainingForSection(sectionId);
    if (remaining == null || remaining.isEmpty) return null;
    final previous = _lastValidatedBase[sectionId];
    if (previous == baseId) return null;
    _lastValidatedBase[sectionId] = baseId;

    final stockByProduct = await _loadStockByProduct(baseId);
    final missing = <String, double>{};
    remaining.forEach((productId, qty) {
      final available = stockByProduct[productId] ?? 0;
      if (available + 0.0001 < qty) {
        missing[productId] = qty - available;
      }
    });
    if (missing.isEmpty) return null;

    final productNames =
        await _moduleRepository.fetchProductNames(missing.keys);
    final summary = missing.entries.map((entry) {
      final name = productNames[entry.key] ?? entry.key;
      return '$name (faltan ${_formatStockQuantity(entry.value)})';
    }).join(', ');
    return 'La base seleccionada no tiene stock suficiente para completar el pedido: $summary.';
  }

  Future<String?> ensurePedidoBaseHasStock({
    required Map<String, dynamic>? pedidoRow,
    required Map<String, String> values,
    String? pedidoIdFallback,
  }) async {
    final baseId = values['idbase']?.trim() ?? '';
    if (baseId.isEmpty) return null;
    final pedidoTotals = <String, double>{};
    final pedidoId =
        pedidoRow?['id']?.toString().trim() ?? pedidoIdFallback?.trim() ?? '';
    if (pedidoId.isNotEmpty) {
      final persistedTotals =
          await _moduleRepository.fetchPedidoDetalleTotals(pedidoId);
      if (persistedTotals.isNotEmpty) {
        pedidoTotals.addAll(persistedTotals);
      }
    }
    final draftTotals = pedidoRow != null
        ? _pendingPedidoDraftTotals()
        : const <String, double>{};
    if (draftTotals.isNotEmpty) {
      draftTotals.forEach((productId, qty) {
        pedidoTotals[productId] = (pedidoTotals[productId] ?? 0) + qty;
      });
    }
    if (pedidoTotals.isEmpty) return null;
    final stockByProduct = await _loadStockByProduct(baseId);
    final missing = <String, double>{};
    pedidoTotals.forEach((productId, qty) {
      final available = stockByProduct[productId] ?? 0;
      if (available + 0.0001 < qty) {
        missing[productId] = qty - available;
      }
    });
    if (missing.isEmpty) return null;

    final productNames =
        await _moduleRepository.fetchProductNames(missing.keys);
    final summary = missing.entries.map((entry) {
      final name = productNames[entry.key] ?? entry.key;
      return '$name (faltan ${_formatStockQuantity(entry.value)})';
    }).join(', ');
    return 'La base seleccionada no tiene stock suficiente para cubrir los productos del pedido: $summary.';
  }

  Future<InlineStockResult> ensureMovimientoBaseReady({
    required String baseId,
    Map<String, double>? movementRemaining,
  }) async {
    if (baseId.isEmpty) {
      return const InlineStockResult(
        message: 'Selecciona una base antes de agregar productos al movimiento.',
      );
    }
    final stockByProduct = await _loadStockByProduct(baseId);
    if (stockByProduct.isEmpty) {
      return const InlineStockResult(
        message: 'La base seleccionada no tiene stock disponible actualmente.',
      );
    }
    if (movementRemaining != null && movementRemaining.isNotEmpty) {
      final missing = <String, double>{};
      movementRemaining.forEach((productId, requiredQty) {
        if (requiredQty <= 0) return;
        final available = stockByProduct[productId] ?? 0;
        if (available + 0.0001 < requiredQty) {
          missing[productId] = requiredQty - available;
        }
      });
      if (missing.isNotEmpty) {
        final productNames =
            await _moduleRepository.fetchProductNames(missing.keys);
        final summary = missing.entries.map((entry) {
          final name = productNames[entry.key] ?? entry.key;
          return '$name (faltan ${_formatStockQuantity(entry.value)})';
        }).join(', ');
        return InlineStockResult(
          stockByProduct: stockByProduct,
          message: 'La base seleccionada no tiene stock suficiente para: $summary.',
        );
      }
    }
    return InlineStockResult(stockByProduct: stockByProduct);
  }

  Map<String, double> _pendingPedidoDraftTotals() {
    final pendingRows = _inlineDraftService.findPendingRows(
      'pedidos_tabla',
      'pedidos_detalle',
    );
    if (pendingRows.isEmpty) return const <String, double>{};
    final totals = <String, double>{};
    for (final row in pendingRows) {
      final raw = row.rawValues;
      final productId = raw['idproducto']?.toString();
      if (productId == null || productId.isEmpty) continue;
      final quantity = parseInlineNumber(raw['cantidad']);
      if (quantity <= 0) continue;
      totals[productId] = (totals[productId] ?? 0) + quantity;
    }
    return totals;
  }

  Future<Map<String, double>> _loadStockByProduct(String baseId) async {
    final stockRows =
        await _moduleRepository.fetchStockDisponiblePorBase(baseId);
    final stockByProduct = <String, double>{};
    for (final row in stockRows) {
      final productId = row['id']?.toString();
      if (productId == null || productId.isEmpty) continue;
      stockByProduct[productId] = parseInlineNumber(
        row['cantidad_disponible'],
      );
    }
    return stockByProduct;
  }

  String _formatStockQuantity(double value) {
    final absValue = value.abs();
    if ((absValue - absValue.round()).abs() < 0.0001) {
      return absValue.round().toString();
    }
    return absValue.toStringAsFixed(2);
  }
}
