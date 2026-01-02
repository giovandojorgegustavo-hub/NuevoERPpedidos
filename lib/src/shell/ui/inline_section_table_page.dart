import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:flutter/material.dart';

class InlineSectionTablePage extends StatefulWidget {
  const InlineSectionTablePage({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    required this.emptyPlaceholder,
    required this.loadRows,
    this.onCreate,
    this.rowActions = const [],
    this.bulkActions = const [],
    this.rowTapAction,
  });

  final String title;
  final List<InlineSectionColumn> columns;
  final List<Map<String, dynamic>> rows;
  final String emptyPlaceholder;
  final Future<List<Map<String, dynamic>>> Function() loadRows;
  final Future<void> Function()? onCreate;
  final List<TableAction> rowActions;
  final List<TableAction> bulkActions;
  final TableAction? rowTapAction;

  @override
  State<InlineSectionTablePage> createState() => _InlineSectionTablePageState();
}

class _InlineSectionTablePageState extends State<InlineSectionTablePage> {
  late List<Map<String, dynamic>> _rows = widget.rows;
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final tableColumns = widget.columns
        .map(
          (column) => TableColumnConfig(key: column.key, label: column.label),
        )
        .toList(growable: false);
    final config = TableViewConfig(
      title: widget.title,
      columns: tableColumns,
      rows: _rows,
      emptyPlaceholder: widget.emptyPlaceholder,
      onRefresh: _handleRefresh,
      primaryAction: widget.onCreate == null
          ? null
          : TableAction(
              label: 'Nuevo',
              icon: Icons.add,
              onSelected: (_) async {
                await widget.onCreate?.call();
                await _handleRefresh();
              },
            ),
      rowActions: _wrapActions(widget.rowActions),
      bulkActions: _wrapActions(widget.bulkActions),
      rowTapAction: widget.rowTapAction == null
          ? null
          : TableAction(
              label: widget.rowTapAction!.label,
              icon: widget.rowTapAction!.icon,
              onSelected: (rows) async {
                await widget.rowTapAction!.onSelected(rows);
                await _handleRefresh();
              },
            ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            TableViewTemplate(config: config),
            if (_isRefreshing)
              const Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      final refreshed = await widget.loadRows();
      setState(() {
        _rows = refreshed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  List<TableAction> _wrapActions(List<TableAction> actions) {
    if (actions.isEmpty) return const [];
    return actions
        .map(
          (action) => TableAction(
            label: action.label,
            icon: action.icon,
            onSelected: (rows) async {
              await action.onSelected(rows);
              await _handleRefresh();
            },
          ),
        )
        .toList(growable: false);
  }
}
