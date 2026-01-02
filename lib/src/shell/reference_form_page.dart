import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:flutter/material.dart';

class ReferenceFormPage extends StatefulWidget {
  const ReferenceFormPage({
    super.key,
    required this.title,
    this.config,
    this.configBuilder,
    this.refreshListenable,
  }) : assert(config != null || configBuilder != null);

  final String title;
  final FormViewConfig? config;
  final FormViewConfig Function()? configBuilder;
  final Listenable? refreshListenable;

  @override
  State<ReferenceFormPage> createState() => _ReferenceFormPageState();
}

class _ReferenceFormPageState extends State<ReferenceFormPage> {
  @override
  void initState() {
    super.initState();
    widget.refreshListenable?.addListener(_handleRefresh);
  }

  @override
  void didUpdateWidget(covariant ReferenceFormPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshListenable != widget.refreshListenable) {
      oldWidget.refreshListenable?.removeListener(_handleRefresh);
      widget.refreshListenable?.addListener(_handleRefresh);
    }
  }

  @override
  void dispose() {
    widget.refreshListenable?.removeListener(_handleRefresh);
    super.dispose();
  }

  void _handleRefresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.configBuilder?.call() ?? widget.config!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FormViewTemplate(config: config),
      ),
    );
  }
}
