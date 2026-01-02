import 'package:flutter/material.dart';
import 'package:erp_app/src/navegacion/inline_types.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_helpers.dart';

InlineTableConfig buildMovimientosDetalleInlineView(
  InlineSectionViewContext context,
) {
  final defaultConfig = context.defaultConfig;
  final rows = context.defaultConfig.rows;
  final sectionContext = context.parentSectionContext;

  final bool? hasRemainingFlag =
      sectionContext['movimientos_detalle_hasRemaining'] as bool?;
  final VoidCallback? completeAction =
      sectionContext['movimientos_detalle_complete_action'] as VoidCallback?;
  debugPrint(
      '[mov-det-inline] hasRemaining=$hasRemainingFlag hasAction=${completeAction != null}');

  if (hasRemainingFlag == null) {
    return rebuildInlineConfig(context, rows);
  }

  final InlineTableAction? createAction = hasRemainingFlag
      ? defaultConfig.primaryAction
      : null;

  final InlineTableAction? completarAction =
      hasRemainingFlag && completeAction != null
          ? InlineTableAction(
              label: 'Completar',
              onPressed: completeAction,
            )
          : null;

  return InlineTableConfig(
    title: defaultConfig.title,
    columns: defaultConfig.columns,
    rows: rows,
    collapsedByDefault: defaultConfig.collapsedByDefault,
    primaryAction: completarAction ?? createAction,
    secondaryAction: completarAction != null ? createAction : null,
    emptyPlaceholder: defaultConfig.emptyPlaceholder,
    isLoading: defaultConfig.isLoading,
    enableSelection: defaultConfig.enableSelection,
    selectionActions: defaultConfig.selectionActions,
    onRowTap: defaultConfig.onRowTap,
  );
}
