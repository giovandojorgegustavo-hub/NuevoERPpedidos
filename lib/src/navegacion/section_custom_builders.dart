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
    bool isAlertValue(dynamic value) {
      final text = value?.toString().toLowerCase();
      if (text == null) return false;
      return text == 'true' || text == '1' || text == 't';
    }

    final quickFilters = [
      TableQuickFilter(
        label: 'Mostrar solo alertas',
        behavior: TableQuickFilterBehavior.include,
        predicate: (row) => isAlertValue(row['alerta']),
      ),
    ];

    return TableViewTemplate(
      config: config.copyWith(quickFilters: quickFilters),
    );
  },
};
