import 'package:flutter/foundation.dart';

import 'package:erp_app/src/navegacion/inline_types.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';

InlineTableConfig buildAjustesDetalleInlineView(
  InlineSectionViewContext context,
) {
  final defaultConfig = context.defaultConfig;
  final rows = context.defaultConfig.rows;
  final sectionContext = context.parentSectionContext;

  final bool canComplete =
      sectionContext['ajustes_detalle_canComplete'] == true;
  final VoidCallback? completeAction =
      sectionContext['ajustes_detalle_complete_action'] as VoidCallback?;

  InlineTableAction? primaryAction = defaultConfig.primaryAction;
  InlineTableAction? secondaryAction = defaultConfig.secondaryAction;

  final InlineTableAction? completarAction =
      canComplete && completeAction != null
      ? InlineTableAction(label: 'Completar', onPressed: completeAction)
      : null;

  if (completarAction != null) {
    secondaryAction = primaryAction ?? secondaryAction;
    primaryAction = completarAction;
  }

  return InlineTableConfig(
    title: defaultConfig.title,
    columns: defaultConfig.columns,
    rows: rows,
    collapsedByDefault: defaultConfig.collapsedByDefault,
    primaryAction: primaryAction,
    secondaryAction: secondaryAction,
    emptyPlaceholder: defaultConfig.emptyPlaceholder,
    isLoading: defaultConfig.isLoading,
    enableSelection: defaultConfig.enableSelection,
    selectionActions: defaultConfig.selectionActions,
    onRowTap: defaultConfig.onRowTap,
  );
}

Map<String, String> buildAjustesDetallePendingDisplay(
  InlinePendingDisplayContext context,
) {
  final raw = context.rawValues;
  final productId = raw['idproducto']?.toString() ?? '';
  String producto = productId;
  if (productId.isNotEmpty) {
    producto = context.resolveReferenceLabel('idproducto', productId) ??
        raw['producto_nombre']?.toString() ??
        productId;
  }
  final sistemaText = _stringifyNumber(raw['cantidad_sistema']);
  final realText = _stringifyNumber(raw['cantidad_real']);
  String diferenciaText = _stringifyNumber(raw['cantidad']);
  if (diferenciaText.isEmpty) {
    final sistema = double.tryParse(raw['cantidad_sistema']?.toString() ?? '');
    final real = double.tryParse(raw['cantidad_real']?.toString() ?? '');
    if (sistema != null && real != null) {
      diferenciaText = _formatNumber(real - sistema);
    }
  }
  return <String, String>{
    'producto_nombre': producto,
    'cantidad_sistema': sistemaText,
    'cantidad_real': realText,
    'diferencia': diferenciaText,
  };
}

String _formatNumber(num value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

String _stringifyNumber(dynamic value) {
  if (value == null) return '';
  if (value is num) return _formatNumber(value);
  final parsed = double.tryParse(value.toString());
  if (parsed == null) return value.toString();
  return _formatNumber(parsed);
}
