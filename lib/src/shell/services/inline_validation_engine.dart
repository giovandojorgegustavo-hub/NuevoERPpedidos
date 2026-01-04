import 'package:erp_app/src/shared/inline_table/inline_parsers.dart';
import 'package:erp_app/src/shared/inline_table/inline_validation.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';

/// Encapsula validaciones de negocio reutilizables para flujos inline.
class InlineValidationEngine {
  InlineValidationEngine({
    required InlineDraftService inlineDraftService,
    required ModuleRepository moduleRepository,
  })  : _inlineDraftService = inlineDraftService,
        _moduleRepository = moduleRepository;

  final InlineDraftService _inlineDraftService;
  final ModuleRepository _moduleRepository;

  String? validateUniqueCompraProducto({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
    required String productId,
    String? excludePendingId,
    dynamic excludeRowId,
  }) {
    if (productId.isEmpty) return null;
    final persistedRows = _persistedInlineRows(
      parentSectionId: parentSectionId,
      parentRow: parentRow,
      inlineId: inline.id,
    );
    final pendingRows = _inlineDraftService.findPendingRows(
      parentSectionId,
      inline.id,
    );
    final duplicated = isInlineValueDuplicated(
      persistedRows: persistedRows,
      pendingRows: pendingRows,
      fieldName: 'idproducto',
      value: productId,
      excludePendingId: excludePendingId,
      excludeRowId: excludeRowId,
    );
    if (!duplicated) return null;
    final friendly = inline.title.toLowerCase();
    return 'Ya agregaste este producto en $friendly.';
  }

  String? validateUniqueViajeMovimiento({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
    required String movimientoId,
    String? excludePendingId,
    dynamic excludeRowId,
  }) {
    if (movimientoId.isEmpty) return null;
    final persistedRows = _persistedInlineRows(
      parentSectionId: parentSectionId,
      parentRow: parentRow,
      inlineId: inline.id,
    );
    final pendingRows = _inlineDraftService.findPendingRows(
      parentSectionId,
      inline.id,
    );
    final duplicated = isInlineValueDuplicated(
      persistedRows: persistedRows,
      pendingRows: pendingRows,
      fieldName: 'idmovimiento',
      value: movimientoId,
      excludePendingId: excludePendingId,
      excludeRowId: excludeRowId,
    );
    if (!duplicated) return null;
    return 'Ya agregaste este movimiento en el viaje.';
  }

  String? validateUniqueFabricacionProducto({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
    required String productId,
    String? excludePendingId,
    dynamic excludeRowId,
  }) {
    if (productId.isEmpty) return null;
    final persistedRows = _persistedInlineRows(
      parentSectionId: parentSectionId,
      parentRow: parentRow,
      inlineId: inline.id,
    );
    final pendingRows = _inlineDraftService.findPendingRows(
      parentSectionId,
      inline.id,
    );
    final duplicated = isInlineValueDuplicated(
      persistedRows: persistedRows,
      pendingRows: pendingRows,
      fieldName: 'idproducto',
      value: productId,
      excludePendingId: excludePendingId,
      excludeRowId: excludeRowId,
    );
    if (!duplicated) return null;
    final friendly = inline.title.toLowerCase();
    return 'Ya agregaste este producto en $friendly.';
  }

  Future<String?> validateMaquilaConsumoStock({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
    required Map<String, String> values,
    String? excludePendingId,
    dynamic excludeRowId,
  }) async {
    final baseId = parentRow['idbase']?.toString();
    if (baseId == null || baseId.isEmpty) {
      return 'Selecciona una base antes de registrar materiales.';
    }
    final productId = values['idproducto']?.toString() ?? '';
    if (productId.isEmpty) {
      return 'Selecciona un producto.';
    }
    final cantidad = parseInlineNumber(values['cantidad']);
    if (cantidad <= 0) {
      return 'Ingresa una cantidad válida.';
    }
    final stockRows =
        await _moduleRepository.fetchStockDisponiblePorBase(baseId);
    double disponible = 0;
    for (final row in stockRows) {
      final rowProductId = row['id']?.toString();
      if (rowProductId == productId) {
        disponible = parseInlineNumber(row['cantidad_disponible']);
        break;
      }
    }
    if (disponible <= 0) {
      return 'No hay stock disponible para este producto en la base seleccionada.';
    }
    double consumido = 0;
    final persisted = _persistedInlineRows(
      parentSectionId: parentSectionId,
      parentRow: parentRow,
      inlineId: inline.id,
    );
    for (final row in persisted) {
      if (excludeRowId != null && row['id'] == excludeRowId) continue;
      final rowProduct = row['idproducto']?.toString();
      if (rowProduct != productId) continue;
      consumido += parseInlineNumber(row['cantidad']);
    }
    final pendingRows = _inlineDraftService.findPendingRows(
      parentSectionId,
      inline.id,
    );
    for (final pending in pendingRows) {
      if (excludePendingId != null && pending.pendingId == excludePendingId) {
        continue;
      }
      final pendingProduct = pending.rawValues['idproducto']?.toString();
      if (pendingProduct != productId) continue;
      consumido += parseInlineNumber(pending.rawValues['cantidad']);
    }
    final remaining = disponible - consumido;
    if (cantidad - remaining > 0.0001) {
      if (remaining <= 0) {
        return 'Ya no queda stock disponible para este producto.';
      }
      return 'Solo quedan ${remaining.toStringAsFixed(2)} unidades disponibles.';
    }
    return null;
  }

  List<Map<String, dynamic>> _persistedInlineRows({
    required String parentSectionId,
    required Map<String, dynamic> parentRow,
    required String inlineId,
  }) {
    final parentId = parentRow['id'];
    if (parentId == null) return const [];
    final key = _inlineDraftService.inlineKey(
      parentSectionId,
      parentId,
      inlineId,
    );
    final rows = _inlineDraftService.inlineSectionData[key];
    if (rows == null || rows.isEmpty) return const [];
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }
}
