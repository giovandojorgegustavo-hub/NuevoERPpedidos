import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:erp_app/src/domains/movimientos/movimiento_coverage_service.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_service.dart';
import 'package:erp_app/src/domains/pedidos/pedido_inline_service.dart';
import 'package:erp_app/src/domains/pedidos/pedido_pago_coordinator.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/utils/date_time_utils.dart'
    as date_time_utils;
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/reference_form_page.dart';
import 'package:erp_app/src/shell/section_form_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_context_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_creation_policy.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/services/inline_navigation_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_stock_validator.dart';
import 'package:erp_app/src/shell/services/inline_validation_engine.dart';

class InlineCreateCoordinator {
  InlineCreateCoordinator({
    required InlineDraftService inlineDraftService,
    required SectionStateController sectionStateController,
    required SectionFormCoordinator sectionFormCoordinator,
    required MovimientoCoverageService movimientoCoverageService,
    required PedidoPagoCoordinator pedidoPagoCoordinator,
    required PedidoInlineService pedidoInlineService,
    required MovimientoService movimientoService,
    required InlineCreationPolicy inlineCreationPolicy,
    required InlineContextCoordinator inlineContextCoordinator,
    required InlineValidationEngine inlineValidationEngine,
    required InlineStockValidator inlineStockValidator,
    required Map<String, Map<String, String>> formDraftValues,
    required Future<void> Function(String sectionId)
        loadReferenceOptionsForSection,
    required InlineTablesBuilder buildInlineTablesWithContext,
    required FormConfigBuilderResolver formConfigBuilderResolver,
    required ContextProvider contextProvider,
    required bool Function() mountedResolver,
    required void Function(String message) showMessage,
    required void Function(void Function()) stateSetter,
    required Future<void> Function(String parentSectionId) refreshParentSection,
    required EnsureSectionValidation ensureSectionValidation,
    required ValidateUniqueInlineProduct validateUniqueInlineProduct,
    required Future<bool> Function({
      required Map<String, dynamic>? pedidoRow,
      required Map<String, String> values,
      String? pedidoIdFallback,
      VoidCallback? onInsufficientStock,
    })
        ensurePedidoBaseHasStock,
    required Map<String, String>? Function(
      String sectionId,
      Map<String, String> values, {
      bool programmaticChange,
    })
        movimientoDraftSanitizer,
  })  : _inlineDraftService = inlineDraftService,
        _sectionStateController = sectionStateController,
        _sectionFormCoordinator = sectionFormCoordinator,
        _movimientoCoverageService = movimientoCoverageService,
        _pedidoPagoCoordinator = pedidoPagoCoordinator,
        _pedidoInlineService = pedidoInlineService,
        _movimientoService = movimientoService,
        _inlineCreationPolicy = inlineCreationPolicy,
        _inlineContextCoordinator = inlineContextCoordinator,
        _inlineValidationEngine = inlineValidationEngine,
        _inlineStockValidator = inlineStockValidator,
        _formDraftValues = formDraftValues,
        _loadReferenceOptionsForSection = loadReferenceOptionsForSection,
        _buildInlineTablesWithContext = buildInlineTablesWithContext,
        _formConfigBuilderResolver = formConfigBuilderResolver,
        _contextProvider = contextProvider,
        _mountedResolver = mountedResolver,
        _showMessage = showMessage,
        _stateSetter = stateSetter,
        _refreshParentSection = refreshParentSection,
        _ensureSectionValidation = ensureSectionValidation,
        _validateUniqueInlineProduct = validateUniqueInlineProduct,
        _ensurePedidoBaseHasStock = ensurePedidoBaseHasStock,
        _movimientoDraftSanitizer = movimientoDraftSanitizer;

  final InlineDraftService _inlineDraftService;
  final SectionStateController _sectionStateController;
  final SectionFormCoordinator _sectionFormCoordinator;
  final MovimientoCoverageService _movimientoCoverageService;
  final PedidoPagoCoordinator _pedidoPagoCoordinator;
  final PedidoInlineService _pedidoInlineService;
  final MovimientoService _movimientoService;
  final InlineCreationPolicy _inlineCreationPolicy;
  final InlineContextCoordinator _inlineContextCoordinator;
  final InlineValidationEngine _inlineValidationEngine;
  final InlineStockValidator _inlineStockValidator;
  final Map<String, Map<String, String>> _formDraftValues;
  final Future<void> Function(String sectionId) _loadReferenceOptionsForSection;
  final InlineTablesBuilder _buildInlineTablesWithContext;
  final FormConfigBuilderResolver _formConfigBuilderResolver;
  final ContextProvider _contextProvider;
  final bool Function() _mountedResolver;
  final void Function(String message) _showMessage;
  final void Function(void Function()) _stateSetter;
  final Future<void> Function(String parentSectionId) _refreshParentSection;
  final EnsureSectionValidation _ensureSectionValidation;
  final ValidateUniqueInlineProduct _validateUniqueInlineProduct;
  final Future<bool> Function({
    required Map<String, dynamic>? pedidoRow,
    required Map<String, String> values,
    String? pedidoIdFallback,
    VoidCallback? onInsufficientStock,
  })
  _ensurePedidoBaseHasStock;
  final Map<String, String>? Function(
    String sectionId,
    Map<String, String> values, {
    bool programmaticChange,
  })
  _movimientoDraftSanitizer;

  static const Set<String> _inlineDraftParentIds = {
    'pedidos_detalle',
    'pedidos_movimientos',
    'pedidos_pagos',
    'movimientos_detalle',
    'viajes_detalle',
    'base_packings',
    'compras_detalle',
    'compras_pagos',
    'compras_movimientos',
    'compras_movimiento_detalle',
  };

  Future<void> createInline({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
    required bool forForm,
  }) async {
    final formBuilder = _formConfigBuilderResolver();
    if (formBuilder == null) return;
    if (_isFabricacionCancelada(parentSectionId, parentRow)) {
      _showMessage('No puedes modificar una fabricación cancelada.');
      return;
    }
    if (parentSectionId == 'compras' &&
        _inlineCreationPolicy.compraCancelada(parentRow)) {
      _showMessage('No puedes modificar una compra cancelada.');
      return;
    }
    bool shouldClearViajeContext = false;
    try {
      if (!_canCreatePedidoInline(parentSectionId, inline, parentRow)) {
        return;
      }
      if (!_canCreateCompraInline(parentSectionId, inline, parentRow)) {
        return;
      }
      final targetSectionId = inline.formSectionId;
      final foreignKeyField = inline.formForeignKeyField;
      if (targetSectionId == null || foreignKeyField == null) {
        _showMessage('No hay formulario configurado para ${inline.title}.');
        return;
      }
      shouldClearViajeContext = targetSectionId == 'viajes_detalle';
      Map<String, dynamic> effectiveParentRow = parentRow;
      var parentRowId = effectiveParentRow['id']?.toString();
      final bool supportsDraftParent = _inlineDraftParentIds.contains(
        inline.id,
      );
      final bool needsPersistedParent =
          !supportsDraftParent && (parentRowId == null || parentRowId.isEmpty);
      if (needsPersistedParent) {
        final draftValues =
            _formDraftValues[parentSectionId] ?? const <String, String>{};
        if (draftValues.isEmpty) {
          _showMessage('Guarda el formulario antes de continuar.');
          return;
        }
        final draftResult = await _sectionFormCoordinator.createDraftRow(
          parentSectionId,
          draftValues,
        );
        if (!draftResult.isSuccess) {
          if (draftResult.errorMessage != null) {
            _showMessage(draftResult.errorMessage!);
          }
          return;
        }
        final savedParent =
            _sectionStateController.sectionSelectedRows[parentSectionId];
        if (savedParent == null) return;
        effectiveParentRow = Map<String, dynamic>.from(savedParent);
        parentRowId = effectiveParentRow['id']?.toString();
      }
      final bool hasPersistedParent =
          parentRowId != null && parentRowId.isNotEmpty;
      final bool persistImmediately = hasPersistedParent && !forForm;
      if (!_canCreateMaquilaInline(
            parentSectionId,
            inline,
            effectiveParentRow,
          )) {
        return;
      }
      if (inline.id == 'compras_detalle') {
        if (_inlineCreationPolicy.compraDetalleCerrado(effectiveParentRow)) {
          _showMessage('No puedes modificar el detalle de una compra cerrada.');
          return;
        }
        if (_inlineCreationPolicy.compraTieneMovimientos(effectiveParentRow)) {
          _showMessage(
            'No puedes modificar el detalle de una compra con movimientos registrados.',
          );
          return;
        }
      }
      if (inline.id == 'compras_movimiento_detalle' &&
          _inlineCreationPolicy.movimientoDetalleCerrado(
            effectiveParentRow,
          )) {
        _showMessage(
          'No puedes modificar el detalle de un movimiento cerrado.',
        );
        return;
      }
      if (inline.id == 'compras_movimiento_detalle') {
        final compraEstado =
            effectiveParentRow['compra_estado']?.toString().toLowerCase().trim();
        if (compraEstado == 'cancelado') {
          _showMessage('No puedes modificar movimientos de una compra cancelada.');
          return;
        }
      }
      final bool isMovimientoDetalle =
          inline.id == 'movimientos_detalle' ||
          inline.id == 'compras_movimiento_detalle';
      Map<String, double>? movementRemaining;
      if (isMovimientoDetalle) {
        movementRemaining = _movimientoCoverageService
            .movementRemainingForSection(parentSectionId);
        if (movementRemaining != null) {
          final hasRemaining = movementRemaining.values.any(
            (value) => value > 0.0001,
          );
          if (!hasRemaining) {
            _showMessage('No hay productos pendientes por asignar.');
            return;
          }
        }
      }
      Map<String, double>? movimientoBaseStock;
      final bool requiereBase =
          inline.id == 'movimientos_detalle' &&
          (parentSectionId == 'movimientos' ||
              parentSectionId == 'pedidos_movimientos');
      if (requiereBase) {
        movimientoBaseStock = await _ensureMovimientoBaseReady(
          parentSectionId: parentSectionId,
          parentRow: effectiveParentRow,
          movementRemaining: movementRemaining,
        );
        if (movimientoBaseStock == null) {
          return;
        }
      }
      PedidoPagoBalance? pagoBalance;
      final bool isPedidoPago = inline.id == 'pedidos_pagos';
      if (isPedidoPago) {
        pagoBalance = _pedidoPagoCoordinator.buildPagoBalance(effectiveParentRow);
        if (pagoBalance.remaining <= 0.0001) {
          _showMessage('Este pedido ya está pagado por completo.');
          return;
        }
      }
      final contextReady =
          _inlineContextCoordinator.prepareInlineSectionContext(
        parentSectionId,
        effectiveParentRow,
        targetSectionId,
      );
      if (!contextReady) return;
      await _loadReferenceOptionsForSection(targetSectionId);
      final defaults = _sectionFormCoordinator.buildDefaultRow(targetSectionId);
      if (inline.id == 'pedidos_movimientos' && foreignKeyField == 'idpedido') {
        defaults['fecharegistro'] = date_time_utils.currentLocalIsoString();
      }
      if (inline.id == 'pedidos_pagos' && foreignKeyField == 'idpedido') {
        defaults['fechapago'] = date_time_utils.currentLocalIsoString();
      }
      List<FormFieldConfig>? fields = formBuilder.buildFields(
        targetSectionId,
        defaults,
        SectionFormMode.create,
      );
      if (fields == null) {
        _showMessage('No hay campos configurados para ${inline.title}.');
        return;
      }
      if (isMovimientoDetalle) {
        fields = _movimientoService.adjustMovimientoDetalleFields(
          fields,
          movementRemaining,
          baseStock: movimientoBaseStock,
        );
        if (fields.isEmpty) {
          if (movementRemaining != null && movimientoBaseStock != null) {
            _showMessage(
              'La base seleccionada no tiene stock disponible para los '
              'productos pendientes.',
            );
          } else if (movementRemaining != null) {
            _showMessage('No hay productos pendientes por asignar.');
          } else if (movimientoBaseStock != null) {
            _showMessage(
              'La base seleccionada no tiene stock disponible para este pedido.',
            );
          } else {
            _showMessage('No hay productos disponibles para asignar.');
          }
          return;
        }
      }
      if (isPedidoPago && pagoBalance != null) {
        fields = _pedidoInlineService.adjustPagoFields(
          fields,
          pagoBalance,
          pedidoRow: effectiveParentRow,
        );
      }
      final formTitle = inline.formTitle ?? inline.title;
      Map<String, String>? movimientoOverrideValues;
      final inlineOverrideNotifier = ValueNotifier<int>(0);
      String inlineBaseSelection =
          (defaults['idbase']?.toString() ?? '').trim();
      int inlineBaseValidationSeq = 0;
      Map<String, String> inlineCurrentValues =
          defaults.map((key, value) => MapEntry(key, value?.toString() ?? ''));
      final refreshListenable = Listenable.merge(<Listenable>[
        _inlineDraftService.refreshNotifier,
        inlineOverrideNotifier,
      ]);
      final Map<String, dynamic> inlineParentRow = Map<String, dynamic>.from(
        effectiveParentRow,
      );
      void applyInlineOverrides(Map<String, String> overrides) {
        if (mapEquals(movimientoOverrideValues, overrides)) {
          return;
        }
        debugPrint(
          '[inline-drafts] section=$targetSectionId override=$overrides',
        );
        movimientoOverrideValues = overrides;
        inlineOverrideNotifier.value++;
      }
      void clearInlineBaseSelection() {
        final hasBaseValue =
            (inlineCurrentValues['idbase'] ?? '').isNotEmpty ||
            (movimientoOverrideValues?['idbase'] ?? '').isNotEmpty;
        if (!hasBaseValue) return;
        inlineBaseSelection = '';
        final cleared = Map<String, String>.from(inlineCurrentValues);
        cleared['idbase'] = '';
        applyInlineOverrides(cleared);
        inlineCurrentValues = cleared;
        if (targetSectionId == 'pedidos_movimientos') {
          _inlineContextCoordinator.updateMovementContextBase(
            targetSectionId,
            null,
          );
        }
      }
      if (!_mountedResolver()) return;
      Map<String, dynamic>? result;
      try {
        result = await Navigator.of(_contextProvider())
            .push<Map<String, dynamic>>(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) {
                  FormViewConfig buildConfig() {
                    final inlineTables = _buildInlineTablesWithContext(
                      targetSectionId,
                      defaults,
                      forForm: true,
                      formMode: SectionFormMode.create,
                    );
                    debugPrint(
                      '[inline-form] buildConfig section=$targetSectionId override=$movimientoOverrideValues',
                    );
                    return FormViewConfig(
                      title: 'Nuevo ${formTitle.toLowerCase()}',
                      fields: fields!,
                      inlineTables: inlineTables,
                      onSubmit: (values) async {
                        if (!_ensureSectionValidation(
                          targetSectionId,
                          values,
                          feedbackContext: context,
                        )) {
                          return;
                        }
                        if (isMovimientoDetalle && movementRemaining != null) {
                          final detailError = _movimientoService
                              .validateMovimientoDetalleCantidad(
                                values,
                                movementRemaining,
                              );
                          if (detailError != null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(content: Text(detailError)),
                              );
                            } else {
                              _showMessage(detailError);
                            }
                            return;
                          }
                        }
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
                          final uniqueValue =
                              values[uniqueField]?.toString().trim() ?? '';
                          if (!_validateUniqueInlineProduct(
                            parentSectionId: parentSectionId,
                            inline: inline,
                            parentRow: inlineParentRow,
                            itemId: uniqueValue,
                          )) {
                            return;
                          }
                        }
                        if (inline.id == 'pedidos_pagos') {
                          final amount = _pedidoPagoCoordinator.parseAmount(
                            values['monto'],
                          );
                          final error = _pedidoPagoCoordinator
                              .validatePagoAmount(
                                parentRow: inlineParentRow,
                                amount: amount,
                              );
                          if (error != null) {
                            _showMessage(error);
                            return;
                          }
                        }
                        if (inline.id == 'fabricaciones_maquila_consumos') {
                          final stockError = await _inlineValidationEngine
                              .validateMaquilaConsumoStock(
                            parentSectionId: parentSectionId,
                            inline: inline,
                            parentRow: inlineParentRow,
                            values: values,
                          );
                          if (stockError != null) {
                            _showMessage(stockError);
                            return;
                          }
                        }
                        if (targetSectionId == 'pedidos_movimientos') {
                          final ok = await _ensurePedidoBaseHasStock(
                            pedidoRow: inlineParentRow,
                            values: values,
                            onInsufficientStock: clearInlineBaseSelection,
                          );
                          if (!ok) {
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
                      onChanged: (values) {
                        final isProgrammaticChange =
                            consumeFormProgrammaticChangeFlag(values);
                        inlineCurrentValues = Map<String, String>.from(values);
                        final sanitized = _movimientoDraftSanitizer(
                          targetSectionId,
                          values,
                          programmaticChange: isProgrammaticChange,
                        );
                        if (sanitized != null) {
                          applyInlineOverrides(sanitized);
                          if (targetSectionId == 'pedidos_movimientos') {
                            final sanitizedBase = sanitized['idbase'];
                            if (sanitizedBase != null) {
                              inlineBaseSelection = sanitizedBase.trim();
                            }
                          }
                          inlineCurrentValues =
                              Map<String, String>.from(sanitized);
                        }
                        if (targetSectionId != 'pedidos_movimientos') {
                          return;
                        }
                        final newBase = values['idbase']?.trim() ?? '';
                        final previousBase = inlineBaseSelection;
                        if (newBase == previousBase) return;
                        inlineBaseSelection = newBase;
                        if (targetSectionId == 'pedidos_movimientos') {
                          _inlineContextCoordinator.updateMovementContextBase(
                            targetSectionId,
                            newBase.isEmpty ? null : newBase,
                          );
                        }
                        final validationSeq = ++inlineBaseValidationSeq;
                        if (newBase.isEmpty) {
                          return;
                        }
                        final snapshot = Map<String, String>.from(values);
                        unawaited(() async {
                          await _ensurePedidoBaseHasStock(
                            pedidoRow: inlineParentRow,
                            values: snapshot,
                            onInsufficientStock: () {
                              if (validationSeq != inlineBaseValidationSeq) {
                                return;
                              }
                              clearInlineBaseSelection();
                            },
                          );
                        }());
                      },
                      overrideValues: movimientoOverrideValues,
                    );
                  }

                  return ReferenceFormPage(
                    title: formTitle,
                    configBuilder: buildConfig,
                    refreshListenable: refreshListenable,
                  );
                },
              ),
            );
      } finally {
        inlineOverrideNotifier.dispose();
      }
      if (result == null) {
        _inlineDraftService.clearPendingRows(targetSectionId);
        debugPrint('[inline-create] cancelado ${inline.id}');
        return;
      }
      debugPrint('[inline-create] ${inline.id} -> $result');
      final nestedPending = _inlineDraftService.takePendingInlineRowsForSection(
        targetSectionId,
      );
      _inlineDraftService.addPendingInlineRow(
        parentSectionId,
        inline,
        result,
        targetSectionId,
        nestedInlineRows: nestedPending,
      );
      if (persistImmediately && hasPersistedParent) {
        await _inlineDraftService.persistPendingInlineRows(
          parentSectionId: parentSectionId,
          parentRowId: parentRowId,
        );
        final currentParent =
            _sectionStateController.sectionSelectedRows[parentSectionId] ??
            effectiveParentRow;
        await _inlineDraftService.loadInlineSectionsForRow(
          parentSectionId,
          currentParent,
        );
        if (isMovimientoDetalle) {
          _movimientoCoverageService.prepareMovementDetailContext(
            parentSectionId,
            currentParent,
          );
        } else if (isPedidoPago) {
          _inlineContextCoordinator.preparePedidoPagoContext(currentParent);
        }
        _stateSetter(() {});
        await _refreshParentSection(parentSectionId);
      } else {
        if (isMovimientoDetalle) {
          _movimientoCoverageService.prepareMovementDetailContext(
            parentSectionId,
            _sectionStateController.sectionSelectedRows[parentSectionId] ??
                effectiveParentRow,
          );
          _stateSetter(() {});
        } else if (isPedidoPago) {
          final currentPedido =
              _sectionStateController.sectionSelectedRows[parentSectionId] ??
              effectiveParentRow;
          _inlineContextCoordinator.preparePedidoPagoContext(currentPedido);
          _stateSetter(() {});
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Error al abrir ${inline.id}: $error\n$stackTrace');
      _showMessage('No se pudo abrir ${inline.id}: $error');
    } finally {
      if (shouldClearViajeContext) {
        _inlineContextCoordinator.clearViajeDetalleContext();
      }
    }
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

  Future<Map<String, double>?> _ensureMovimientoBaseReady({
    required String parentSectionId,
    required Map<String, dynamic> parentRow,
    Map<String, double>? movementRemaining,
  }) async {
    final baseId = _inlineContextCoordinator.resolveMovimientoBaseId(
      parentSectionId,
      parentRow,
    );
    final result = await _inlineStockValidator.ensureMovimientoBaseReady(
      baseId: baseId,
      movementRemaining: movementRemaining,
    );
    if (result.message != null) {
      _showMessage(result.message!);
    }
    return result.stockByProduct;
  }

  bool _canCreatePedidoInline(
    String parentSectionId,
    InlineSectionConfig inline,
    Map<String, dynamic> parentRow,
  ) {
    final message = _inlineCreationPolicy.validatePedidoInlineCreation(
      parentSectionId: parentSectionId,
      inline: inline,
      parentRow: parentRow,
    );
    if (message != null) {
      _showMessage(message);
      return false;
    }
    return true;
  }

  bool _canCreateCompraInline(
    String parentSectionId,
    InlineSectionConfig inline,
    Map<String, dynamic> parentRow,
  ) {
    final message = _inlineCreationPolicy.validateCompraInlineCreation(
      parentSectionId: parentSectionId,
      inline: inline,
      parentRow: parentRow,
    );
    if (message != null) {
      _showMessage(message);
      return false;
    }
    return true;
  }

  bool _canCreateMaquilaInline(
    String parentSectionId,
    InlineSectionConfig inline,
    Map<String, dynamic> parentRow,
  ) {
    final message = _inlineCreationPolicy.validateMaquilaInlineCreation(
      parentSectionId: parentSectionId,
      inline: inline,
      parentRow: parentRow,
    );
    if (message != null) {
      _showMessage(message);
      return false;
    }
    return true;
  }
}
