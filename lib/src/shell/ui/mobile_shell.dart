import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/ui/module_card.dart';
import 'package:erp_app/src/shell/ui/section_content_view.dart';
import 'package:flutter/material.dart';

class MobileShell extends StatelessWidget {
  const MobileShell({
    super.key,
    required this.modules,
    required this.activeModule,
    required this.activeSectionId,
    required this.selectedSection,
    required this.showModulePicker,
    required this.onModuleSelected,
    required this.onSectionSelected,
    required this.globalActions,
    required this.onGlobalAction,
    required this.onShowModulePicker,
    required this.contentMode,
    required this.onContentModeChanged,
    required this.tableConfig,
    required this.detailConfig,
    required this.formConfig,
    required this.isSectionLoading,
    this.onRowSelected,
    this.onCreate,
  });

  final List<ModuleConfig> modules;
  final ModuleConfig activeModule;
  final String? activeSectionId;
  final ModuleSection? selectedSection;
  final bool showModulePicker;
  final ValueChanged<ModuleConfig> onModuleSelected;
  final ValueChanged<String> onSectionSelected;
  final List<GlobalNavAction> globalActions;
  final ValueChanged<GlobalNavAction> onGlobalAction;
  final VoidCallback onShowModulePicker;
  final SectionContentMode contentMode;
  final ValueChanged<SectionContentMode> onContentModeChanged;
  final TableViewConfig? tableConfig;
  final DetailViewConfig? detailConfig;
  final FormViewConfig? formConfig;
  final bool isSectionLoading;
  final ValueChanged<TableRowData>? onRowSelected;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activeModule.name),
        actions: [
          if (globalActions.isNotEmpty)
            PopupMenuButton<GlobalNavAction>(
              tooltip: 'Acciones globales',
              onSelected: onGlobalAction,
              itemBuilder: (context) => globalActions
                  .map(
                    (action) => PopupMenuItem<GlobalNavAction>(
                      value: action,
                      child: Row(
                        children: [
                          Icon(action.icon, size: 18),
                          const SizedBox(width: 8),
                          Text(action.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      activeModule.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeModule.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Vistas del módulo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              if (activeModule.sections.isEmpty)
                const ListTile(
                  title: Text('Sin vistas configuradas'),
                  dense: true,
                )
              else
                ...activeModule.sections.map(
                  (section) => ListTile(
                    leading: Icon(section.icon),
                    title: Text(section.label),
                    selected: section.id == activeSectionId,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSectionSelected(section.id);
                    },
                  ),
                ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Global',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              ...globalActions.map(
                (action) => ListTile(
                  leading: Icon(action.icon),
                  title: Text(action.label),
                  onTap: () {
                    Navigator.of(context).pop();
                    onGlobalAction(action);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: showModulePicker
            ? ListView(
                children: [
                  Text(
                    'Módulos disponibles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: modules.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        return ModuleCard(
                          module: module,
                          isSelected: module.id == activeModule.id,
                          onTap: () => onModuleSelected(module),
                          width: 200,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Selecciona un módulo para ver sus vistas y contenidos.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ],
              )
            : Column(
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onShowModulePicker,
                      icon: const Icon(Icons.apps),
                      label: const Text('Ver módulos disponibles'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
