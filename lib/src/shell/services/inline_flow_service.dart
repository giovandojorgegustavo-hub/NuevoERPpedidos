import 'dart:async';

import 'package:flutter/material.dart';

import 'package:erp_app/src/domains/clientes/client_context_service.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_coverage_service.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_inline_coordinator.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_service.dart';
import 'package:erp_app/src/domains/pedidos/pedido_inline_service.dart';
import 'package:erp_app/src/domains/pedidos/pedido_pago_coordinator.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shared/utils/template_formatters.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/controllers/section_config_builders.dart';
import 'package:erp_app/src/shell/controllers/inline_table_presenter.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/section_action_controller.dart';
import 'package:erp_app/src/shell/section_form_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_bulk_delete_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_context_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_create_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_creation_policy.dart';
import 'package:erp_app/src/shell/services/inline_navigation_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_pending_edit_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_stock_validator.dart';
import 'package:erp_app/src/shell/services/inline_validation_engine.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';

typedef ContextProvider = BuildContext Function();

/// Encapsula la lógica de manejo de tablas inline y borradores para mantener
/// `ShellPage` delgada. Esta clase aún depende de `BuildContext` porque los
/// flujos actuales abren páginas propias, pero concentra toda la orquestación.
class InlineFlowService {
  InlineFlowService({
    required ModuleRepository moduleRepository,
    required SectionStateController sectionStateController,
    required InlineDraftService inlineDraftService,
    required SectionFormCoordinator sectionFormCoordinator,
    required ClientContextService clientContextService,
    required PedidoPagoCoordinator pedidoPagoCoordinator,
    required MovimientoInlineCoordinator movimientoInlineCoordinator,
    required MovimientoCoverageService movimientoCoverageService,
    required PedidoInlineService pedidoInlineService,
    required MovimientoService movimientoService,
    required void Function(
      String sectionId,
      String fieldId,
      Map<String, dynamic>? filter,
    )
    referenceFilterSetter,
    required Map<String, Map<String, String>> formDraftValues,
    required Map<String, dynamic> Function(String sectionId)
    sectionContextResolver,
    required void Function(String sectionId, Map<String, dynamic>? values)
    sectionContextWriter,
    required bool Function(String sectionId, String inlineId)
    hasInlineRowsResolver,
    required bool Function(String sectionId, Map<String, dynamic> row)
    shouldLoadInlineSections,
    required Future<void> Function(String sectionId)
    loadReferenceOptionsForSection,
    required ContextProvider contextProvider,
    required void Function(String message) showMessage,
    required void Function(void Function()) stateSetter,
    required bool Function() mountedResolver,
    required ModuleConfig? Function() activeModuleResolver,
    required String? Function() activeSectionResolver,
    required List<GlobalNavAction> Function() globalActionsResolver,
    required Future<void> Function(String sectionId) onSectionSelected,
    required Future<void> Function(GlobalNavAction action) onGlobalAction,
    required SectionActionController sectionActionController,
    required VoidCallback pushNavigationSnapshot,
    required bool Function(String sectionId) sectionExistsResolver,
    required ModuleSection? Function(String sectionId) moduleSectionResolver,
    required Future<void> Function(String sectionId) sectionRefresher,
    required Map<String, String>? Function(
      String sectionId,
      Map<String, String> values, {
      bool programmaticChange,
    })
    movimientoDraftSanitizer,
  }) : _moduleRepository = moduleRepository,
       _sectionStateController = sectionStateController,
       _inlineDraftService = inlineDraftService,
       _inlineValidationEngine = InlineValidationEngine(
         inlineDraftService: inlineDraftService,
         moduleRepository: moduleRepository,
       ),
       _inlineStockValidator = InlineStockValidator(
         moduleRepository: moduleRepository,
         inlineDraftService: inlineDraftService,
         movimientoCoverageService: movimientoCoverageService,
       ),
       _sectionFormCoordinator = sectionFormCoordinator,
       _pedidoPagoCoordinator = pedidoPagoCoordinator,
       _movimientoInlineCoordinator = movimientoInlineCoordinator,
       _movimientoCoverageService = movimientoCoverageService,
       _pedidoInlineService = pedidoInlineService,
       _movimientoService = movimientoService,
       _inlineCreationPolicy = InlineCreationPolicy(
         clientContextService: clientContextService,
         pedidoPagoCoordinator: pedidoPagoCoordinator,
         hasInlineRowsResolver: hasInlineRowsResolver,
         formDraftValuesResolver: (sectionId) => formDraftValues[sectionId],
       ),
       _inlineContextCoordinator = InlineContextCoordinator(
         clientContextService: clientContextService,
         pedidoPagoCoordinator: pedidoPagoCoordinator,
         movimientoInlineCoordinator: movimientoInlineCoordinator,
         inlineDraftService: inlineDraftService,
         formDraftValues: formDraftValues,
         sectionContextResolver: sectionContextResolver,
         sectionContextWriter: sectionContextWriter,
         referenceFilterSetter: referenceFilterSetter,
         showMessage: showMessage,
       ),
       _formDraftValues = formDraftValues,
       _sectionContextResolver = sectionContextResolver,
       _shouldLoadInlineSections = shouldLoadInlineSections,
       _loadReferenceOptionsForSection = loadReferenceOptionsForSection,
       _contextProvider = contextProvider,
       _showMessage = showMessage,
       _stateSetter = stateSetter,
       _mountedResolver = mountedResolver,
       _activeModuleResolver = activeModuleResolver,
       _activeSectionResolver = activeSectionResolver,
       _globalActionsResolver = globalActionsResolver,
       _onSectionSelected = onSectionSelected,
       _onGlobalAction = onGlobalAction,
       _sectionActionController = sectionActionController,
       _pushNavigationSnapshot = pushNavigationSnapshot,
       _sectionExistsResolver = sectionExistsResolver,
       _sectionRefresher = sectionRefresher,
       _movimientoDraftSanitizer = movimientoDraftSanitizer {
    _inlineTablePresenter = InlineTablePresenter(
      sectionStateController: _sectionStateController,
      inlineDraftService: _inlineDraftService,
      sectionContextResolver: _sectionContextResolver,
      rowNavigator:
          ({
            required String parentSectionId,
            required String targetSectionId,
            required InlineSectionConfig inline,
            required InlineTableRow row,
            required bool forForm,
          }) => handleInlineRowNavigation(
            parentSectionId: parentSectionId,
            targetSectionId: targetSectionId,
            inline: inline,
            row: row,
            forForm: forForm,
          ),
      createHandler:
          (parentSectionId, inline, parentRow, {required bool forForm}) =>
              handleInlineCreate(
                parentSectionId: parentSectionId,
                inline: inline,
                parentRow: parentRow,
                forForm: forForm,
              ),
      viewHandler: (parentSectionId, inline, parentRow) =>
          handleInlineView(parentSectionId, inline, parentRow),
      bulkDeleteHandler: (parentSectionId, inline, rows, parentRow) =>
          handleInlineBulkDelete(parentSectionId, inline, rows, parentRow),
      valueFormatter: formatInlineValue,
    );
    _inlineNavigationCoordinator = InlineNavigationCoordinator(
      contextProvider: _contextProvider,
      mountedResolver: _mountedResolver,
      activeModuleResolver: _activeModuleResolver,
      activeSectionResolver: _activeSectionResolver,
      globalActionsResolver: _globalActionsResolver,
      onSectionSelected: _onSectionSelected,
      onGlobalAction: _onGlobalAction,
      sectionStateController: _sectionStateController,
      moduleRepository: _moduleRepository,
      inlineDraftService: _inlineDraftService,
      inlineTablePresenter: _inlineTablePresenter,
      inlineContextCoordinator: _inlineContextCoordinator,
      inlineValidationEngine: _inlineValidationEngine,
      pedidoPagoCoordinator: _pedidoPagoCoordinator,
      sectionFormCoordinator: _sectionFormCoordinator,
      loadReferenceOptionsForSection: _loadReferenceOptionsForSection,
      ensureSectionValidation: _ensureSectionValidation,
      validateUniqueInlineProduct: _validateUniqueInlineProduct,
      ensurePedidoBaseHasStock: _ensurePedidoBaseHasStock,
      refreshParentSection: _refreshParentSection,
      buildInlineTablesWithContext: buildInlineTablesWithContext,
      formConfigBuilderResolver: () => _formConfigBuilder,
      detailConfigBuilderResolver: () => _detailConfigBuilder,
      moduleSectionResolver: moduleSectionResolver,
      shouldLoadInlineSections: _shouldLoadInlineSections,
      showMessage: _showMessage,
    );
    _inlineCreateCoordinator = InlineCreateCoordinator(
      inlineDraftService: _inlineDraftService,
      sectionStateController: _sectionStateController,
      sectionFormCoordinator: _sectionFormCoordinator,
      movimientoCoverageService: _movimientoCoverageService,
      pedidoPagoCoordinator: _pedidoPagoCoordinator,
      pedidoInlineService: _pedidoInlineService,
      movimientoService: _movimientoService,
      inlineCreationPolicy: _inlineCreationPolicy,
      inlineContextCoordinator: _inlineContextCoordinator,
      inlineValidationEngine: _inlineValidationEngine,
      inlineStockValidator: _inlineStockValidator,
      formDraftValues: _formDraftValues,
      loadReferenceOptionsForSection: _loadReferenceOptionsForSection,
      buildInlineTablesWithContext: buildInlineTablesWithContext,
      formConfigBuilderResolver: () => _formConfigBuilder,
      contextProvider: _contextProvider,
      mountedResolver: _mountedResolver,
      showMessage: _showMessage,
      stateSetter: _stateSetter,
      refreshParentSection: _refreshParentSection,
      ensureSectionValidation: _ensureSectionValidation,
      validateUniqueInlineProduct: _validateUniqueInlineProduct,
      ensurePedidoBaseHasStock: _ensurePedidoBaseHasStock,
      movimientoDraftSanitizer: _movimientoDraftSanitizer,
    );
    _inlinePendingEditCoordinator = InlinePendingEditCoordinator(
      inlineDraftService: _inlineDraftService,
      sectionStateController: _sectionStateController,
      inlineContextCoordinator: _inlineContextCoordinator,
      inlineValidationEngine: _inlineValidationEngine,
      sectionFormCoordinator: _sectionFormCoordinator,
      pedidoPagoCoordinator: _pedidoPagoCoordinator,
      movimientoCoverageService: _movimientoCoverageService,
      loadReferenceOptionsForSection: _loadReferenceOptionsForSection,
      buildInlineTablesWithContext: buildInlineTablesWithContext,
      formConfigBuilderResolver: () => _formConfigBuilder,
      contextProvider: _contextProvider,
      mountedResolver: _mountedResolver,
      showMessage: _showMessage,
      stateSetter: _stateSetter,
      ensureSectionValidation: _ensureSectionValidation,
      validateUniqueInlineProduct: _validateUniqueInlineProduct,
    );
    _inlineBulkDeleteCoordinator = InlineBulkDeleteCoordinator(
      inlineDraftService: _inlineDraftService,
      sectionStateController: _sectionStateController,
      moduleRepository: _moduleRepository,
      inlineCreationPolicy: _inlineCreationPolicy,
      movimientoCoverageService: _movimientoCoverageService,
      inlineContextCoordinator: _inlineContextCoordinator,
      stateSetter: _stateSetter,
      refreshParentSection: _refreshParentSection,
      showMessage: _showMessage,
    );
  }

  final ModuleRepository _moduleRepository;
  final SectionStateController _sectionStateController;
  final InlineDraftService _inlineDraftService;
  final InlineValidationEngine _inlineValidationEngine;
  final InlineStockValidator _inlineStockValidator;
  final SectionFormCoordinator _sectionFormCoordinator;
  final PedidoPagoCoordinator _pedidoPagoCoordinator;
  final MovimientoInlineCoordinator _movimientoInlineCoordinator;
  final MovimientoCoverageService _movimientoCoverageService;
  final PedidoInlineService _pedidoInlineService;
  final MovimientoService _movimientoService;
  final InlineCreationPolicy _inlineCreationPolicy;
  final InlineContextCoordinator _inlineContextCoordinator;
  late final InlineNavigationCoordinator _inlineNavigationCoordinator;
  late final InlineCreateCoordinator _inlineCreateCoordinator;
  late final InlinePendingEditCoordinator _inlinePendingEditCoordinator;
  late final InlineBulkDeleteCoordinator _inlineBulkDeleteCoordinator;
  final Map<String, Map<String, String>> _formDraftValues;
  final Map<String, dynamic> Function(String sectionId) _sectionContextResolver;
  final bool Function(String sectionId, Map<String, dynamic> row)
  _shouldLoadInlineSections;
  final Future<void> Function(String sectionId) _loadReferenceOptionsForSection;
  final ContextProvider _contextProvider;
  final void Function(String message) _showMessage;
  final void Function(void Function()) _stateSetter;
  final bool Function() _mountedResolver;
  final ModuleConfig? Function() _activeModuleResolver;
  final String? Function() _activeSectionResolver;
  final List<GlobalNavAction> Function() _globalActionsResolver;
  final Future<void> Function(String sectionId) _onSectionSelected;
  final Future<void> Function(GlobalNavAction action) _onGlobalAction;
  final SectionActionController _sectionActionController;
  final VoidCallback _pushNavigationSnapshot;
  final bool Function(String sectionId) _sectionExistsResolver;
  final Future<void> Function(String sectionId) _sectionRefresher;
  final Map<String, String>? Function(
    String sectionId,
    Map<String, String> values, {
    bool programmaticChange,
  })
  _movimientoDraftSanitizer;

  late final InlineTablePresenter _inlineTablePresenter;
  FormConfigBuilder? _formConfigBuilder;
  DetailConfigBuilder? _detailConfigBuilder;
  void attachBuilders({
    required FormConfigBuilder formBuilder,
    required DetailConfigBuilder detailBuilder,
  }) {
    _formConfigBuilder = formBuilder;
    _detailConfigBuilder = detailBuilder;
  }

  List<InlineTableConfig> buildInlineTablesWithContext(
    String sectionId,
    Map<String, dynamic> row, {
    required bool forForm,
    SectionFormMode? formMode,
  }) {
    if (forForm) {
      _movimientoCoverageService.prepareMovementDetailContext(sectionId, row);
    }
    if (sectionId == 'pedidos_tabla') {
      _inlineContextCoordinator.preparePedidoPagoContext(row);
    }
    return _inlineTablePresenter.buildTables(
      sectionId,
      row,
      forForm: forForm,
      formMode: formMode,
    );
  }

  Future<void> handleInlineCreate({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
    required bool forForm,
  }) async {
    await _inlineCreateCoordinator.createInline(
      parentSectionId: parentSectionId,
      inline: inline,
      parentRow: parentRow,
      forForm: forForm,
    );
  }

  Future<void> handlePendingInlineRowEdit(
    String parentSectionId,
    InlineSectionConfig inline,
    InlineTableRow row,
  ) async {
    await _inlinePendingEditCoordinator.editPendingInlineRow(
      parentSectionId: parentSectionId,
      inline: inline,
      row: row,
    );
  }

  Future<void> handleInlineRowNavigation({
    required String parentSectionId,
    required String targetSectionId,
    required InlineSectionConfig inline,
    required InlineTableRow row,
    required bool forForm,
  }) async {
    try {
      if (row.isPending) {
        await handlePendingInlineRowEdit(parentSectionId, inline, row);
        return;
      }
      final rawRow = row.rawRow;
      if (rawRow == null) return;
      final id = rawRow['id'];
      if (id == null) return;
      final data = Map<String, dynamic>.from(rawRow);
      if (forForm) {
        final editSectionId = inline.formSectionId ?? targetSectionId;
        await _inlineNavigationCoordinator.openInlineStandaloneEdit(
          parentSectionId: parentSectionId,
          inline: inline,
          targetSectionId: editSectionId,
          row: data,
        );
      } else {
        final bool shouldNavigateToSection =
            parentSectionId == targetSectionId &&
            _sectionExistsResolver(targetSectionId);
        if (shouldNavigateToSection) {
          _pushNavigationSnapshot();
          await _sectionActionController.showDetail(targetSectionId, data);
        } else {
          await _inlineNavigationCoordinator.openInlineDetailPage(
            parentSectionId: parentSectionId,
            inline: inline,
            targetSectionId: targetSectionId,
            row: data,
          );
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Error al navegar a $targetSectionId: $error\n$stackTrace');
      _showMessage('No se pudo abrir el registro: $error');
    }
  }

  Future<void> handleInlineBulkDelete(
    String parentSectionId,
    InlineSectionConfig inline,
    List<TableRowData> rows,
    Map<String, dynamic> parentRow,
  ) async {
    await _inlineBulkDeleteCoordinator.bulkDelete(
      parentSectionId: parentSectionId,
      inline: inline,
      rows: rows,
      parentRow: parentRow,
    );
  }

  Future<void> handleInlineView(
    String parentSectionId,
    InlineSectionConfig inline,
    Map<String, dynamic> parentRow,
  ) async {
    await _inlineNavigationCoordinator.openInlineSectionTablePage(
      parentSectionId: parentSectionId,
      inline: inline,
      parentRow: parentRow,
      onCreate: handleInlineCreate,
      onBulkDelete: handleInlineBulkDelete,
    );
  }

  Future<void> _refreshParentSection(String parentSectionId) async {
    if (parentSectionId.isEmpty) return;
    try {
      await _sectionRefresher(parentSectionId);
    } catch (error, stackTrace) {
      debugPrint(
        'Error refreshing $parentSectionId after inline action: $error\n$stackTrace',
      );
    }
  }

  bool _validateUniqueInlineProduct({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
    required String itemId,
    String? excludePendingId,
    dynamic excludeRowId,
  }) {
    if (itemId.isEmpty) return true;
    String? message;
    if (inline.id == 'movimientos_detalle') {
      message = _movimientoInlineCoordinator.validateUniqueMovimientoProducto(
        parentSectionId: parentSectionId,
        inline: inline,
        parentRow: parentRow,
        productId: itemId,
        excludePendingId: excludePendingId,
        excludeRowId: excludeRowId,
      );
    } else if (inline.id == 'pedidos_detalle') {
      message = _pedidoPagoCoordinator.validateUniquePedidoProducto(
        parentSectionId: parentSectionId,
        inline: inline,
        parentRow: parentRow,
        productId: itemId,
        excludePendingId: excludePendingId,
        excludeRowId: excludeRowId,
      );
    } else if (inline.id == 'viajes_detalle') {
      message = _inlineValidationEngine.validateUniqueViajeMovimiento(
        parentSectionId: parentSectionId,
        inline: inline,
        parentRow: parentRow,
        movimientoId: itemId,
        excludePendingId: excludePendingId,
        excludeRowId: excludeRowId,
      );
    } else if (inline.id == 'compras_detalle' ||
        inline.id == 'compras_movimiento_detalle') {
      message = _inlineValidationEngine.validateUniqueCompraProducto(
        parentSectionId: parentSectionId,
        inline: inline,
        parentRow: parentRow,
        productId: itemId,
        excludePendingId: excludePendingId,
        excludeRowId: excludeRowId,
      );
    } else if (inline.id == 'fabricaciones_internas_resultados') {
      message = _inlineValidationEngine.validateUniqueFabricacionProducto(
        parentSectionId: parentSectionId,
        inline: inline,
        parentRow: parentRow,
        productId: itemId,
        excludePendingId: excludePendingId,
        excludeRowId: excludeRowId,
      );
    }
    if (message == null) return true;
    _showMessage(message);
    return false;
  }

  Future<void> validateMovimientoBaseSelection(String sectionId) async {
    final message = await _inlineStockValidator
        .validateMovimientoBaseSelection(
      sectionId: sectionId,
      values: _formDraftValues[sectionId],
    );
    if (message != null) {
      _showMessage(message);
    }
  }

  Future<bool> _ensurePedidoBaseHasStock({
    required Map<String, dynamic>? pedidoRow,
    required Map<String, String> values,
    String? pedidoIdFallback,
    VoidCallback? onInsufficientStock,
  }) async {
    final message = await _inlineStockValidator.ensurePedidoBaseHasStock(
      pedidoRow: pedidoRow,
      values: values,
      pedidoIdFallback: pedidoIdFallback,
    );
    if (message == null) return true;
    onInsufficientStock?.call();
    _showMessage(message);
    return false;
  }

  bool _ensureSectionValidation(
    String sectionId,
    Map<String, String> values, {
    BuildContext? feedbackContext,
  }) {
    final error = _sectionFormCoordinator.ensureSectionValidation(
      sectionId,
      values,
    );
    if (error == null) return true;
    if (feedbackContext != null) {
      if (feedbackContext.mounted) {
        ScaffoldMessenger.of(
          feedbackContext,
        ).showSnackBar(SnackBar(content: Text(error)));
      } else {
        _showMessage(error);
      }
    } else {
      _showMessage(error);
    }
    return false;
  }
}
