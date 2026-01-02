import 'package:erp_app/src/navegacion/inline_types.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:erp_app/src/shell/models.dart';

/// Utilidades compartidas para formatear tablas inline.
///
/// Estas funciones encapsulan la lógica necesaria para reutilizar la
/// configuración generada por defecto (columnas, acciones) mientras se
/// ajustan los valores visibles, incluso cuando las filas aún son borradores
/// (`__pending_display_values`). Se pueden utilizar en cualquier inline view
/// que necesite presentar etiquetas personalizadas o datos derivados.

Map<String, String> buildInlineColumnLabelMap(InlineSectionConfig config) {
  return {
    for (final column in config.columns) column.key: column.label,
  };
}

InlineTableConfig rebuildInlineConfig(
  InlineSectionViewContext context,
  List<InlineTableRow> rows,
) {
  final defaultConfig = context.defaultConfig;
  return InlineTableConfig(
    title: defaultConfig.title,
    columns: defaultConfig.columns,
    rows: rows,
    collapsedByDefault: defaultConfig.collapsedByDefault,
    primaryAction: defaultConfig.primaryAction,
    secondaryAction: defaultConfig.secondaryAction,
    emptyPlaceholder: defaultConfig.emptyPlaceholder,
    isLoading: defaultConfig.isLoading,
    enableSelection: defaultConfig.enableSelection,
    selectionActions: defaultConfig.selectionActions,
    onRowTap: defaultConfig.onRowTap,
    filters: defaultConfig.filters,
  );
}

InlineTableRow copyInlineRow(
  InlineTableRow source,
  Map<String, String> displayValues,
) {
  return InlineTableRow(
    displayValues: displayValues,
    rawRow: source.rawRow,
    isPending: source.isPending,
    pendingId: source.pendingId,
  );
}

String inlineValueFromRow(
  InlineTableRow row,
  String columnKey,
  Map<String, String> labelMap,
) {
  final rawValue = normalizeInlineValue(row.rawRow?[columnKey]);
  if (rawValue.isNotEmpty) return rawValue;
  final pendingDisplay =
      (row.rawRow?['__pending_display_values'] as Map<String, dynamic>?)
          ?[columnKey];
  final pendingValue = normalizeInlineValue(pendingDisplay);
  if (pendingValue.isNotEmpty) return pendingValue;
  final label = labelMap[columnKey] ?? columnKey;
  return normalizeInlineValue(row.displayValues[label]);
}

String normalizeInlineValue(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return '';
  return text;
}

bool parseInlineBool(dynamic value) {
  final text = value?.toString().toLowerCase();
  if (text == null) return false;
  return text == 'true' || text == '1';
}
