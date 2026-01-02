import 'package:erp_app/src/navegacion/inline_types.dart';
import 'package:erp_app/src/shared/inline_table/inline_helpers.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';

InlineTableConfig buildPagosVistaInlineView(
  InlineSectionViewContext context,
) {
  final keyToLabel = buildInlineColumnLabelMap(context.inlineConfig);
  final rows = context.defaultConfig.rows
      .map(
        (row) => copyInlineRow(
          row,
          {
            keyToLabel['fechapago'] ?? 'Fecha':
                inlineValueFromRow(row, 'fechapago', keyToLabel),
            keyToLabel['cuenta_nombre'] ?? 'Cuenta':
                inlineValueFromRow(row, 'cuenta_nombre', keyToLabel),
            keyToLabel['monto'] ?? 'Monto':
                inlineValueFromRow(row, 'monto', keyToLabel),
          },
        ),
      )
      .toList(growable: false);
  final config = rebuildInlineConfig(context, rows);
  final saldo =
      (context.sectionContext['pedido_saldo'] as num?)?.toDouble() ??
          double.infinity;
  final hasSaldo = saldo > 0.0001;
  return InlineTableConfig(
    title: config.title,
    columns: config.columns,
    rows: config.rows,
    collapsedByDefault: config.collapsedByDefault,
    primaryAction: hasSaldo ? config.primaryAction : null,
    secondaryAction: config.secondaryAction,
    emptyPlaceholder: config.emptyPlaceholder,
    isLoading: config.isLoading,
    enableSelection: config.enableSelection,
    selectionActions: config.selectionActions,
    onRowTap: config.onRowTap,
  );
}

Map<String, String> buildPagosVistaPendingDisplay(
  InlinePendingDisplayContext context,
) {
  final fecha = normalizeInlineValue(context.rawValues['fechapago']);
  final cuentaId = normalizeInlineValue(context.rawValues['idcuenta']);
  final monto = normalizeInlineValue(context.rawValues['monto']);
  return {
    'fechapago': fecha,
    'cuenta_nombre': cuentaId.isEmpty
        ? ''
        : context.resolveReferenceLabel('idcuenta', cuentaId) ?? '',
    'monto': monto,
  };
}
