import 'dart:async';

import 'package:flutter/material.dart';

import 'package:erp_app/src/navegacion/detalle_builders.dart';
import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shared/utils/template_formatters.dart';
import 'package:erp_app/src/shell/controllers/inline_table_presenter.dart';
import 'package:erp_app/src/shell/controllers/section_config_builders.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/domains/pedidos/pedido_pago_coordinator.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/reference_form_page.dart';
import 'package:erp_app/src/shell/section_form_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_context_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/services/inline_validation_engine.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';
import 'package:erp_app/src/shell/ui/inline_detail_shell_page.dart';
import 'package:erp_app/src/shell/ui/inline_section_table_page.dart';

typedef ContextProvider = BuildContext Function();
typedef InlineTablesBuilder = List<InlineTableConfig> Function(
  String sectionId,
  Map<String, dynamic> row, {
  required bool forForm,
  SectionFormMode? formMode,
});
typedef InlineCreateHandler = Future<void> Function({
  required String parentSectionId,
  required InlineSectionConfig inline,
  required Map<String, dynamic> parentRow,
  required bool forForm,
});
typedef InlineBulkDeleteHandler = Future<void> Function(
  String parentSectionId,
  InlineSectionConfig inline,
  List<TableRowData> rows,
  Map<String, dynamic> parentRow,
);
typedef EnsureSectionValidation = bool Function(
  String sectionId,
  Map<String, String> values, {
  BuildContext? feedbackContext,
});
typedef ValidateUniqueInlineProduct = bool Function({
  required String parentSectionId,
  required InlineSectionConfig inline,
  required Map<String, dynamic> parentRow,
  required String itemId,
  String? excludePendingId,
  dynamic excludeRowId,
});
typedef EnsurePedidoBaseHasStock = Future<bool> Function({
  required Map<String, dynamic>? pedidoRow,
  required Map<String, String> values,
  String? pedidoIdFallback,
});

typedef FormConfigBuilderResolver = FormConfigBuilder? Function();
typedef DetailConfigBuilderResolver = DetailConfigBuilder? Function();

/// Centraliza la navegación de vistas inline (detalle, edición, tabla).
class InlineNavigationCoordinator {
  InlineNavigationCoordinator({
    required ContextProvider contextProvider,
    required bool Function() mountedResolver,
    required ModuleConfig? Function() activeModuleResolver,
    required String? Function() activeSectionResolver,
    required List<GlobalNavAction> Function() globalActionsResolver,
    required Future<void> Function(String sectionId) onSectionSelected,
    required Future<void> Function(GlobalNavAction action) onGlobalAction,
    required SectionStateController sectionStateController,
    required ModuleRepository moduleRepository,
    required InlineDraftService inlineDraftService,
    required InlineTablePresenter inlineTablePresenter,
    required InlineContextCoordinator inlineContextCoordinator,
    required InlineValidationEngine inlineValidationEngine,
    required PedidoPagoCoordinator pedidoPagoCoordinator,
    required SectionFormCoordinator sectionFormCoordinator,
    required Future<void> Function(String sectionId) loadReferenceOptionsForSection,
    required EnsureSectionValidation ensureSectionValidation,
    required ValidateUniqueInlineProduct validateUniqueInlineProduct,
    required EnsurePedidoBaseHasStock ensurePedidoBaseHasStock,
    required Future<void> Function(String parentSectionId) refreshParentSection,
    required InlineTablesBuilder buildInlineTablesWithContext,
    required FormConfigBuilderResolver formConfigBuilderResolver,
    required DetailConfigBuilderResolver detailConfigBuilderResolver,
    required ModuleSection? Function(String sectionId) moduleSectionResolver,
    required bool Function(String sectionId, Map<String, dynamic> row)
        shouldLoadInlineSections,
    required void Function(String message) showMessage,
  })  : _contextProvider = contextProvider,
        _mountedResolver = mountedResolver,
        _activeModuleResolver = activeModuleResolver,
        _activeSectionResolver = activeSectionResolver,
        _globalActionsResolver = globalActionsResolver,
        _onSectionSelected = onSectionSelected,
        _onGlobalAction = onGlobalAction,
        _sectionStateController = sectionStateController,
        _moduleRepository = moduleRepository,
        _inlineDraftService = inlineDraftService,
        _inlineTablePresenter = inlineTablePresenter,
        _inlineContextCoordinator = inlineContextCoordinator,
        _inlineValidationEngine = inlineValidationEngine,
        _pedidoPagoCoordinator = pedidoPagoCoordinator,
        _sectionFormCoordinator = sectionFormCoordinator,
        _loadReferenceOptionsForSection = loadReferenceOptionsForSection,
        _ensureSectionValidation = ensureSectionValidation,
        _validateUniqueInlineProduct = validateUniqueInlineProduct,
        _ensurePedidoBaseHasStock = ensurePedidoBaseHasStock,
        _refreshParentSection = refreshParentSection,
        _buildInlineTablesWithContext = buildInlineTablesWithContext,
        _formConfigBuilderResolver = formConfigBuilderResolver,
        _detailConfigBuilderResolver = detailConfigBuilderResolver,
        _moduleSectionResolver = moduleSectionResolver,
        _shouldLoadInlineSections = shouldLoadInlineSections,
        _showMessage = showMessage;

  final ContextProvider _contextProvider;
  final bool Function() _mountedResolver;
  final ModuleConfig? Function() _activeModuleResolver;
  final String? Function() _activeSectionResolver;
  final List<GlobalNavAction> Function() _globalActionsResolver;
  final Future<void> Function(String sectionId) _onSectionSelected;
  final Future<void> Function(GlobalNavAction action) _onGlobalAction;
  final SectionStateController _sectionStateController;
  final ModuleRepository _moduleRepository;
  final InlineDraftService _inlineDraftService;
  final InlineTablePresenter _inlineTablePresenter;
  final InlineContextCoordinator _inlineContextCoordinator;
  final InlineValidationEngine _inlineValidationEngine;
  final PedidoPagoCoordinator _pedidoPagoCoordinator;
  final SectionFormCoordinator _sectionFormCoordinator;
  final Future<void> Function(String sectionId) _loadReferenceOptionsForSection;
  final EnsureSectionValidation _ensureSectionValidation;
  final ValidateUniqueInlineProduct _validateUniqueInlineProduct;
  final EnsurePedidoBaseHasStock _ensurePedidoBaseHasStock;
  final Future<void> Function(String parentSectionId) _refreshParentSection;
  final InlineTablesBuilder _buildInlineTablesWithContext;
  final FormConfigBuilderResolver _formConfigBuilderResolver;
  final DetailConfigBuilderResolver _detailConfigBuilderResolver;
  final ModuleSection? Function(String sectionId) _moduleSectionResolver;
  final bool Function(String sectionId, Map<String, dynamic> row)
  _shouldLoadInlineSections;
  final void Function(String message) _showMessage;

  Future<void> openInlineSectionTablePage({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
    required InlineCreateHandler onCreate,
    required InlineBulkDeleteHandler onBulkDelete,
  }) async {
    Map<String, dynamic> currentRow =
        _sectionStateController.sectionSelectedRows[parentSectionId] ??
        parentRow;
    final parentId = currentRow['id'];
    Future<List<Map<String, dynamic>>> rowsLoader() async {
      final List<Map<String, dynamic>> result = [];
      if (parentId != null) {
        final rows = await _moduleRepository.fetchInlineRows(
          inline.dataSource,
          foreignKeyColumn: inline.foreignKeyColumn,
          foreignKeyValue: parentId,
        );
        result.addAll(
          rows.map((data) => Map<String, dynamic>.from(data as Map)),
        );
      }
      final pendingRows = _inlineDraftService.findPendingRows(
        parentSectionId,
        inline.id,
      );
      result.addAll(
        pendingRows.map(
          (entry) => {
            ...entry.tableValues,
            '__pending': true,
            '__pending_id': entry.pendingId,
          },
        ),
      );
      return result;
    }

    final tableRows = await rowsLoader();
    final List<TableAction> bulkActions = [
      TableAction(
        label: 'Eliminar',
        icon: Icons.delete_outline,
        onSelected: (rows) =>
            onBulkDelete(parentSectionId, inline, rows, currentRow),
      ),
    ];
    if (!_mountedResolver()) return;
    await Navigator.of(_contextProvider()).push(
      MaterialPageRoute(
        builder: (context) => InlineSectionTablePage(
          title: inline.title,
          columns: inline.columns,
          rows: tableRows,
          emptyPlaceholder: inline.emptyPlaceholder,
          loadRows: rowsLoader,
          onCreate: inline.enableCreate
              ? () => onCreate(
                    parentSectionId: parentSectionId,
                    inline: inline,
                    parentRow: parentRow,
                    forForm: false,
                  )
              : null,
          bulkActions: bulkActions,
        ),
      ),
    );
  }

  Future<void> openInlineDetailPage({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required String targetSectionId,
    required Map<String, dynamic> row,
  }) async {
    if (_shouldLoadInlineSections(targetSectionId, row)) {
      await _inlineDraftService.loadInlineSectionsForRow(targetSectionId, row);
    }
    final moduleSection = _moduleSectionResolver(targetSectionId);
    final title = moduleSection?.label ?? formatColumnLabel(targetSectionId);
    final subtitle = _buildInlineDetailSubtitle(targetSectionId, row);
    final detailBuilder = _detailConfigBuilderResolver();
    final fields = detailBuilder?.buildFields(targetSectionId, row) ?? [];
    final inlineSections = _inlineTablePresenter.buildTables(
      targetSectionId,
      row,
      forForm: false,
    );
    DetailActionConfig? floatingAction;
    final formSectionId = inline.formSectionId ?? targetSectionId;
    final dataSource = _sectionStateController.sectionDataSources[formSectionId];
    final isPending = row['__pending'] == true;
    if (!isPending &&
        dataSource != null &&
        dataSource.formRelation.isNotEmpty) {
      floatingAction = DetailActionConfig(
        label: 'Editar',
        icon: Icons.edit_outlined,
        onPressed: () => openInlineStandaloneEdit(
          parentSectionId: parentSectionId,
          inline: inline,
          targetSectionId: formSectionId,
          row: row,
        ),
      );
    }
    final builder = kModuleDetailViewBuilders[targetSectionId];
    final detailConfig = builder != null
        ? builder(
            row: row,
            inlineTables: inlineSections,
            onBack: null,
            floatingAction: floatingAction,
          )
        : DetailViewConfig(
            title: title,
            subtitle: subtitle,
            fields: fields,
            inlineSections: inlineSections,
            onBack: null,
            floatingAction: floatingAction,
          );
    if (!_mountedResolver()) return;
    await Navigator.of(_contextProvider()).push(
      MaterialPageRoute(
        builder: (routeContext) {
          final configForRoute = detailConfig.copyWith(
            onBack: () => Navigator.of(routeContext).pop(),
          );
          return InlineDetailShellPage(
            detailConfig: configForRoute,
            activeModule: _activeModuleResolver(),
            selectedSectionId: _activeSectionResolver(),
            globalActions: _globalActionsResolver(),
            onSectionSelected: (sectionId) {
              Navigator.of(routeContext).pop();
              unawaited(_onSectionSelected(sectionId));
            },
            onGlobalAction: (action) {
              Navigator.of(routeContext).pop();
              unawaited(_onGlobalAction(action));
            },
          );
        },
      ),
    );
  }

  Future<void> openInlineStandaloneEdit({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required String targetSectionId,
    required Map<String, dynamic> row,
  }) async {
    final formBuilder = _formConfigBuilderResolver();
    if (formBuilder == null) return;
    final formSectionId = inline.formSectionId ?? targetSectionId;
    bool shouldClearViajeContext = false;
    if (formSectionId == 'viajes_detalle') {
      final parentRow =
          _sectionStateController.sectionSelectedRows[parentSectionId];
      final ready = _inlineContextCoordinator.prepareViajeDetalleEditContext(
        parentSectionId: parentSectionId,
        parentRow: parentRow,
        detalleRow: row,
      );
      if (!ready) return;
      shouldClearViajeContext = true;
    }
    if (formSectionId == 'pedidos_movimientos') {
      _inlineContextCoordinator.preparePedidoMovimientoEditContext(
        parentSectionId,
        formSectionId,
        row,
      );
    }
    await _loadReferenceOptionsForSection(formSectionId);
    try {
      final dataSource =
          _sectionStateController.sectionDataSources[formSectionId];
      final editableRow = Map<String, dynamic>.from(row);
      final isPendingRow = row['__pending'] == true;
      if (!isPendingRow && dataSource != null) {
        final rowId = row['id'];
        if (rowId != null) {
          try {
            final persisted = await _moduleRepository.fetchFormRow(
              dataSource,
              rowId,
            );
            if (persisted != null) {
              editableRow.addAll(persisted);
            }
          } catch (error, stackTrace) {
            debugPrint(
              'Error cargando $formSectionId $rowId para edición: '
              '$error\n$stackTrace',
            );
          }
          await _inlineDraftService.loadInlineSectionsForRow(
            formSectionId,
            editableRow,
          );
        }
      }
      final fields = formBuilder.buildFields(
        formSectionId,
        editableRow,
        SectionFormMode.edit,
      );
      if (fields == null) {
        _showMessage('No hay campos configurados para ${inline.title}.');
        return;
      }
      final inlineTables = _buildInlineTablesWithContext(
        formSectionId,
        editableRow,
        forForm: true,
        formMode: SectionFormMode.edit,
      );
      if (!_mountedResolver()) return;
      final result = await Navigator.of(_contextProvider())
          .push<Map<String, String>>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => ReferenceFormPage(
                title: 'Editar ${inline.title.toLowerCase()}',
                config: FormViewConfig(
                  title: 'Editar ${inline.title.toLowerCase()}',
                  fields: fields,
                  inlineTables: inlineTables,
                  onSubmit: (values) async {
                    final navigator = Navigator.of(context);
                    if (!_ensureSectionValidation(
                      formSectionId,
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
                        excludeRowId: row['id'],
                      );
                      if (stockError != null) {
                        _showMessage(stockError);
                        return;
                      }
                    }
                    if (formSectionId == 'pedidos_movimientos') {
                      final pedidoRow =
                          _sectionStateController.sectionSelectedRows[
                              parentSectionId];
                      final ok = await _ensurePedidoBaseHasStock(
                        pedidoRow: pedidoRow,
                        values: values,
                        pedidoIdFallback: row['idpedido']?.toString(),
                      );
                      if (!ok) {
                        return;
                      }
                    }
                    if (!navigator.mounted) return;
                    navigator.pop(values);
                  },
                  onCancel: () => Navigator.of(context).pop(),
                  saveLabel: 'Guardar',
                  cancelLabel: 'Cancelar',
                ),
              ),
            ),
          );
      if (result == null) return;
      final rowId = row['id'];
      if (rowId == null || dataSource == null) {
        _showMessage('No se pudo actualizar el registro.');
        return;
      }
      String? uniqueField;
      if (inline.id == 'viajes_detalle') {
        uniqueField = 'idmovimiento';
      } else if (inline.id == 'movimientos_detalle' ||
          inline.id == 'pedidos_detalle' ||
          inline.id == 'compras_detalle' ||
          inline.id == 'compras_movimiento_detalle') {
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
          excludeRowId: rowId,
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
          excludeRowId: rowId,
        );
        if (error != null) {
          _showMessage(error);
          return;
        }
      }
      final payload = _sectionFormCoordinator.preparePayload(
        result,
        sectionId: formSectionId,
      );
      try {
        await _moduleRepository.updateRow(dataSource, rowId, payload);
        final parentRow =
            _sectionStateController.sectionSelectedRows[parentSectionId];
        if (parentRow != null) {
          await _inlineDraftService.loadInlineSectionsForRow(
            parentSectionId,
            parentRow,
          );
        }
        if (!_mountedResolver()) return;
        Navigator.of(_contextProvider()).pop();
        ScaffoldMessenger.of(
          _contextProvider(),
        ).showSnackBar(const SnackBar(content: Text('Registro actualizado.')));
        await _refreshParentSection(parentSectionId);
      } catch (error) {
        if (!_mountedResolver()) return;
        ScaffoldMessenger.of(_contextProvider()).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar: $error')),
        );
      }
    } finally {
      if (shouldClearViajeContext) {
        _inlineContextCoordinator.clearViajeDetalleContext();
      }
    }
  }

  String _buildInlineDetailSubtitle(
    String sectionId,
    Map<String, dynamic> row,
  ) {
    if (sectionId == 'pedidos_movimientos') {
      final isProvincia =
          (row['es_provincia']?.toString().toLowerCase() ?? 'false') == 'true';
      if (isProvincia) {
        final destino = row['provincia_destino']?.toString();
        final destinatario = row['provincia_destinatario']?.toString();
        if ((destino ?? '').isNotEmpty && (destinatario ?? '').isNotEmpty) {
          return '$destinatario · $destino';
        }
        return destino ?? destinatario ?? 'Destino provincia';
      }
      final direccion = row['direccion_texto']?.toString();
      final referencia = row['direccion_referencia']?.toString();
      if ((direccion ?? '').isNotEmpty && (referencia ?? '').isNotEmpty) {
        return '$direccion · $referencia';
      }
      return direccion ?? referencia ?? 'Destino Lima';
    }
    return row['cliente_nombre']?.toString() ??
        row['producto_nombre']?.toString() ??
        row['nombre']?.toString() ??
        '';
  }
}
