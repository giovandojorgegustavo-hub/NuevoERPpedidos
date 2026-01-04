import 'package:erp_app/src/domains/movimientos/movimiento_coverage_service.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shared/utils/date_time_utils.dart'
    as date_time_utils;
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/services/inline_context_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_creation_policy.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (_isFabricacionCancelada(parentSectionId, parentRow)) {
      _showMessage('No puedes modificar una fabricación cancelada.');
      return;
    }
    if (parentSectionId == 'compras' &&
        _inlineCreationPolicy.compraCancelada(parentRow)) {
      _showMessage('No puedes modificar una compra cancelada.');
      return;
    }
    if (inline.id == 'compras_detalle' &&
        _inlineCreationPolicy.compraDetalleCerrado(parentRow)) {
      _showMessage('No puedes modificar el detalle de una compra cerrada.');
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
    if (inline.id == 'compras_detalle' &&
        _inlineCreationPolicy.compraTieneMovimientos(parentRow) &&
        persistedIds.isNotEmpty) {
      _showMessage(
        'No puedes modificar el detalle de una compra con movimientos.',
      );
      return;
    }
    if (inline.id == 'compras_movimiento_detalle' && persistedIds.isNotEmpty) {
      _showMessage('No puedes modificar el detalle de un movimiento cerrado.');
      return;
    }
    final fallbackRow = parentRow.isNotEmpty ? parentRow : null;
    if (inline.id == 'compras_pagos' && persistedIds.isNotEmpty) {
      final reversibleIds = rows
          .where(
            (row) =>
                row['__pending'] != true &&
                row['estado']?.toString().toLowerCase().trim() != 'reversado',
          )
          .map((row) => row['id'])
          .whereType<dynamic>()
          .toList(growable: false);
      if (reversibleIds.isEmpty) {
        _showMessage('No hay pagos pendientes de reversa.');
        return;
      }
      for (final pagoId in reversibleIds) {
        await _moduleRepository.callRpc(
          'fn_compras_pagos_reversar',
          params: {'p_pago_id': pagoId},
        );
      }
      await _refreshParentSection(parentSectionId);
      if (fallbackRow != null) {
        await _inlineDraftService.loadInlineSectionsForRow(
          parentSectionId,
          fallbackRow,
        );
      }
      return;
    }
    if (inline.id == 'compras_movimientos' && persistedIds.isNotEmpty) {
      final reversibleIds = rows
          .where(
            (row) =>
                row['__pending'] != true && !_isTrue(row['es_reversion']),
          )
          .map((row) => row['id'])
          .whereType<dynamic>()
          .toList(growable: false);
      if (reversibleIds.isEmpty) {
        _showMessage('No hay movimientos pendientes de reversa.');
        return;
      }
      for (final movimientoId in reversibleIds) {
        await _moduleRepository.callRpc(
          'fn_compras_movimiento_reversar',
          params: {'p_movimiento_id': movimientoId},
        );
      }
      await _refreshParentSection(parentSectionId);
      if (fallbackRow != null) {
        await _inlineDraftService.loadInlineSectionsForRow(
          parentSectionId,
          fallbackRow,
        );
      }
      return;
    }
    if (inline.id == 'pedidos_detalle' && persistedIds.isNotEmpty) {
      if (targetSectionId == null) return;
      final dataSource =
          _sectionStateController.sectionDataSources[targetSectionId];
      if (dataSource == null) return;
      final nowIso = date_time_utils.currentUtcIsoString();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      for (final row in rows) {
        if (row['__pending'] == true) continue;
        final id = row['id'];
        if (id == null) continue;
        await _moduleRepository.updateRow(dataSource, id, {
          'estado': 'cancelado',
          'editado_at': nowIso,
          if (userId != null) 'editado_por': userId,
        });
      }
      await _refreshParentSection(parentSectionId);
      if (fallbackRow != null) {
        await _inlineDraftService.loadInlineSectionsForRow(
          parentSectionId,
          fallbackRow,
        );
      }
      return;
    }
    if (inline.id == 'pedidos_pagos' && persistedIds.isNotEmpty) {
      if (targetSectionId == null) return;
      final dataSource =
          _sectionStateController.sectionDataSources[targetSectionId];
      if (dataSource == null) return;
      final nowIso = date_time_utils.currentUtcIsoString();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      for (final row in rows) {
        if (row['__pending'] == true) continue;
        final id = row['id'];
        if (id == null) continue;
        await _moduleRepository.updateRow(dataSource, id, {
          'estado': 'cancelado',
          'editado_at': nowIso,
          if (userId != null) 'editado_por': userId,
        });
      }
      await _refreshParentSection(parentSectionId);
      if (fallbackRow != null) {
        await _inlineDraftService.loadInlineSectionsForRow(
          parentSectionId,
          fallbackRow,
        );
      }
      final currentPedido =
          _sectionStateController.sectionSelectedRows[parentSectionId];
      if (currentPedido != null) {
        _inlineContextCoordinator.preparePedidoPagoContext(currentPedido);
        _stateSetter(() {});
      }
      return;
    }
    if (inline.id == 'pedidos_movimientos' && persistedIds.isNotEmpty) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      for (final movimientoId in persistedIds) {
        await _moduleRepository.callRpc(
          'fn_pedidos_movimiento_cancelar',
          params: {
            'p_movimiento_id': movimientoId,
            if (userId != null) 'p_usuario': userId,
          },
        );
      }
      await _refreshParentSection(parentSectionId);
      if (fallbackRow != null) {
        await _inlineDraftService.loadInlineSectionsForRow(
          parentSectionId,
          fallbackRow,
        );
      }
      final pedidoId = parentRow['id']?.toString();
      if (pedidoId != null && pedidoId.isNotEmpty) {
        _movimientoCoverageService.invalidateCoverage(pedidoId);
      }
      return;
    }
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

  bool _isTrue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim() ?? '';
    return text == 'true' || text == '1';
  }

  bool _isFabricacionCancelada(String sectionId, Map<String, dynamic> row) {
    if (sectionId != 'fabricaciones_internas' &&
        sectionId != 'fabricaciones_maquila') {
      return false;
    }
    final estadoRaw = row['estado_codigo'] ?? row['estado'];
    final estado = estadoRaw?.toString().toLowerCase().trim();
    return estado == 'cancelado';
  }
}
