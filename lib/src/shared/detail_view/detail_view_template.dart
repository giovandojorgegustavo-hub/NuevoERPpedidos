import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:flutter/material.dart';

class DetailFieldConfig {
  const DetailFieldConfig({
    required this.label,
    required this.value,
    this.isReference = false,
    this.onReferenceTap,
    this.helperText,
  });

  final String label;
  final String value;
  final bool isReference;
  final VoidCallback? onReferenceTap;
  final String? helperText;
}

class DetailActionConfig {
  const DetailActionConfig({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

class DetailViewConfig {
  const DetailViewConfig({
    required this.title,
    required this.subtitle,
    required this.fields,
    this.inlineSections = const [],
    this.headerActions = const [],
    this.moreActions = const [],
    this.deleteAction,
    this.onBack,
    this.floatingAction,
  });

  final String title;
  final String subtitle;
  final List<DetailFieldConfig> fields;
  final List<InlineTableConfig> inlineSections;
  final List<DetailActionConfig> headerActions;
  final List<DetailActionConfig> moreActions;
  final DetailActionConfig? deleteAction;
  final VoidCallback? onBack;
  final DetailActionConfig? floatingAction;

  DetailViewConfig copyWith({
    String? title,
    String? subtitle,
    List<DetailFieldConfig>? fields,
    List<InlineTableConfig>? inlineSections,
    List<DetailActionConfig>? headerActions,
    List<DetailActionConfig>? moreActions,
    DetailActionConfig? deleteAction,
    VoidCallback? onBack,
    DetailActionConfig? floatingAction,
  }) {
    return DetailViewConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      fields: fields ?? this.fields,
      inlineSections: inlineSections ?? this.inlineSections,
      headerActions: headerActions ?? this.headerActions,
      moreActions: moreActions ?? this.moreActions,
      deleteAction: deleteAction ?? this.deleteAction,
      onBack: onBack ?? this.onBack,
      floatingAction: floatingAction ?? this.floatingAction,
    );
  }
}

class DetailViewTemplate extends StatelessWidget {
  const DetailViewTemplate({
    super.key,
    required this.config,
  });

  final DetailViewConfig config;

  @override
  Widget build(BuildContext context) {
    final hasFloating = config.floatingAction != null;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, hasFloating ? 96 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 16),
                      if (config.headerActions.isNotEmpty) ...[
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: config.headerActions
                              .map(
                                (action) => FilledButton.tonalIcon(
                                  onPressed: action.onPressed,
                                  icon: Icon(action.icon, size: 18),
                                  label: Text(action.label),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ..._buildFieldCards(context),
                      for (final inline in config.inlineSections) ...[
                        const SizedBox(height: 24),
                        InlineTableTemplate(config: inline),
                      ],
                    ],
                  ),
                ),
              ),
              if (hasFloating)
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: FloatingActionButton.extended(
                    onPressed: config.floatingAction!.onPressed,
                    icon: Icon(config.floatingAction!.icon),
                    label: Text(config.floatingAction!.label),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (config.onBack != null)
          IconButton(
            onPressed: config.onBack,
            icon: const Icon(Icons.arrow_back),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (config.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  config.subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
        if (config.deleteAction != null &&
            config.onBack == null)
          IconButton(
            tooltip: config.deleteAction!.label,
            onPressed: config.deleteAction!.onPressed,
            icon: Icon(config.deleteAction!.icon),
          ),
        if (config.moreActions.isNotEmpty)
          PopupMenuButton<DetailActionConfig>(
            tooltip: 'Acciones',
            onSelected: (action) => action.onPressed(),
            itemBuilder: (context) => [
              for (final action in config.moreActions)
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
    );
  }

  List<Widget> _buildFieldCards(BuildContext context) {
    final List<Widget> cards = [];
    for (var i = 0; i < config.fields.length; i++) {
      final field = config.fields[i];
      cards.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 6),
            _buildValueTile(context, field),
            if (i < config.fields.length - 1)
              const Divider(height: 24),
          ],
        ),
      );
    }
    return cards;
  }

  Widget _buildValueTile(BuildContext context, DetailFieldConfig field) {
    final valueText = Text(
      field.value.isEmpty ? '-' : field.value,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w600),
    );
    final helper = field.helperText == null
        ? null
        : Text(
            field.helperText!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black45),
          );
    if (!field.isReference) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          valueText,
          if (helper != null) ...[
            const SizedBox(height: 4),
            helper,
          ],
        ],
      );
    }
    return InkWell(
      onTap: field.onReferenceTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  valueText,
                  if (helper != null) ...[
                    const SizedBox(height: 4),
                    helper,
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
