import 'package:erp_app/src/shell/models.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.module,
    required this.selectedSectionId,
    required this.onSectionSelected,
    required this.globalActions,
    required this.onGlobalAction,
  });

  final ModuleConfig module;
  final String? selectedSectionId;
  final ValueChanged<String> onSectionSelected;
  final List<GlobalNavAction> globalActions;
  final ValueChanged<GlobalNavAction> onGlobalAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModuleHeader(module: module),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Vistas del módulo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: module.sections.isEmpty
                ? const Center(
                    child: Text(
                      'Sin secciones configuradas',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: module.sections.length,
                    itemBuilder: (context, index) {
                      final section = module.sections[index];
                      final isActive = section.id == selectedSectionId;
                      return ListTile(
                        leading: Icon(
                          section.icon,
                          color: isActive ? Colors.indigo : Colors.black54,
                        ),
                        title: Text(
                          section.label,
                          style: TextStyle(
                            color: isActive
                                ? Colors.indigo
                                : Colors.grey.shade800,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () => onSectionSelected(section.id),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Global',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
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
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.module});

  final ModuleConfig module;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE6E8F0))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.indigo.withValues(alpha: 0.12),
            child: Icon(module.icon, color: Colors.indigo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  module.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
