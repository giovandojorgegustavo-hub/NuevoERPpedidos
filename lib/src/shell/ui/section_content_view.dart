import 'package:erp_app/src/navegacion/section_custom_builders.dart';
import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:flutter/material.dart';

class SectionContentView extends StatelessWidget {
  const SectionContentView({
    super.key,
    required this.selectedSection,
    required this.tableConfig,
    required this.detailConfig,
    required this.formConfig,
    required this.contentMode,
    required this.onContentModeChanged,
    required this.isSectionLoading,
    this.onRowSelected,
    this.onCreate,
  });

  final ModuleSection? selectedSection;
  final TableViewConfig? tableConfig;
  final DetailViewConfig? detailConfig;
  final FormViewConfig? formConfig;
  final SectionContentMode contentMode;
  final ValueChanged<SectionContentMode> onContentModeChanged;
  final bool isSectionLoading;
  final ValueChanged<TableRowData>? onRowSelected;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    Widget contentChild;
    DetailViewConfig? detailConfigAdjusted;
    final detail = detailConfig;
    if (detail != null) {
      detailConfigAdjusted = detail.copyWith(
        onBack:
            detail.onBack ??
            () => onContentModeChanged(SectionContentMode.table),
      );
    }
    final originalFormConfig = formConfig;
    final formConfigAdjusted = originalFormConfig?.copyWith(
      onCancel: () {
        originalFormConfig.onCancel?.call();
        onContentModeChanged(SectionContentMode.table);
      },
    );

    switch (contentMode) {
      case SectionContentMode.detail:
        contentChild = detailConfigAdjusted != null
            ? DetailViewTemplate(config: detailConfigAdjusted)
            : buildSectionPlaceholder(selectedSection);
        break;
      case SectionContentMode.form:
        contentChild = formConfigAdjusted != null
            ? FormViewTemplate(config: formConfigAdjusted)
            : buildSectionPlaceholder(selectedSection);
        break;
      case SectionContentMode.table:
        if (isSectionLoading) {
          contentChild = const Center(child: CircularProgressIndicator());
        } else {
          if (tableConfig != null) {
            final customBuilder = selectedSection?.id == null
                ? null
                : kSectionCustomTableBuilders[selectedSection!.id];
            if (customBuilder != null) {
              contentChild = customBuilder(context, tableConfig!);
            } else {
              contentChild = TableViewTemplate(
                config: tableConfig!,
                onRowTap: tableConfig!.rowTapAction == null &&
                        detailConfig != null &&
                        onRowSelected != null
                    ? onRowSelected
                    : null,
                onPrimaryAction: onCreate,
              );
            }
          } else {
            contentChild = buildSectionPlaceholder(selectedSection);
          }
        }
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(8), child: contentChild),
    );
  }
}

Widget buildSectionPlaceholder(ModuleSection? section) {
  return DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFFF3F5FF),
    ),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          section == null
              ? 'Configura al menos una vista para comenzar.'
              : 'Aquí se renderizará la vista "${section.label}".',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    ),
  );
}
