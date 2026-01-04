import 'package:erp_app/src/navegacion/inline_builders.dart';
import 'package:erp_app/src/shared/inline_table/inline_pending_row.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';

class InlineTablePresenter {
  InlineTablePresenter({
    required SectionStateController sectionStateController,
    required InlineDraftService inlineDraftService,
    required SectionContextResolver sectionContextResolver,
    required InlineRowNavigator rowNavigator,
    required InlineCreateHandler createHandler,
    required InlineViewHandler viewHandler,
    required InlineBulkDeleteHandler bulkDeleteHandler,
    required InlineValueFormatter valueFormatter,
  })  : _sectionStateController = sectionStateController,
        _inlineDraftService = inlineDraftService,
        _sectionContextResolver = sectionContextResolver,
        _rowNavigator = rowNavigator,
        _createHandler = createHandler,
        _viewHandler = viewHandler,
        _bulkDeleteHandler = bulkDeleteHandler,
        _valueFormatter = valueFormatter;

  final SectionStateController _sectionStateController;
  final InlineDraftService _inlineDraftService;
  final SectionContextResolver _sectionContextResolver;
  final InlineRowNavigator _rowNavigator;
  final InlineCreateHandler _createHandler;
  final InlineViewHandler _viewHandler;
  final InlineBulkDeleteHandler _bulkDeleteHandler;
  final InlineValueFormatter _valueFormatter;

  List<InlineTableConfig> buildTables(
    String sectionId,
    Map<String, dynamic> parentRow, {
    required bool forForm,
    SectionFormMode? formMode,
  }) {
    final overrides =
        _sectionStateController.inlineSectionOverrides[sectionId];
    if (overrides == null || overrides.isEmpty) return const [];
    final List<InlineTableConfig> tables = [];
    final rowId = parentRow['id'];
    final isCreateMode = formMode == SectionFormMode.create;
    for (final inline in overrides) {
      final shouldRender = forForm ? inline.showInForm : inline.showInDetail;
      if (!shouldRender) continue;
      if (forForm && inline.requiresPersistedParent) {
        final hasPersistedParent =
            rowId != null && rowId.toString().trim().isNotEmpty;
        if (!hasPersistedParent || isCreateMode) {
          continue;
        }
      }
      final List<InlineTableRow> rows = [];
      bool isLoading = false;
      if (rowId != null) {
        final key =
            _inlineDraftService.inlineKey(sectionId, rowId, inline.id);
        final rawRows =
            _inlineDraftService.inlineSectionData[key] ??
                const <Map<String, dynamic>>[];
        rows.addAll(
          rawRows.map((data) => _fromPersistedRow(inline, data)),
        );
        isLoading = _inlineDraftService.inlineLoadingKeys.contains(key);
        rows.addAll(
          _inlineDraftService
              .findPendingRows(sectionId, inline.id)
              .map((entry) => _fromPendingRow(inline, entry)),
        );
      } else {
        rows.addAll(
          _inlineDraftService
              .findPendingRows(sectionId, inline.id)
              .map((entry) => _fromPendingRow(inline, entry)),
        );
      }
      final isParentLocked = _isParentLocked(sectionId, parentRow);
      final isDetalleCerrado = (inline.id == 'compras_detalle' ||
              inline.id == 'compras_movimiento_detalle') &&
          _isDetalleCerrado(parentRow, key: 'detalle_cerrado');
      final selectionActions = isParentLocked
          ? const <InlineSelectionAction>[]
          : _buildSelectionActions(sectionId, inline, parentRow);
      final rowTapTargetSectionId = inline.rowTapSectionId ?? inline.formSectionId;
      final Future<void> Function(InlineTableRow row)? onRowTap =
          rowTapTargetSectionId == null
              ? null
              : (InlineTableRow inlineRow) => _rowNavigator(
                    parentSectionId: sectionId,
                    targetSectionId: rowTapTargetSectionId,
                    inline: inline,
                    row: inlineRow,
                    forForm: forForm,
                  );
      InlineTableConfig tableConfig = InlineTableConfig(
        title: inline.title,
        columns: inline.columns.map((column) => column.label).toList(),
        rows: rows,
        collapsedByDefault: inline.collapsedByDefault,
        emptyPlaceholder: inline.emptyPlaceholder,
        isLoading: isLoading,
        enableSelection: selectionActions.isNotEmpty,
        selectionActions: selectionActions,
        onRowTap: onRowTap,
        primaryAction: inline.enableCreate && !isParentLocked && !isDetalleCerrado
            ? InlineTableAction(
                label: 'Nuevo',
                onPressed: () => _createHandler(
                  sectionId,
                  inline,
                  parentRow,
                  forForm: forForm,
                ),
              )
            : null,
        secondaryAction: inline.enableView
            ? InlineTableAction(
                label: 'Ver',
                onPressed: () => _viewHandler(sectionId, inline, parentRow),
              )
            : null,
      );
      final inlineBuilder = kInlineSectionViewBuilders[inline.id];
      if (inlineBuilder != null) {
        final builderSectionId = inline.formSectionId ?? sectionId;
        final parentSectionContext = _sectionContextResolver(sectionId);
        final builderSectionContext =
            _sectionContextResolver(builderSectionId);
        tableConfig = inlineBuilder(
          InlineSectionViewContext(
            inlineConfig: inline,
            defaultConfig: tableConfig,
            parentRow: parentRow,
            parentSectionId: sectionId,
            parentSectionContext: parentSectionContext,
            sectionContext: builderSectionContext,
            forForm: forForm,
            builderSectionId: builderSectionId,
          ),
        );
      }
      tables.add(tableConfig);
    }
    return tables;
  }

  InlineTableRow _fromPersistedRow(
    InlineSectionConfig config,
    Map<String, dynamic> data,
  ) {
    return InlineTableRow(
      displayValues: {
        for (final column in config.columns)
          column.label: _valueFormatter(data[column.key]),
      },
      rawRow: Map<String, dynamic>.from(data),
      isPending: false,
    );
  }

  InlineTableRow _fromPendingRow(
    InlineSectionConfig config,
    InlinePendingRow entry,
  ) {
    final rawRow = <String, dynamic>{
      ...entry.displayValues,
      ...entry.rawValues,
      '__pending': true,
      '__pending_id': entry.pendingId,
      '__pending_raw_values': entry.rawValues,
      '__pending_display_values': entry.displayValues,
    };
    return InlineTableRow(
      displayValues: {
        for (final column in config.columns)
          column.label: _valueFormatter(entry.displayValues[column.key]),
      },
      rawRow: rawRow,
      isPending: true,
      pendingId: entry.pendingId,
    );
  }

  List<InlineSelectionAction> _buildSelectionActions(
    String sectionId,
    InlineSectionConfig inline,
    Map<String, dynamic> parentRow,
  ) {
    final targetSectionId = inline.formSectionId;
    if (targetSectionId == null) return const [];
    if (inline.id == 'compras_historial_contable' ||
        inline.id == 'compras_eventos') {
      return const [];
    }
    if (inline.id == 'compras_detalle' &&
        _isDetalleCerrado(parentRow, key: 'detalle_cerrado')) {
      return const [];
    }
    if (inline.id == 'compras_movimiento_detalle' &&
        _isDetalleCerrado(parentRow, key: 'detalle_cerrado')) {
      return const [];
    }
    final deleteLabel = inline.id == 'compras_pagos'
        ? 'Reversar pago'
        : inline.id == 'compras_movimientos'
            ? 'Reversar movimiento'
            : (inline.id == 'pedidos_detalle' ||
                    inline.id == 'pedidos_pagos' ||
                    inline.id == 'pedidos_movimientos')
                ? 'Cancelar/Revertir'
                : 'Eliminar';
    return [
      InlineSelectionAction(
        label: deleteLabel,
        onSelected: (rows) async {
          final tableRows = rows
              .map((row) => Map<String, dynamic>.from(row.rawRow ?? const {}))
              .toList(growable: false);
          if (tableRows.isEmpty) return;
          await _bulkDeleteHandler(
            sectionId,
            inline,
            tableRows,
            parentRow,
          );
        },
      ),
    ];
  }

  bool _isParentLocked(String sectionId, Map<String, dynamic> row) {
    if (sectionId == 'compras') {
      return _isCompraCancelada(row);
    }
    if (sectionId == 'compras_movimientos') {
      final estado = row['compra_estado']?.toString().toLowerCase().trim();
      return estado == 'cancelado';
    }
    if (sectionId != 'fabricaciones_internas' &&
        sectionId != 'fabricaciones_maquila') {
      return false;
    }
    final estadoRaw = row['estado_codigo'] ?? row['estado'];
    final estado = estadoRaw?.toString().toLowerCase().trim();
    return estado == 'cancelado';
  }

  bool _isCompraCancelada(Map<String, dynamic> row) {
    final estado = row['estado']?.toString().toLowerCase().trim();
    return estado == 'cancelado';
  }

  bool _isDetalleCerrado(
    Map<String, dynamic> row, {
    required String key,
  }) {
    final value = row[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim() ?? '';
    return text == 'true' || text == '1';
  }
}

typedef InlineRowNavigator = Future<void> Function({
  required String parentSectionId,
  required String targetSectionId,
  required InlineSectionConfig inline,
  required InlineTableRow row,
  required bool forForm,
});

typedef InlineCreateHandler = Future<void> Function(
  String parentSectionId,
  InlineSectionConfig inline,
  Map<String, dynamic> parentRow, {
  required bool forForm,
});

typedef InlineViewHandler = Future<void> Function(
  String parentSectionId,
  InlineSectionConfig inline,
  Map<String, dynamic> parentRow,
);

typedef InlineBulkDeleteHandler = Future<void> Function(
  String parentSectionId,
  InlineSectionConfig inline,
  List<TableRowData> rows,
  Map<String, dynamic> parentRow,
);

typedef InlineValueFormatter = String Function(dynamic value);
