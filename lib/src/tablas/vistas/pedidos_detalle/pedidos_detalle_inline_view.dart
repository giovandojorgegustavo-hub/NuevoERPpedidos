import 'package:erp_app/src/navegacion/inline_types.dart';
import 'package:erp_app/src/shared/inline_table/inline_helpers.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';

InlineTableConfig buildPedidosDetalleInlineView(
  InlineSectionViewContext context,
) {
  final keyToLabel = buildInlineColumnLabelMap(context.inlineConfig);
  final rows = context.defaultConfig.rows
      .map(
        (row) => copyInlineRow(
          row,
          {
            keyToLabel['producto_nombre'] ?? 'Producto':
                inlineValueFromRow(row, 'producto_nombre', keyToLabel),
            keyToLabel['cantidad'] ?? 'Cantidad':
                inlineValueFromRow(row, 'cantidad', keyToLabel),
            keyToLabel['precioventa'] ?? 'Precio total':
                inlineValueFromRow(row, 'precioventa', keyToLabel),
          },
        ),
      )
      .toList(growable: false);
  return rebuildInlineConfig(context, rows);
}

Map<String, String> buildPedidosDetallePendingDisplay(
  InlinePendingDisplayContext context,
) {
  final productoId = normalizeInlineValue(context.rawValues['idproducto']);
  final cantidad = normalizeInlineValue(context.rawValues['cantidad']);
  final precio = normalizeInlineValue(context.rawValues['precioventa']);
  return {
    'producto_nombre': productoId.isEmpty
        ? ''
        : context.resolveReferenceLabel('idproducto', productoId) ?? '',
    'cantidad': cantidad,
    'precioventa': precio,
  };
}
