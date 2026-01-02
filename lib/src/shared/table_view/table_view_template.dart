import 'dart:async';

import 'package:flutter/material.dart';

/// `TableViewTemplate` emulates la vista tipo tabla de AppSheet permitiendo
/// reutilizar un layout con búsquedas, filtros, agrupaciones y acciones.
///
/// El widget se alimenta de un [TableViewConfig] que describe columnas,
/// filas y acciones disponibles, por lo que se puede reutilizar en cualquier
/// módulo solo cambiando los datos de origen.
typedef TableRowData = Map<String, dynamic>;

class TableColumnConfig {
  const TableColumnConfig({
    required this.key,
    required this.label,
    this.width,
    this.isSortable = true,
    this.isFilterable = true,
    this.textAlign = TextAlign.left,
  });

  final String key;
  final String label;
  final double? width;
  final bool isSortable;
  final bool isFilterable;
  final TextAlign textAlign;
}

class TableAction {
  const TableAction({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.isVisible,
  });

  final String label;
  final IconData icon;
  final Future<void> Function(List<TableRowData> rows) onSelected;
  final bool Function(List<TableRowData> rows)? isVisible;

  bool isVisibleFor(List<TableRowData> rows) {
    return isVisible?.call(rows) ?? true;
  }
}

enum TableQuickFilterBehavior { include, exclude }

class TableQuickFilter {
  const TableQuickFilter({
    required this.label,
    required this.predicate,
    this.behavior = TableQuickFilterBehavior.include,
  });

  final String label;
  final bool Function(TableRowData row) predicate;
  final TableQuickFilterBehavior behavior;
}

class TableSortOption {
  const TableSortOption(this.columnKey, {this.desc = true});

  final String columnKey;
  final bool desc;
}

class TableViewConfig {
  const TableViewConfig({
    required this.title,
    required this.columns,
    required this.rows,
    this.description,
    this.initialSort,
    this.groupByColumn,
    this.rowActions = const [],
    this.bulkActions = const [],
    this.primaryAction,
    this.rowTapAction,
    this.onRefresh,
    this.quickFilters = const [],
    this.emptyPlaceholder =
        'Configura la conexión a datos para comenzar a trabajar.',
  });

  final String title;
  final String? description;
  final List<TableColumnConfig> columns;
  final List<TableRowData> rows;
  final TableSortOption? initialSort;
  final String? groupByColumn;
  final List<TableAction> rowActions;
  final List<TableAction> bulkActions;
  final TableAction? primaryAction;
  final TableAction? rowTapAction;
  final VoidCallback? onRefresh;
  final List<TableQuickFilter> quickFilters;
  final String emptyPlaceholder;

  TableViewConfig copyWith({
    String? title,
    String? description,
    List<TableColumnConfig>? columns,
    List<TableRowData>? rows,
    TableSortOption? initialSort,
    String? groupByColumn,
    List<TableAction>? rowActions,
    List<TableAction>? bulkActions,
    TableAction? primaryAction,
    TableAction? rowTapAction,
    VoidCallback? onRefresh,
    List<TableQuickFilter>? quickFilters,
    String? emptyPlaceholder,
  }) {
    return TableViewConfig(
      title: title ?? this.title,
      description: description ?? this.description,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      initialSort: initialSort ?? this.initialSort,
      groupByColumn: groupByColumn ?? this.groupByColumn,
      rowActions: rowActions ?? this.rowActions,
      bulkActions: bulkActions ?? this.bulkActions,
      primaryAction: primaryAction ?? this.primaryAction,
      rowTapAction: rowTapAction ?? this.rowTapAction,
      onRefresh: onRefresh ?? this.onRefresh,
      quickFilters: quickFilters ?? this.quickFilters,
      emptyPlaceholder: emptyPlaceholder ?? this.emptyPlaceholder,
    );
  }
}

class TableViewTemplate extends StatefulWidget {
  const TableViewTemplate({
    super.key,
    required this.config,
    this.onRowTap,
    this.onPrimaryAction,
  });

  final TableViewConfig config;
  final ValueChanged<TableRowData>? onRowTap;
  final VoidCallback? onPrimaryAction;

  @override
  State<TableViewTemplate> createState() => _TableViewTemplateState();
}

class _TableViewTemplateState extends State<TableViewTemplate> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  TableSortOption? _sortOption;
  final Map<String, String> _columnFilters = {};
  final Set<int> _selectedOriginalIndexes = {};
  final Set<String> _activeQuickFilters = {};
  List<_TableRowEntry> _visibleRows = <_TableRowEntry>[];

  @override
  void initState() {
    super.initState();
    _sortOption = widget.config.initialSort;
    _applyFilters();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
        _applyFilters();
      });
    });
  }

  @override
  void didUpdateWidget(covariant TableViewTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    final rowsOrColumnsChanged =
        oldWidget.config.rows != widget.config.rows ||
        oldWidget.config.columns != widget.config.columns;
    final quickFiltersChanged =
        oldWidget.config.quickFilters.length !=
        widget.config.quickFilters.length;
    if (rowsOrColumnsChanged || quickFiltersChanged) {
      setState(() {
        if (quickFiltersChanged) {
          _activeQuickFilters.clear();
        }
        _applyFilters();
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final List<_TableRowEntry> entries = [];
    final lowerQuery = _searchQuery;
    for (var i = 0; i < widget.config.rows.length; i++) {
      final row = widget.config.rows[i];
      bool matchesSearch = true;
      if (lowerQuery.isNotEmpty) {
        matchesSearch = row.values.any(
          (value) =>
              value.toString().toLowerCase().contains(lowerQuery.toLowerCase()),
        );
      }

      if (!matchesSearch) continue;

      bool matchesFilters = true;
      for (final entry in _columnFilters.entries) {
        final value = row[entry.key];
        final filterValue = entry.value.toLowerCase();
        if (filterValue.isEmpty) continue;
        if (value == null ||
            !value.toString().toLowerCase().contains(filterValue)) {
          matchesFilters = false;
          break;
        }
      }

      if (!matchesFilters) continue;
      final quickFilters = widget.config.quickFilters;
      if (quickFilters.isNotEmpty && _activeQuickFilters.isNotEmpty) {
        final activeFilters = quickFilters
            .where((filter) => _activeQuickFilters.contains(filter.label))
            .toList(growable: false);
        if (activeFilters.isNotEmpty) {
          final includeFilters = activeFilters
              .where(
                (filter) => filter.behavior == TableQuickFilterBehavior.include,
              )
              .toList(growable: false);
          final excludeFilters = activeFilters
              .where(
                (filter) => filter.behavior == TableQuickFilterBehavior.exclude,
              )
              .toList(growable: false);
          final hasInclude = includeFilters.isNotEmpty;
          if (hasInclude &&
              !includeFilters.any((filter) => filter.predicate(row))) {
            continue;
          }
          if (!hasInclude) {
            var excluded = false;
            for (final filter in excludeFilters) {
              if (filter.predicate(row)) {
                excluded = true;
                break;
              }
            }
            if (excluded) continue;
          }
        }
      }
      entries.add(_TableRowEntry(index: i, data: row));
    }

    if (_sortOption != null) {
      entries.sort((a, b) {
        final key = _sortOption!.columnKey;
        final aValue = a.data[key];
        final bValue = b.data[key];
        if (aValue == null && bValue == null) return 0;
        if (aValue == null) return _sortOption!.desc ? 1 : -1;
        if (bValue == null) return _sortOption!.desc ? -1 : 1;

        final result = '$aValue'.compareTo('$bValue');
        return _sortOption!.desc ? -result : result;
      });
    }

    _visibleRows = entries;
  }

  void _openFilterDialog() async {
    final availableColumns = widget.config.columns
        .where((column) => column.isFilterable)
        .toList(growable: false);

    if (availableColumns.isEmpty) return;

    String selectedKey = availableColumns.first.key;
    final currentValue = _columnFilters[selectedKey] ?? '';
    final controller = TextEditingController(text: currentValue);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar por columna'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedKey,
                items: [
                  for (final column in availableColumns)
                    DropdownMenuItem(
                      value: column.key,
                      child: Text(column.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedKey = value;
                      controller.text = _columnFilters[selectedKey] ?? '';
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Columna',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Valor a buscar',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _columnFilters[selectedKey] = controller.text;
                  _applyFilters();
                });
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  void _openSortDialog() async {
    final sortableColumns = widget.config.columns
        .where((column) => column.isSortable)
        .toList(growable: false);
    if (sortableColumns.isEmpty) return;

    String selectedKey = _sortOption?.columnKey ?? sortableColumns.first.key;
    bool desc = _sortOption?.desc ?? true;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ordenar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedKey,
                items: [
                  for (final column in sortableColumns)
                    DropdownMenuItem(
                      value: column.key,
                      child: Text(column.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedKey = value);
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Columna',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: desc,
                onChanged: (value) {
                  setState(() => desc = value);
                },
                title: const Text('Descendente'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _sortOption = TableSortOption(selectedKey, desc: desc);
                  _applyFilters();
                });
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  bool get _hasSelection => _selectedOriginalIndexes.isNotEmpty;

  void _handleRowTap(_TableRowEntry entry) {
    if (_hasSelection) {
      _toggleSelection(entry);
      return;
    }
    final rowTapAction = widget.config.rowTapAction;
    if (rowTapAction != null) {
      unawaited(rowTapAction.onSelected([entry.data]));
    } else {
      _toggleSelection(entry);
    }
    widget.onRowTap?.call(entry.data);
  }

  void _handleRowLongPress(_TableRowEntry entry) {
    _toggleSelection(entry);
  }

  void _toggleSelection(_TableRowEntry entry) {
    setState(() {
      if (_selectedOriginalIndexes.contains(entry.index)) {
        _selectedOriginalIndexes.remove(entry.index);
      } else {
        _selectedOriginalIndexes.add(entry.index);
      }
    });
  }

  void _clearSelection() {
    if (!mounted) return;
    setState(() => _selectedOriginalIndexes.clear());
  }

  void _toggleQuickFilter(String label, bool selected) {
    setState(() {
      if (selected) {
        _activeQuickFilters.add(label);
      } else {
        _activeQuickFilters.remove(label);
      }
      _applyFilters();
    });
  }

  List<TableRowData> get _selectedRows =>
      _selectedOriginalIndexes.map((i) => widget.config.rows[i]).toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final groupBy = widget.config.groupByColumn;
    final groupedRows = <String, List<_TableRowEntry>>{};

    if (groupBy != null) {
      for (final entry in _visibleRows) {
        final groupKey = entry.data[groupBy]?.toString() ?? 'Sin grupo';
        groupedRows.putIfAbsent(groupKey, () => []).add(entry);
      }
    }

    final selectedRows = _selectedRows;
    final visibleBulkActions = widget.config.bulkActions
        .where((action) => action.isVisibleFor(selectedRows))
        .toList();
    final bool bulkVisible =
        visibleBulkActions.isNotEmpty && selectedRows.isNotEmpty;
    final bool hasFloatingPrimary = widget.config.primaryAction != null;
    final double bottomPadding =
        (bulkVisible ? 80 : 0) + (hasFloatingPrimary ? 80 : 0);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.config.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (widget.config.description != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.config.description!,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
            const SizedBox(height: 16),
            _buildToolbar(colorScheme),
            if (widget.config.quickFilters.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.config.quickFilters
                    .map(
                      (filter) => FilterChip(
                        label: Text(filter.label),
                        selected: _activeQuickFilters.contains(filter.label),
                        onSelected: (selected) =>
                            _toggleQuickFilter(filter.label, selected),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ] else
              const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: _visibleRows.isEmpty
                          ? Center(
                              child: Text(
                                widget.config.emptyPlaceholder,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            )
                          : groupBy != null
                          ? _GroupedTableView(
                              columns: widget.config.columns,
                              groups: groupedRows,
                              onRowTap: _handleRowTap,
                              onRowLongPress: _handleRowLongPress,
                              selectedIndexes: _selectedOriginalIndexes,
                              rowActions: widget.config.rowActions,
                            )
                          : _DataTableView(
                              columns: widget.config.columns,
                              rows: _visibleRows,
                              sortOption: _sortOption,
                              rowActions: widget.config.rowActions,
                              onSortSelected: (columnKey, ascending) {
                                setState(() {
                                  _sortOption = TableSortOption(
                                    columnKey,
                                    desc: !ascending,
                                  );
                                  _applyFilters();
                                });
                              },
                              onRowTap: _handleRowTap,
                              onRowLongPress: _handleRowLongPress,
                              selectedIndexes: _selectedOriginalIndexes,
                            ),
                    ),
                  ),
                  if (bulkVisible)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _BulkActionBar(
                        selectedCount: _selectedOriginalIndexes.length,
                        actions: visibleBulkActions,
                        onClear: _clearSelection,
                        selectedRows: selectedRows,
                      ),
                    ),
                  if (hasFloatingPrimary)
                    Positioned(
                      right: 16,
                      bottom: bulkVisible ? 96 : 24,
                      child: FloatingActionButton.extended(
                        onPressed: () async {
                          await widget.config.primaryAction!.onSelected(
                            const [],
                          );
                          widget.onPrimaryAction?.call();
                        },
                        icon: Icon(widget.config.primaryAction!.icon),
                        label: Text(widget.config.primaryAction!.label),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        FocusScope.of(context).unfocus();
                      },
                    ),
              hintText: 'Buscar en la tabla',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: _openFilterDialog,
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filtrar por columna',
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: _openSortDialog,
          icon: const Icon(Icons.swap_vert),
          tooltip: 'Ordenar',
        ),
        if (widget.config.onRefresh != null) ...[
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: widget.config.onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar datos',
          ),
        ],
      ],
    );
  }
}

class _DataTableView extends StatefulWidget {
  const _DataTableView({
    required this.columns,
    required this.rows,
    required this.sortOption,
    required this.onSortSelected,
    required this.onRowTap,
    required this.onRowLongPress,
    required this.selectedIndexes,
    required this.rowActions,
  });

  final List<TableColumnConfig> columns;
  final List<_TableRowEntry> rows;
  final TableSortOption? sortOption;
  final void Function(String columnKey, bool ascending) onSortSelected;
  final void Function(_TableRowEntry row) onRowTap;
  final void Function(_TableRowEntry row) onRowLongPress;
  final Set<int> selectedIndexes;
  final List<TableAction> rowActions;

  @override
  State<_DataTableView> createState() => _DataTableViewState();
}

class _DataTableViewState extends State<_DataTableView> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSortKey = widget.sortOption?.columnKey;
    final sortColumnIndex = currentSortKey == null
        ? null
        : widget.columns.indexWhere((column) => column.key == currentSortKey);
    final sortAscending = widget.sortOption == null
        ? true
        : !widget.sortOption!.desc;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.horizontal,
            child: Scrollbar(
              controller: _verticalController,
              thumbVisibility: true,
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.vertical,
              child: SingleChildScrollView(
                controller: _verticalController,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      showCheckboxColumn: false,
                      sortColumnIndex: sortColumnIndex,
                      sortAscending: sortAscending,
                      columns: [
                        for (final column in widget.columns)
                          DataColumn(
                            label: Text(column.label),
                            onSort: column.isSortable
                                ? (columnIndex, ascending) =>
                                    widget.onSortSelected(column.key, ascending)
                                : null,
                          ),
                        if (widget.rowActions.isNotEmpty)
                          const DataColumn(label: Icon(Icons.more_horiz)),
                      ],
                      rows: [
                        for (final row in widget.rows)
                          DataRow.byIndex(
                            index: row.index,
                            selected: widget.selectedIndexes.contains(row.index),
                            onLongPress: () => widget.onRowLongPress(row),
                            onSelectChanged: (_) => widget.onRowTap(row),
                            cells: [
                              for (final column in widget.columns)
                                DataCell(
                                  Align(
                                    alignment: _textAlignToAlignment(
                                      column.textAlign,
                                    ),
                                    child: Text(
                                      row.data[column.key]?.toString() ?? '-',
                                    ),
                                  ),
                                ),
                              if (widget.rowActions.isNotEmpty)
                                DataCell(
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: PopupMenuButton<TableAction>(
                                      icon: const Icon(Icons.more_vert),
                                      tooltip: 'Acciones',
                                      onSelected: (action) =>
                                          unawaited(action.onSelected([row.data])),
                                      itemBuilder: (context) {
                                        return [
                                          for (final action in widget.rowActions)
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
                                        ];
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Alignment _textAlignToAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }
}

class _BulkActionBar extends StatelessWidget {
  const _BulkActionBar({
    required this.selectedCount,
    required this.actions,
    required this.onClear,
    required this.selectedRows,
  });

  final int selectedCount;
  final List<TableAction> actions;
  final VoidCallback onClear;
  final List<TableRowData> selectedRows;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.primary.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          Text(
            '$selectedCount seleccionados',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          ...actions.map(
            (action) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilledButton.icon(
                onPressed: () async {
                  await action.onSelected(selectedRows);
                  onClear();
                },
                icon: Icon(action.icon),
                label: Text(action.label),
              ),
            ),
          ),
          IconButton(
            onPressed: onClear,
            tooltip: 'Limpiar selección',
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _GroupedTableView extends StatelessWidget {
  const _GroupedTableView({
    required this.columns,
    required this.groups,
    required this.onRowTap,
    required this.onRowLongPress,
    required this.selectedIndexes,
    required this.rowActions,
  });

  final List<TableColumnConfig> columns;
  final Map<String, List<_TableRowEntry>> groups;
  final void Function(_TableRowEntry row) onRowTap;
  final void Function(_TableRowEntry row) onRowLongPress;
  final Set<int> selectedIndexes;
  final List<TableAction> rowActions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final entry in groups.entries)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _DataTableView(
                columns: columns,
                rows: entry.value,
                sortOption: null,
                onSortSelected: (_, __) {},
                onRowTap: onRowTap,
                onRowLongPress: onRowLongPress,
                selectedIndexes: selectedIndexes,
                rowActions: rowActions,
              ),
              const Divider(),
            ],
          ),
      ],
    );
  }
}

class _TableRowEntry {
  const _TableRowEntry({required this.index, required this.data});

  final int index;
  final TableRowData data;
}
