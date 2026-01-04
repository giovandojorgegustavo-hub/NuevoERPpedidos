import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/tablas/vistas/contabilidad/balance_general_view.dart';
import 'package:flutter/widgets.dart';

typedef SectionTableBuilder = Widget Function(
  BuildContext context,
  TableViewConfig config,
);

final Map<String, SectionTableBuilder> kSectionCustomTableBuilders = {
  'contabilidad_balance_sheet': (context, config) =>
      BalanceGeneralBoard(config: config),
  'contabilidad_historial': (context, config) {
    bool isCorreccionValue(dynamic value) {
      final text = value?.toString().toLowerCase();
      if (text == null) return false;
      return text == 'correccion';
    }

    final quickFilters = [
      TableQuickFilter(
        label: 'Mostrar solo correcciones',
        behavior: TableQuickFilterBehavior.include,
        predicate: (row) => isCorreccionValue(row['tipo']),
      ),
    ];

    return TableViewTemplate(
      config: config.copyWith(quickFilters: quickFilters),
    );
  },
};
