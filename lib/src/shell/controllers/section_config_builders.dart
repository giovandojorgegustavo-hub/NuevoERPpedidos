import 'package:erp_app/src/navegacion/detalle_builders.dart';
import 'package:erp_app/src/navegacion/registro_vistas.dart';
import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/section_action_controller.dart';
import 'package:flutter/material.dart';

typedef ColumnLabelFormatter = String Function(String key);
typedef ColumnsBuilder =
    List<TableColumnConfig> Function(List<TableRowData> rows);
typedef InlineSectionBuilder =
    List<InlineTableConfig> Function(
      String sectionId,
      Map<String, dynamic> row, {
      required bool forForm,
      SectionFormMode? formMode,
    });
typedef DetailValueFormatter = String Function(String key, dynamic value);
typedef OptionLabelFormatter = String Function(String value);
typedef FieldTypeResolver = FormFieldType Function(SectionField field);
typedef DateFormatter = String? Function(String value);
typedef ReferenceHelperResolver =
    String? Function(String sectionId, String fieldId, String? value);
typedef ReferenceAddHandler =
    Future<ReferenceOption?> Function(
      SectionField field,
      String parentSectionId,
    );
typedef ReferenceOptionsResolver =
    List<ReferenceOption> Function(String sectionId, String fieldId);
typedef FormCancelHandler = VoidCallback Function(String sectionId);
typedef FormChangedHandler =
    void Function(String sectionId, Map<String, String> values);
typedef FormSubmitHandler = Future<void> Function(Map<String, String> values);

class TableConfigBuilder {
  TableConfigBuilder({
    required SectionStateController sectionStateController,
    required String? Function() loadingSectionIdResolver,
    required Future<void> Function(String sectionId) onRefresh,
    required Future<void> Function(TableRowData row) onRowSelected,
    required Future<void> Function(String sectionId, List<TableRowData> rows)
    onBulkDelete,
    required Future<void> Function([String? sectionId]) onStartCreate,
    required SectionActionController actionController,
    required ColumnsBuilder columnsBuilder,
  }) : _sectionStateController = sectionStateController,
       _loadingSectionIdResolver = loadingSectionIdResolver,
       _onRefresh = onRefresh,
       _onRowSelected = onRowSelected,
       _onBulkDelete = onBulkDelete,
       _onStartCreate = onStartCreate,
       _actionController = actionController,
       _columnsBuilder = columnsBuilder;

  final SectionStateController _sectionStateController;
  final String? Function() _loadingSectionIdResolver;
  final Future<void> Function(String sectionId) _onRefresh;
  final Future<void> Function(TableRowData row) _onRowSelected;
  final Future<void> Function(String sectionId, List<TableRowData> rows)
  _onBulkDelete;
  final Future<void> Function([String? sectionId]) _onStartCreate;
  final SectionActionController _actionController;
  final ColumnsBuilder _columnsBuilder;

  TableViewConfig? build(ModuleSection? section) {
    if (section == null) return null;
    final overrides = kSectionOverrides[section.id];
    final rows =
        _sectionStateController.sectionRows[section.id] ??
        const <TableRowData>[];
    final columns =
        _sectionStateController.sectionColumns[section.id] ??
        _columnsBuilder(rows);
    final dataSource = _sectionStateController.sectionDataSources[section.id];
    final canCreate = dataSource != null && dataSource.formRelation.isNotEmpty;
    const deleteLabel = 'Eliminar';
    const deleteIcon = Icons.delete_outline;
    final placeholder = _loadingSectionIdResolver() == section.id
        ? 'Cargando datos...'
        : 'Sin registros.';
    final defaultRowTap = TableAction(
      label: 'Ver detalle',
      icon: Icons.visibility_outlined,
      onSelected: (selectedRows) async {
        if (selectedRows.isEmpty) return;
        await _onRowSelected(selectedRows.first);
      },
    );
    final TableAction? customRowTap = overrides?.rowTapActionBuilder?.call(
      _actionController,
    );
    final List<TableAction> rowActions =
        overrides?.rowActionsBuilder?.call(_actionController) ?? const [];
    final List<TableAction> defaultBulkActions = [];
    if (canCreate) {
      defaultBulkActions.add(
        TableAction(
          label: deleteLabel,
          icon: deleteIcon,
          onSelected: (rows) => _onBulkDelete(section.id, rows),
        ),
      );
    }
    final List<TableAction> bulkActions =
        overrides?.bulkActionsBuilder?.call(_actionController) ??
        defaultBulkActions;
    final TableAction? defaultPrimaryAction = canCreate
        ? TableAction(
            label: 'Nuevo',
            icon: Icons.add,
            onSelected: (_) => _onStartCreate(),
          )
        : null;
    final TableAction? primaryAction =
        overrides?.primaryActionBuilder?.call(_actionController) ??
        defaultPrimaryAction;
    return TableViewConfig(
      title: section.label,
      description: null,
      columns: columns,
      rows: rows,
      onRefresh: () {
        _onRefresh(section.id);
      },
      emptyPlaceholder: placeholder,
      rowTapAction: customRowTap ?? defaultRowTap,
      rowActions: rowActions,
      bulkActions: bulkActions,
      primaryAction: primaryAction,
      groupByColumn: overrides?.groupByColumn,
    );
  }
}

class DetailConfigBuilder {
  DetailConfigBuilder({
    required SectionStateController sectionStateController,
    required InlineSectionBuilder inlineSectionBuilder,
    required ColumnLabelFormatter columnLabelFormatter,
    required DetailValueFormatter detailValueFormatter,
    required VoidCallback handleDetailBack,
    required SectionActionController actionController,
  }) : _sectionStateController = sectionStateController,
       _inlineSectionBuilder = inlineSectionBuilder,
       _columnLabelFormatter = columnLabelFormatter,
       _detailValueFormatter = detailValueFormatter,
       _handleDetailBack = handleDetailBack,
       _actionController = actionController;

  final SectionStateController _sectionStateController;
  final InlineSectionBuilder _inlineSectionBuilder;
  final ColumnLabelFormatter _columnLabelFormatter;
  final DetailValueFormatter _detailValueFormatter;
  final VoidCallback _handleDetailBack;
  final SectionActionController _actionController;

  DetailViewConfig? build(ModuleSection? section) {
    if (section == null) return null;
    final row = _sectionStateController.sectionSelectedRows[section.id];
    if (row == null) return null;
    final fields = _buildFields(section.id, row);
    final subtitle = _buildSubtitle(section.id, row);
    final inlineSections = _inlineSectionBuilder(
      section.id,
      row,
      forForm: false,
    );
    DetailActionConfig? floatingAction;
    final dataSource = _sectionStateController.sectionDataSources[section.id];
    final canEdit = dataSource != null && dataSource.formRelation.isNotEmpty;
    if (canEdit) {
      floatingAction = DetailActionConfig(
        label: 'Editar',
        icon: Icons.edit_outlined,
        onPressed: () async {
          await _actionController.editRow(
            section.id,
            Map<String, dynamic>.from(row),
          );
        },
      );
    }
    final builder = kModuleDetailViewBuilders[section.id];
    if (builder != null) {
      return builder(
        row: row,
        inlineTables: inlineSections,
        onBack: _handleDetailBack,
        floatingAction: floatingAction,
      );
    }
    return DetailViewConfig(
      title: section.label,
      subtitle: subtitle,
      fields: fields,
      inlineSections: inlineSections,
      onBack: _handleDetailBack,
      floatingAction: floatingAction,
    );
  }

  List<DetailFieldConfig> buildFields(
    String sectionId,
    Map<String, dynamic> row,
  ) {
    return _buildFields(sectionId, row);
  }

  List<DetailFieldConfig> _buildFields(
    String sectionId,
    Map<String, dynamic> row,
  ) {
    final overrideFields =
        _sectionStateController.detailFieldOverrides[sectionId];
    if (overrideFields != null && overrideFields.isNotEmpty) {
      return overrideFields
          .map(
            (override) => DetailFieldConfig(
              label: override.label,
              value: _detailValueFormatter(override.key, row[override.key]),
            ),
          )
          .toList(growable: false);
    }
    return row.entries
        .map(
          (entry) => DetailFieldConfig(
            label: _columnLabelFormatter(entry.key),
            value: _detailValueFormatter(entry.key, entry.value),
          ),
        )
        .toList(growable: false);
  }

  String _buildSubtitle(String sectionId, Map<String, dynamic> row) {
    final subtitleBuilder =
        _sectionStateController.detailSubtitleBuilders[sectionId];
    return subtitleBuilder?.call(row) ??
        row['cliente_nombre']?.toString() ??
        (row.entries.isNotEmpty ? '${row.entries.first.value ?? ''}' : '');
  }
}

class FormConfigBuilder {
  FormConfigBuilder({
    required SectionStateController sectionStateController,
    required Future<void> Function(String sectionId, Map<String, dynamic> row)
    inlineLoader,
    required InlineSectionBuilder inlineSectionBuilder,
    required ReferenceOptionsResolver referenceOptionsResolver,
    required OptionLabelFormatter optionLabelFormatter,
    required FieldTypeResolver fieldTypeResolver,
    required DateFormatter dateFormatter,
    required ReferenceHelperResolver referenceHelperResolver,
    required ReferenceAddHandler referenceAddHandler,
    required ColumnsBuilder columnsBuilder,
    required ColumnLabelFormatter columnLabelFormatter,
    required FormCancelHandler cancelHandler,
    required FormChangedHandler changedHandler,
    required FormSubmitHandler submitHandler,
    required Future<void> Function(String sectionId) referenceLoader,
    required bool Function(String sectionId) isMovementSection,
    required void Function(String sectionId, Map<String, dynamic> row)
    movementContextPreparer,
    required bool Function(String sectionId, Map<String, dynamic> row)
    shouldLoadInlineSections,
    required Map<String, Map<String, String>> Function()
        formDraftValuesResolver,
  }) : _sectionStateController = sectionStateController,
       _inlineLoader = inlineLoader,
       _inlineSectionBuilder = inlineSectionBuilder,
       _referenceOptionsResolver = referenceOptionsResolver,
       _optionLabelFormatter = optionLabelFormatter,
       _fieldTypeResolver = fieldTypeResolver,
       _dateFormatter = dateFormatter,
       _referenceHelperResolver = referenceHelperResolver,
       _referenceAddHandler = referenceAddHandler,
       _columnsBuilder = columnsBuilder,
       _columnLabelFormatter = columnLabelFormatter,
       _cancelHandler = cancelHandler,
       _changedHandler = changedHandler,
       _submitHandler = submitHandler,
       _referenceLoader = referenceLoader,
       _isMovementSection = isMovementSection,
       _movementContextPreparer = movementContextPreparer,
       _shouldLoadInlineSections = shouldLoadInlineSections,
       _formDraftValuesResolver = formDraftValuesResolver;

  final SectionStateController _sectionStateController;
  final Future<void> Function(String sectionId, Map<String, dynamic> row)
  _inlineLoader;
  final InlineSectionBuilder _inlineSectionBuilder;
  final ReferenceOptionsResolver _referenceOptionsResolver;
  final OptionLabelFormatter _optionLabelFormatter;
  final FieldTypeResolver _fieldTypeResolver;
  final DateFormatter _dateFormatter;
  final ReferenceHelperResolver _referenceHelperResolver;
  final ReferenceAddHandler _referenceAddHandler;
  final ColumnsBuilder _columnsBuilder;
  final ColumnLabelFormatter _columnLabelFormatter;
  final FormCancelHandler _cancelHandler;
  final FormChangedHandler _changedHandler;
  final FormSubmitHandler _submitHandler;
  final Future<void> Function(String sectionId) _referenceLoader;
  final bool Function(String sectionId) _isMovementSection;
  final void Function(String sectionId, Map<String, dynamic> row)
  _movementContextPreparer;
  final bool Function(String sectionId, Map<String, dynamic> row)
  _shouldLoadInlineSections;
  final Map<String, Map<String, String>> Function() _formDraftValuesResolver;

  FormViewConfig? buildForSection(ModuleSection? section) {
    if (section == null) return null;
    _referenceLoader(section.id);
    final dataSource = _sectionStateController.sectionDataSources[section.id];
    if (dataSource == null || dataSource.formRelation.isEmpty) return null;
    final row = Map<String, dynamic>.from(
      _sectionStateController.sectionSelectedRows[section.id] ??
          const <String, dynamic>{},
    );
    final mode =
        _sectionStateController.sectionFormModes[section.id] ??
        SectionFormMode.edit;
    if (_isMovementSection(section.id)) {
      _movementContextPreparer(section.id, row);
    }
    if (mode == SectionFormMode.edit &&
        _shouldLoadInlineSections(section.id, row)) {
      _inlineLoader(section.id, row);
    }
    return build(section: section, row: row, mode: mode);
  }

  FormViewConfig? build({
    required ModuleSection section,
    required Map<String, dynamic> row,
    required SectionFormMode mode,
  }) {
    final fields = _buildFields(section.id, row, mode);
    if (fields == null) return null;
    final inlineTables = _inlineSectionBuilder(
      section.id,
      row,
      forForm: true,
      formMode: mode,
    );
    final cancel = _cancelHandler(section.id);
    final overrideValues = _formDraftValuesResolver()[section.id];
    if (section.id == 'movimientos' || section.id == 'pedidos_movimientos') {
      debugPrint(
        '[form-config] section=${section.id} mode=$mode overrideValues=$overrideValues',
      );
    }
    return FormViewConfig(
      title: mode == SectionFormMode.create
          ? 'Nuevo ${section.label}'
          : 'Editar ${section.label}',
      fields: fields,
      inlineTables: inlineTables,
      onSubmit: (values) => _submitHandler(values),
      onCancel: cancel,
      saveLabel: 'Guardar',
      cancelLabel: 'Cancelar',
      onChanged: (values) => _changedHandler(section.id, values),
      overrideValues: overrideValues,
    );
  }

  List<FormFieldConfig>? buildFields(
    String sectionId,
    Map<String, dynamic> row,
    SectionFormMode mode,
  ) {
    return _buildFields(sectionId, row, mode);
  }

  List<FormFieldConfig>? _buildFields(
    String sectionId,
    Map<String, dynamic> row,
    SectionFormMode mode,
  ) {
    final metadataFields = _sectionStateController.sectionFields[sectionId];
    if (metadataFields != null && metadataFields.isNotEmpty) {
      final visibleFields = metadataFields
          .where((field) => field.visible)
          .toList();
      if (visibleFields.isEmpty) return null;
      return visibleFields
          .map((field) => _buildFieldConfig(sectionId, row, mode, field))
          .toList(growable: false);
    }
    final columns =
        _sectionStateController.sectionColumns[sectionId] ??
        _columnsBuilder(
          _sectionStateController.sectionRows[sectionId] ??
              const <TableRowData>[],
        );
    if (columns.isEmpty) return null;
    return columns
        .map(
          (column) => FormFieldConfig(
            id: column.key,
            label: _columnLabelFormatter(column.key),
            initialValue: row[column.key]?.toString(),
            readOnly: column.key == 'id',
            helperText: column.key == 'id' ? 'Se genera automáticamente' : null,
          ),
        )
        .toList(growable: false);
  }

  FormFieldConfig _buildFieldConfig(
    String sectionId,
    Map<String, dynamic> row,
    SectionFormMode mode,
    SectionField field,
  ) {
    List<FormFieldOption>? options;
    if (field.widgetType == 'reference') {
      final entries = _referenceOptionsResolver(sectionId, field.id);
      if (entries.isNotEmpty) {
        options = entries
            .map((opt) => FormFieldOption(value: opt.value, label: opt.label))
            .toList();
      }
    } else if (field.staticOptions.isNotEmpty) {
      options = field.staticOptions
          .map(
            (value) => FormFieldOption(
              value: value,
              label: _optionLabelFormatter(value),
            ),
          )
          .toList();
    }
    var initialValue = row[field.id]?.toString();
    if ((initialValue == null || initialValue.isEmpty) &&
        mode == SectionFormMode.create) {
      initialValue = field.defaultValue == null
          ? null
          : field.defaultValue!.toLowerCase() == 'now'
          ? DateTime.now().toIso8601String()
          : field.defaultValue;
      if (initialValue != null) {
        row[field.id] = initialValue;
      }
    }
    final fieldType = _fieldTypeResolver(field);
    if (fieldType == FormFieldType.dateTime &&
        initialValue != null &&
        initialValue.isNotEmpty) {
      final formatted = _dateFormatter(initialValue);
      if (formatted != null) {
        initialValue = formatted;
      }
    }
    final helperBuilder = field.widgetType == 'reference'
        ? (String? currentValue) =>
              _referenceHelperResolver(sectionId, field.id, currentValue)
        : null;
    return FormFieldConfig(
      id: field.id,
      label: field.label,
      initialValue: initialValue,
      readOnly: field.readOnly,
      required: field.required,
      fieldType: fieldType,
      options: options,
      helperBuilder: helperBuilder,
      sectionId: sectionId,
      onAddReference: field.widgetType == 'reference'
          ? () async {
              final reference = await _referenceAddHandler(field, sectionId);
              if (reference == null) return null;
              return FormFieldOption(
                value: reference.value,
                label: reference.label,
              );
            }
          : null,
      visibleWhen: _buildVisibilityPredicate(field),
    );
  }

  bool Function(Map<String, String>)? _buildVisibilityPredicate(
    SectionField field,
  ) {
    final controllingField = field.visibleWhenField;
    if (controllingField == null) return null;
    return (values) => _matchesVisibilityValue(
          values[controllingField] ?? '',
          field.visibleWhenEquals,
        );
  }

  bool _matchesVisibilityValue(String comparedRaw, String? expectedRaw) {
    final normalizedCompared = comparedRaw.trim().toLowerCase();
    final targets = _normalizeVisibilityTargets(expectedRaw);
    if (targets.isEmpty) {
      return normalizedCompared ==
          (expectedRaw ?? '').trim().toLowerCase();
    }
    return targets.contains(normalizedCompared);
  }

  List<String> _normalizeVisibilityTargets(String? raw) {
    if (raw == null) return const [];
    return raw
        .split(RegExp(r'[|,]'))
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }
}
