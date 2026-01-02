import 'dart:async';

import 'package:flutter/material.dart';

class InlineTableAction {
  const InlineTableAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}

class InlineSelectionAction {
  const InlineSelectionAction({
    required this.label,
    required this.onSelected,
  });

  final String label;
  final Future<void> Function(List<InlineTableRow> rows) onSelected;
}

enum InlineTableFilterBehavior { include, exclude }

class InlineTableFilter {
  const InlineTableFilter({
    required this.label,
    required this.predicate,
    this.behavior = InlineTableFilterBehavior.exclude,
  });

  final String label;
  final bool Function(InlineTableRow row) predicate;
  final InlineTableFilterBehavior behavior;
}

class InlineTableRow {
  const InlineTableRow({
    required this.displayValues,
    this.rawRow,
    this.isPending = false,
    this.pendingId,
  });

  final Map<String, String> displayValues;
  final Map<String, dynamic>? rawRow;
  final bool isPending;
  final String? pendingId;
}

class InlineTableConfig {
  const InlineTableConfig({
    required this.title,
    required this.columns,
    required this.rows,
    this.collapsedByDefault = false,
    this.primaryAction,
    this.secondaryAction,
    this.emptyPlaceholder = 'Sin registros disponibles.',
    this.isLoading = false,
    this.enableSelection = false,
    this.selectionActions = const [],
    this.onRowTap,
    this.filters = const [],
  });

  final String title;
  final List<String> columns;
  final List<InlineTableRow> rows;
  final bool collapsedByDefault;
  final InlineTableAction? primaryAction;
  final InlineTableAction? secondaryAction;
  final String emptyPlaceholder;
  final bool isLoading;
  final bool enableSelection;
  final List<InlineSelectionAction> selectionActions;
  final Future<void> Function(InlineTableRow row)? onRowTap;
  final List<InlineTableFilter> filters;

  InlineTableConfig copyWith({
    String? title,
    List<String>? columns,
    List<InlineTableRow>? rows,
    bool? collapsedByDefault,
    InlineTableAction? primaryAction,
    InlineTableAction? secondaryAction,
    String? emptyPlaceholder,
    bool? isLoading,
    bool? enableSelection,
    List<InlineSelectionAction>? selectionActions,
    Future<void> Function(InlineTableRow row)? onRowTap,
    List<InlineTableFilter>? filters,
  }) {
    return InlineTableConfig(
      title: title ?? this.title,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      collapsedByDefault: collapsedByDefault ?? this.collapsedByDefault,
      primaryAction: primaryAction ?? this.primaryAction,
      secondaryAction: secondaryAction ?? this.secondaryAction,
      emptyPlaceholder: emptyPlaceholder ?? this.emptyPlaceholder,
      isLoading: isLoading ?? this.isLoading,
      enableSelection: enableSelection ?? this.enableSelection,
      selectionActions: selectionActions ?? this.selectionActions,
      onRowTap: onRowTap ?? this.onRowTap,
      filters: filters ?? this.filters,
    );
  }
}

class InlineTableTemplate extends StatefulWidget {
  const InlineTableTemplate({super.key, required this.config});

  final InlineTableConfig config;

  @override
  State<InlineTableTemplate> createState() => _InlineTableTemplateState();
}

class _InlineTableTemplateState extends State<InlineTableTemplate> {
  late bool _collapsed = widget.config.collapsedByDefault;
  final Set<int> _selectedIndexes = <int>{};
  final Set<String> _activeFilters = <String>{};
  bool _isPerformingSelectionAction = false;
  final ScrollController _horizontalController = ScrollController();
  String? _sortColumnLabel;
  bool _sortAscending = true;

  bool get _selectionEnabled =>
      widget.config.selectionActions.isNotEmpty;

  bool get _isSelectionMode =>
      _selectionEnabled && _selectedIndexes.isNotEmpty;

  @override
  void didUpdateWidget(covariant InlineTableTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndexes.isNotEmpty &&
        oldWidget.config.rows.length != widget.config.rows.length) {
      _selectedIndexes.clear();
    }
    if (oldWidget.config.filters.length != widget.config.filters.length) {
      _selectedIndexes.clear();
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.config.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: Icon(_collapsed ? Icons.expand_more : Icons.expand_less),
                  onPressed: () =>
                      setState(() => _collapsed = !_collapsed),
                ),
              ],
            ),
            if (!_collapsed) ...[
              const SizedBox(height: 8),
              _buildContent(context),
              const SizedBox(height: 8),
              if (_isSelectionMode &&
                  widget.config.selectionActions.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    children: widget.config.selectionActions
                        .map(
                          (action) => FilledButton.tonal(
                            onPressed: _isPerformingSelectionAction
                                ? null
                                : () => _handleSelectionAction(
                                      action,
                                      _filteredRows(),
                                    ),
                            child: Text(action.label),
                          ),
                        )
                        .toList(),
                  ),
                )
              else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.config.secondaryAction != null) ...[
                    TextButton(
                      onPressed: widget.config.secondaryAction!.onPressed,
                      child: Text(widget.config.secondaryAction!.label),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (widget.config.primaryAction != null)
                    TextButton(
                      onPressed: widget.config.primaryAction!.onPressed,
                      child: Text(widget.config.primaryAction!.label),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.config.isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final filteredRows = _filteredRows();
    final Widget content = filteredRows.isEmpty
        ? _buildEmptyState()
        : _buildTable(context, filteredRows);
    if (widget.config.filters.isEmpty) {
      return content;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilters(context),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF7F8FC),
      ),
      child: Text(
        widget.config.emptyPlaceholder,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.config.filters
          .map(
            (filter) => FilterChip(
              label: Text(filter.label),
              selected: _activeFilters.contains(filter.label),
              onSelected: (selected) =>
                  _toggleFilter(filter.label, selected),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTable(BuildContext context, List<InlineTableRow> rows) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sortedIndexes = _sortedRowIndexes(rows);
        final sortColumnIndex = _sortColumnLabel == null
            ? null
            : widget.config.columns.indexOf(_sortColumnLabel!);
        return Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: DataTable(
                  showCheckboxColumn: false,
                  sortColumnIndex: sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: [
                    for (var columnIndex = 0;
                        columnIndex < widget.config.columns.length;
                        columnIndex++)
                      DataColumn(
                        label: Text(widget.config.columns[columnIndex]),
                        onSort: (index, _) =>
                            _handleSort(widget.config.columns[columnIndex]),
                      ),
                  ],
                  rows: [
                    for (final rowIndex in sortedIndexes)
                      _buildDataRow(rowIndex, rows[rowIndex]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<int> _sortedRowIndexes(List<InlineTableRow> rows) {
    final indexes = List<int>.generate(rows.length, (index) => index);
    final sortLabel = _sortColumnLabel;
    if (sortLabel == null) return indexes;
    indexes.sort((a, b) {
      final aValue = rows[a].displayValues[sortLabel] ?? '';
      final bValue = rows[b].displayValues[sortLabel] ?? '';
      final comparison = aValue.compareTo(bValue);
      return _sortAscending ? comparison : -comparison;
    });
    return indexes;
  }

  List<InlineTableRow> _filteredRows() {
    final filters = widget.config.filters;
    if (filters.isEmpty) return widget.config.rows;
    final activeFilters = filters
        .where((filter) => _activeFilters.contains(filter.label))
        .toList(growable: false);
    if (activeFilters.isEmpty) return widget.config.rows;
    final includeFilters = activeFilters
        .where((filter) => filter.behavior == InlineTableFilterBehavior.include)
        .toList(growable: false);
    final excludeFilters = activeFilters
        .where((filter) => filter.behavior == InlineTableFilterBehavior.exclude)
        .toList(growable: false);
    final hasInclude = includeFilters.isNotEmpty;
    return widget.config.rows.where((row) {
      if (hasInclude &&
          !includeFilters.any((filter) => filter.predicate(row))) {
        return false;
      }
      if (!hasInclude) {
        for (final filter in excludeFilters) {
          if (filter.predicate(row)) return false;
        }
      }
      return true;
    }).toList(growable: false);
  }

  void _handleSort(String columnLabel) {
    setState(() {
      if (_sortColumnLabel == columnLabel) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnLabel = columnLabel;
        _sortAscending = true;
      }
    });
  }

  void _toggleFilter(String label, bool selected) {
    setState(() {
      if (selected) {
        _activeFilters.add(label);
      } else {
        _activeFilters.remove(label);
      }
      _selectedIndexes.clear();
    });
  }

  DataRow _buildDataRow(int rowIndex, InlineTableRow row) {
    final isSelected = _selectedIndexes.contains(rowIndex);
    return DataRow.byIndex(
      index: rowIndex,
      selected: isSelected,
      onLongPress: _selectionEnabled
          ? () => _toggleSelection(rowIndex, !isSelected)
          : null,
      onSelectChanged: (_) {
        if (_isSelectionMode) {
          _toggleSelection(rowIndex, !isSelected);
        } else {
          _handleCellTap(rowIndex, row);
        }
      },
      cells: widget.config.columns
          .map(
            (column) => DataCell(
              Align(
                alignment: Alignment.centerLeft,
                child: Text(row.displayValues[column] ?? '-'),
              ),
            ),
          )
          .toList(),
    );
  }

  void _toggleSelection(int index, bool selected) {
    if (!_selectionEnabled) return;
    setState(() {
      if (selected) {
        _selectedIndexes.add(index);
      } else {
        _selectedIndexes.remove(index);
      }
    });
  }

  void _handleCellTap(int index, InlineTableRow row) {
    if (_selectionEnabled && _selectedIndexes.isNotEmpty) {
      final isSelected = _selectedIndexes.contains(index);
      _toggleSelection(index, !isSelected);
      return;
    }
    final callback = widget.config.onRowTap;
    if (callback == null) return;
    unawaited(callback(row));
  }

  Future<void> _handleSelectionAction(
    InlineSelectionAction action,
    List<InlineTableRow> rows,
  ) async {
    if (_selectedIndexes.isEmpty) return;
    setState(() => _isPerformingSelectionAction = true);
    try {
      final selectedRows = _selectedIndexes
          .map((index) => rows[index])
          .toList(growable: false);
      await action.onSelected(selectedRows);
    } finally {
      if (mounted) {
        setState(() {
          _isPerformingSelectionAction = false;
          _selectedIndexes.clear();
        });
      }
    }
  }
}
