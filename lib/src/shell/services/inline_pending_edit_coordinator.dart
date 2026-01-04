import 'package:flutter/material.dart';

import 'package:erp_app/src/domains/movimientos/movimiento_coverage_service.dart';
import 'package:erp_app/src/domains/pedidos/pedido_pago_coordinator.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/reference_form_page.dart';
import 'package:erp_app/src/shell/section_form_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_context_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/services/inline_navigation_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_validation_engine.dart';

class InlinePendingEditCoordinator {
  InlinePendingEditCoordinator({
    required InlineDraftService inlineDraftService,
    required SectionStateController sectionStateController,
    required InlineContextCoordinator inlineContextCoordinator,
    required InlineValidationEngine inlineValidationEngine,
    required SectionFormCoordinator sectionFormCoordinator,
    required PedidoPagoCoordinator pedidoPagoCoordinator,
    required MovimientoCoverageService movimientoCoverageService,
    required Future<void> Function(String sectionId)
        loadReferenceOptionsForSection,
    required InlineTablesBuilder buildInlineTablesWithContext,
    required FormConfigBuilderResolver formConfigBuilderResolver,
    required ContextProvider contextProvider,
    required bool Function() mountedResolver,
    required void Function(String message) showMessage,
    required void Function(void Function()) stateSetter,
    required EnsureSectionValidation ensureSectionValidation,
    required ValidateUniqueInlineProduct validateUniqueInlineProduct,
  })  : _inlineDraftService = inlineDraftService,
        _sectionStateController = sectionStateController,
        _inlineContextCoordinator = inlineContextCoordinator,
        _inlineValidationEngine = inlineValidationEngine,
        _sectionFormCoordinator = sectionFormCoordinator,
        _pedidoPagoCoordinator = pedidoPagoCoordinator,
        _movimientoCoverageService = movimientoCoverageService,
        _loadReferenceOptionsForSection = loadReferenceOptionsForSection,
        _buildInlineTablesWithContext = buildInlineTablesWithContext,
        _formConfigBuilderResolver = formConfigBuilderResolver,
        _contextProvider = contextProvider,
        _mountedResolver = mountedResolver,
        _showMessage = showMessage,
        _stateSetter = stateSetter,
        _ensureSectionValidation = ensureSectionValidation,
        _validateUniqueInlineProduct = validateUniqueInlineProduct;

  final InlineDraftService _inlineDraftService;
  final SectionStateController _sectionStateController;
  final InlineContextCoordinator _inlineContextCoordinator;
  final InlineValidationEngine _inlineValidationEngine;
  final SectionFormCoordinator _sectionFormCoordinator;
  final PedidoPagoCoordinator _pedidoPagoCoordinator;
  final MovimientoCoverageService _movimientoCoverageService;
  final Future<void> Function(String sectionId) _loadReferenceOptionsForSection;
  final InlineTablesBuilder _buildInlineTablesWithContext;
  final FormConfigBuilderResolver _formConfigBuilderResolver;
  final ContextProvider _contextProvider;
  final bool Function() _mountedResolver;
  final void Function(String message) _showMessage;
  final void Function(void Function()) _stateSetter;
  final EnsureSectionValidation _ensureSectionValidation;
  final ValidateUniqueInlineProduct _validateUniqueInlineProduct;

  Future<void> editPendingInlineRow({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required InlineTableRow row,
  }) async {
    final formBuilder = _formConfigBuilderResolver();
    if (formBuilder == null) return;
    final pendingId = row.pendingId;
    if (pendingId == null) return;
    final pendingEntry = _inlineDraftService.findPendingInlineRow(
      parentSectionId,
      inline.id,
      pendingId,
    );
    if (pendingEntry == null) return;
    final targetSectionId = inline.formSectionId;
    if (targetSectionId == null) return;
    bool shouldClearViajeContext = false;
    if (targetSectionId == 'viajes_detalle') {
      final parentRow =
          _sectionStateController.sectionSelectedRows[parentSectionId];
      final ready = _inlineContextCoordinator.prepareViajeDetalleContext(
        parentSectionId,
        parentRow,
      );
      if (!ready) return;
      shouldClearViajeContext = true;
    }
    await _loadReferenceOptionsForSection(targetSectionId);
    try {
      final defaults = Map<String, dynamic>.from(pendingEntry.rawValues);
      _inlineDraftService.restoreNestedDraftsForEdit(
        targetSectionId,
        pendingEntry,
      );
      final fields = formBuilder.buildFields(
        targetSectionId,
        defaults,
        SectionFormMode.edit,
      );
      if (fields == null) {
        _showMessage('No hay campos configurados para ${inline.title}.');
        _inlineDraftService.captureNestedDraftsAfterEdit(
          targetSectionId,
          pendingEntry,
        );
        return;
      }
      final inlineTables = _buildInlineTablesWithContext(
        targetSectionId,
        defaults,
        forForm: true,
        formMode: SectionFormMode.edit,
      );
      if (!_mountedResolver()) return;
      final result = await Navigator.of(_contextProvider())
          .push<Map<String, dynamic>>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) {
                final config = FormViewConfig(
                  title: 'Editar ${inline.title.toLowerCase()}',
                  fields: fields,
                  inlineTables: inlineTables,
                  onSubmit: (values) async {
                    if (!_ensureSectionValidation(
                      targetSectionId,
                      values,
                      feedbackContext: context,
                    )) {
                      return;
                    }
                    if (inline.id == 'fabricaciones_maquila_consumos') {
                      final stockError = await _inlineValidationEngine
                          .validateMaquilaConsumoStock(
                        parentSectionId: parentSectionId,
                        inline: inline,
                        parentRow: _sectionStateController
                                .sectionSelectedRows[parentSectionId] ??
                            const <String, dynamic>{},
                        values: values,
                        excludePendingId: pendingId,
                      );
                      if (stockError != null) {
                        _showMessage(stockError);
                        return;
                      }
                    }
                    final cleaned = _sectionFormCoordinator.preparePayload(
                      values,
                      sectionId: targetSectionId,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop(cleaned);
                  },
                  onCancel: () => Navigator.of(context).pop(),
                  saveLabel: 'Guardar',
                  cancelLabel: 'Cancelar',
                );
                return ReferenceFormPage(
                  title: inline.title,
                  config: config,
                  refreshListenable: _inlineDraftService.refreshNotifier,
                );
              },
            ),
          );
      _inlineDraftService.captureNestedDraftsAfterEdit(
        targetSectionId,
        pendingEntry,
      );
      if (result == null) return;
      String? uniqueField;
      if (inline.id == 'viajes_detalle') {
        uniqueField = 'idmovimiento';
      } else if (inline.id == 'movimientos_detalle' ||
          inline.id == 'pedidos_detalle' ||
          inline.id == 'compras_detalle' ||
          inline.id == 'compras_movimiento_detalle' ||
          inline.id == 'fabricaciones_internas_resultados') {
        uniqueField = 'idproducto';
      }
      if (uniqueField != null) {
        final parentRow =
            _sectionStateController.sectionSelectedRows[parentSectionId] ??
            const <String, dynamic>{};
        final uniqueValue = result[uniqueField]?.toString().trim() ?? '';
        if (!_validateUniqueInlineProduct(
          parentSectionId: parentSectionId,
          inline: inline,
          parentRow: parentRow,
          itemId: uniqueValue,
          excludePendingId: pendingEntry.pendingId,
        )) {
          return;
        }
      }
      if (inline.id == 'pedidos_pagos') {
        final parentRow =
            _sectionStateController.sectionSelectedRows[parentSectionId] ??
            const <String, dynamic>{};
        final amount = _pedidoPagoCoordinator.parseAmount(result['monto']);
        final error = _pedidoPagoCoordinator.validatePagoAmount(
          parentRow: parentRow,
          amount: amount,
          excludePendingId: pendingEntry.pendingId,
        );
        if (error != null) {
          _showMessage(error);
          return;
        }
      }
      pendingEntry.rawValues
        ..clear()
        ..addAll(Map<String, dynamic>.from(result));
      final display = _inlineDraftService.buildPendingDisplayValues(
        inline,
        result,
        targetSectionId,
      );
      pendingEntry.displayValues
        ..clear()
        ..addAll(display);
      pendingEntry.tableValues
        ..clear()
        ..addAll(display);
      _stateSetter(() {});
      _inlineDraftService.notifyInlineDataChanged();
      if (inline.id == 'movimientos_detalle') {
        final currentRow =
            _sectionStateController.sectionSelectedRows[parentSectionId];
        if (currentRow != null) {
          _movimientoCoverageService.prepareMovementDetailContext(
            parentSectionId,
            currentRow,
          );
        }
      } else if (inline.id == 'pedidos_pagos') {
        final currentPedido =
            _sectionStateController.sectionSelectedRows[parentSectionId];
        if (currentPedido != null) {
          _inlineContextCoordinator.preparePedidoPagoContext(currentPedido);
        }
      }
    } finally {
      if (shouldClearViajeContext) {
        _inlineContextCoordinator.clearViajeDetalleContext();
      }
    }
  }
}
