import 'package:erp_app/src/domains/movimientos/movimiento_coverage_service.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/services/inline_context_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_creation_policy.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';

class InlineBulkDeleteCoordinator {
  InlineBulkDeleteCoordinator({
    required InlineDraftService inlineDraftService,
    required SectionStateController sectionStateController,
    required ModuleRepository moduleRepository,
    required InlineCreationPolicy inlineCreationPolicy,
    required MovimientoCoverageService movimientoCoverageService,
    required InlineContextCoordinator inlineContextCoordinator,
    required void Function(void Function()) stateSetter,
    required Future<void> Function(String parentSectionId) refreshParentSection,
    required void Function(String message) showMessage,
  })  : _inlineDraftService = inlineDraftService,
        _sectionStateController = sectionStateController,
        _moduleRepository = moduleRepository,
        _inlineCreationPolicy = inlineCreationPolicy,
        _movimientoCoverageService = movimientoCoverageService,
        _inlineContextCoordinator = inlineContextCoordinator,
        _stateSetter = stateSetter,
        _refreshParentSection = refreshParentSection,
        _showMessage = showMessage;

  final InlineDraftService _inlineDraftService;
  final SectionStateController _sectionStateController;
  final ModuleRepository _moduleRepository;
  final InlineCreationPolicy _inlineCreationPolicy;
  final MovimientoCoverageService _movimientoCoverageService;
  final InlineContextCoordinator _inlineContextCoordinator;
  final void Function(void Function()) _stateSetter;
  final Future<void> Function(String parentSectionId) _refreshParentSection;
  final void Function(String message) _showMessage;

  Future<void> bulkDelete({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required List<TableRowData> rows,
    required Map<String, dynamic> parentRow,
  }) async {
    final targetSectionId = inline.formSectionId;
    final List<dynamic> persistedIds = [];
    final List<String> pendingIds = [];
    if (inline.id == 'compras_detalle' &&
        _inlineCreationPolicy.compraTieneMovimientos(parentRow)) {
      _showMessage(
        'No puedes eliminar productos del detalle de una compra con movimientos.',
      );
      return;
    }
    for (final row in rows) {
      if (row['__pending'] == true) {
        final pendingId = row['__pending_id']?.toString();
        if (pendingId != null) pendingIds.add(pendingId);
      } else {
        final id = row['id'];
        if (id != null) persistedIds.add(id);
      }
    }
    if (pendingIds.isNotEmpty) {
      _inlineDraftService.removePendingRows(
        sectionId: parentSectionId,
        inlineId: inline.id,
        pendingIds: pendingIds,
      );
    }
    final fallbackRow = parentRow.isNotEmpty ? parentRow : null;
    if (persistedIds.isNotEmpty && targetSectionId != null) {
      final dataSource =
          _sectionStateController.sectionDataSources[targetSectionId];
      if (dataSource != null) {
        await _moduleRepository.deleteRows(dataSource, persistedIds);
        final currentRow =
            _sectionStateController.sectionSelectedRows[parentSectionId] ??
            fallbackRow;
        if (currentRow != null) {
          await _inlineDraftService.loadInlineSectionsForRow(
            parentSectionId,
            currentRow,
          );
        }
      }
      await _refreshParentSection(parentSectionId);
    }
    if (inline.id == 'movimientos_detalle' ||
        inline.id == 'compras_movimiento_detalle') {
      final currentRow =
          _sectionStateController.sectionSelectedRows[parentSectionId] ??
          fallbackRow;
      if (currentRow != null) {
        _movimientoCoverageService.prepareMovementDetailContext(
          parentSectionId,
          currentRow,
        );
        _stateSetter(() {});
      }
    } else if (inline.id == 'pedidos_pagos') {
      final currentPedido =
          _sectionStateController.sectionSelectedRows[parentSectionId];
      if (currentPedido != null) {
        _inlineContextCoordinator.preparePedidoPagoContext(currentPedido);
        _stateSetter(() {});
      }
    }
  }
}
