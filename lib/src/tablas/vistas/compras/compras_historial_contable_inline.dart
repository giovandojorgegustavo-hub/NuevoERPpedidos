import 'package:erp_app/src/navegacion/inline_types.dart';
import 'package:erp_app/src/shared/inline_table/inline_helpers.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';

InlineTableConfig buildComprasHistorialContableInlineView(
  InlineSectionViewContext context,
) {
  bool isTrue(dynamic value) => parseInlineBool(value);

  final filters = [
    InlineTableFilter(
      label: 'Mostrar solo alertas',
      behavior: InlineTableFilterBehavior.include,
      predicate: (row) => isTrue(row.rawRow?['alerta']),
    ),
    InlineTableFilter(
      label: 'Mostrar solo correcciones',
      behavior: InlineTableFilterBehavior.include,
      predicate: (row) => isTrue(row.rawRow?['is_correction']),
    ),
  ];

  return context.defaultConfig.copyWith(filters: filters);
}
