import 'package:erp_app/src/domains/movimientos/movimiento_coverage_service.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_service.dart';
import 'package:erp_app/src/recursos/movimientos_constants.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/models.dart';

class MovimientoInlineCoordinator {
  const MovimientoInlineCoordinator({
    required MovimientoService movimientoService,
    required MovimientoCoverageService movimientoCoverageService,
    required InlineDraftService inlineDraftService,
    required void Function(
      String sectionId,
      String fieldId,
      Map<String, dynamic>? filter,
    )
    referenceFilterSetter,
  }) : _movimientoService = movimientoService,
       _movimientoCoverageService = movimientoCoverageService,
       _inlineDraftService = inlineDraftService,
       _referenceFilterSetter = referenceFilterSetter;

  final MovimientoService _movimientoService;
  final MovimientoCoverageService _movimientoCoverageService;
  final InlineDraftService _inlineDraftService;
  final void Function(
    String sectionId,
    String fieldId,
    Map<String, dynamic>? filter,
  )
  _referenceFilterSetter;

  bool isMovementSection(String sectionId) =>
      _movimientoCoverageService.isMovementSection(sectionId);

  void prepareMovementDetailContext(
    String sectionId,
    Map<String, dynamic> row,
  ) {
    _movimientoCoverageService.prepareMovementDetailContext(sectionId, row);
  }

  Map<String, double>? movementRemainingForSection(String sectionId) {
    return _movimientoCoverageService.movementRemainingForSection(sectionId);
  }

  void invalidateCoverage(
    String? documentId, {
    MovementDocumentType type = MovementDocumentType.pedido,
  }) {
    _movimientoCoverageService.invalidateCoverage(documentId, type: type);
  }

  void applyMovementReferenceFilters(
    String sectionId,
    String clientId, {
    String? baseId,
  }) {
    final filters = _movimientoService.buildClientReferenceFilters(
      clientId,
      baseId: baseId,
    );
    for (final entry in filters.entries) {
      _referenceFilterSetter(sectionId, entry.key, entry.value);
    }
  }

  void clearMovementReferenceFilters(String sectionId) {
    _referenceFilterSetter(sectionId, kMovDestinoLimaDireccionField, null);
    _referenceFilterSetter(sectionId, kMovDestinoLimaContactoField, null);
    _referenceFilterSetter(sectionId, kMovDestinoProvinciaDireccionField, null);
  }

  String? validateUniqueMovimientoProducto({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
    required String productId,
    String? excludePendingId,
    dynamic excludeRowId,
  }) {
    final persisted = _persistedInlineRows(
      parentSectionId,
      parentRow,
      inline.id,
    );
    final pending = _inlineDraftService.findPendingRows(
      parentSectionId,
      inline.id,
    );
    return _movimientoService.validateUniqueMovimientoProducto(
      persistedRows: persisted,
      pendingRows: pending,
      productId: productId,
      inlineTitle: inline.title,
      excludePendingId: excludePendingId,
      excludeRowId: excludeRowId,
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
