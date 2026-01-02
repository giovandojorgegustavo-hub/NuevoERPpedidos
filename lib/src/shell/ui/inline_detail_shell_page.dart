import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/ui/multi_section_drawer.dart';
import 'package:erp_app/src/shell/widgets/sidebar.dart';
import 'package:flutter/material.dart';

class InlineDetailShellPage extends StatelessWidget {
  const InlineDetailShellPage({
    super.key,
    required this.detailConfig,
    required this.activeModule,
    required this.selectedSectionId,
    required this.globalActions,
    required this.onSectionSelected,
    required this.onGlobalAction,
  });

  final DetailViewConfig detailConfig;
  final ModuleConfig? activeModule;
  final String? selectedSectionId;
  final List<GlobalNavAction> globalActions;
  final ValueChanged<String> onSectionSelected;
  final ValueChanged<GlobalNavAction> onGlobalAction;

  @override
  Widget build(BuildContext context) {
    final module = activeModule;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        if (isCompact) {
          return Scaffold(
            appBar: AppBar(
              title: Text(detailConfig.title),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: detailConfig.onBack,
              ),
              actions: [
                if (globalActions.isNotEmpty)
                  PopupMenuButton<GlobalNavAction>(
                    tooltip: 'Acciones globales',
                    onSelected: (action) {
                      Navigator.of(context).pop();
                      onGlobalAction(action);
                    },
                    itemBuilder: (context) => [
                      for (final action in globalActions)
                        PopupMenuItem(
                          value: action,
                          child: Row(
                            children: [
                              Icon(action.icon, size: 18),
                              const SizedBox(width: 8),
                              Text(action.label),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            drawer: MultiSectionDrawer(
              module: module,
              selectedSectionId: selectedSectionId,
              globalActions: globalActions,
              onSectionSelected: (sectionId) {
                Navigator.of(context).pop();
                onSectionSelected(sectionId);
              },
              onGlobalAction: (action) {
                Navigator.of(context).pop();
                onGlobalAction(action);
              },
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: DetailViewTemplate(config: detailConfig),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              if (module != null)
                Sidebar(
                  module: module,
                  selectedSectionId: selectedSectionId,
                  onSectionSelected: (sectionId) {
                    Navigator.of(context).pop();
                    onSectionSelected(sectionId);
                  },
                  globalActions: globalActions,
                  onGlobalAction: (action) {
                    Navigator.of(context).pop();
                    onGlobalAction(action);
                  },
                ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F6FB),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DetailViewTemplate(config: detailConfig),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
