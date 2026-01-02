import 'package:erp_app/src/shell/models.dart';
import 'package:flutter/material.dart';

class MultiSectionDrawer extends StatelessWidget {
  const MultiSectionDrawer({
    super.key,
    required this.module,
    required this.selectedSectionId,
    required this.globalActions,
    required this.onSectionSelected,
    required this.onGlobalAction,
  });

  final ModuleConfig? module;
  final String? selectedSectionId;
  final List<GlobalNavAction> globalActions;
  final ValueChanged<String> onSectionSelected;
  final ValueChanged<GlobalNavAction> onGlobalAction;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (module != null) ...[
              DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      module!.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module!.description,
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
              if (module!.sections.isEmpty)
                const ListTile(
                  title: Text('Sin vistas configuradas'),
                  dense: true,
                )
              else
                ...module!.sections.map(
                  (section) => ListTile(
                    leading: Icon(section.icon),
                    title: Text(section.label),
                    selected: section.id == selectedSectionId,
                    onTap: () => onSectionSelected(section.id),
                  ),
                ),
            ],
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
                onTap: () => onGlobalAction(action),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
