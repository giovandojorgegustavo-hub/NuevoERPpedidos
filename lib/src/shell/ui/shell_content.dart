import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/ui/module_card.dart';
import 'package:erp_app/src/shell/ui/section_content_view.dart';
import 'package:flutter/material.dart';

class ShellContent extends StatelessWidget {
  const ShellContent({
    super.key,
    required this.modules,
    required this.selectedSection,
    required this.activeModule,
    required this.activeSectionId,
    required this.onModuleSelected,
    required this.showModulePicker,
    required this.onShowModulePicker,
    required this.contentMode,
    required this.onContentModeChanged,
    required this.globalActions,
    required this.onGlobalAction,
    required this.isSectionLoading,
    required this.tableConfig,
    required this.detailConfig,
    required this.formConfig,
    this.onRowSelected,
    this.onCreate,
  });

  final List<ModuleConfig> modules;
  final ModuleSection? selectedSection;
  final ModuleConfig activeModule;
  final String? activeSectionId;
  final ValueChanged<ModuleConfig> onModuleSelected;
  final bool showModulePicker;
  final VoidCallback onShowModulePicker;
  final SectionContentMode contentMode;
  final ValueChanged<SectionContentMode> onContentModeChanged;
  final List<GlobalNavAction> globalActions;
  final ValueChanged<GlobalNavAction> onGlobalAction;
  final bool isSectionLoading;
  final TableViewConfig? tableConfig;
  final DetailViewConfig? detailConfig;
  final FormViewConfig? formConfig;
  final ValueChanged<TableRowData>? onRowSelected;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: showModulePicker
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Módulos disponibles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: modules
                        .map(
                          (module) => ModuleCard(
                            module: module,
                            isSelected: module.id == activeModule.id,
                            onTap: () => onModuleSelected(module),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Selecciona un módulo para visualizar sus vistas y acciones.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SectionContentView(
                    selectedSection: selectedSection,
                    tableConfig: tableConfig,
                    detailConfig: detailConfig,
                    formConfig: formConfig,
                    contentMode: contentMode,
                    onContentModeChanged: onContentModeChanged,
                    isSectionLoading: isSectionLoading,
                    onRowSelected: onRowSelected,
                    onCreate: onCreate,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: onShowModulePicker,
                    icon: const Icon(Icons.apps),
                    label: const Text('Ver módulos'),
                  ),
                ),
              ],
            ),
    );
  }
}
