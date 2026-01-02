import 'package:flutter/foundation.dart';

import 'package:erp_app/src/navegacion/inline_builders.dart';
import 'package:erp_app/src/shared/inline_table/inline_pending_row.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';

/// Servicio que coordina todo lo relacionado con secciones inline y borradores.
///
/// Centraliza el estado (rows pendientes, cachés de datos, banderas de carga,
/// jerarquías anidadas, etc.) y expone operaciones de alto nivel para los
/// controladores del shell.
class InlineDraftService {
  InlineDraftService({
    required ModuleRepository moduleRepository,
    required InlineShellSetState setState,
    required SectionContextResolver sectionContextResolver,
    required SectionOverridesResolver inlineOverridesResolver,
    required SectionFieldsResolver sectionFieldsResolver,
    required SectionDataSourceResolver sectionDataSourceResolver,
    required ReferenceLabelResolver referenceLabelResolver,
    required ReferenceMetadataResolver referenceMetadataResolver,
  })  : _moduleRepository = moduleRepository,
        _setState = setState,
        _sectionContextResolver = sectionContextResolver,
        _inlineOverridesResolver = inlineOverridesResolver,
        _sectionFieldsResolver = sectionFieldsResolver,
        _sectionDataSourceResolver = sectionDataSourceResolver,
        _referenceLabelResolver = referenceLabelResolver,
        _referenceMetadataResolver = referenceMetadataResolver,
        _inlineRefreshNotifier = ValueNotifier<int>(0);

  final ModuleRepository _moduleRepository;
  final InlineShellSetState _setState;
  final SectionContextResolver _sectionContextResolver;
  final SectionOverridesResolver _inlineOverridesResolver;
  final SectionFieldsResolver _sectionFieldsResolver;
  final SectionDataSourceResolver _sectionDataSourceResolver;
  final ReferenceLabelResolver _referenceLabelResolver;
  final ReferenceMetadataResolver _referenceMetadataResolver;

  final Map<String, List<Map<String, dynamic>>> _inlineSectionData = {};
  final Set<String> _inlineLoadingKeys = <String>{};
  final Map<String, List<InlinePendingRow>> _pendingInlineRows = {};
  int _pendingRowSequence = 0;

  final ValueNotifier<int> _inlineRefreshNotifier;

  ValueNotifier<int> get refreshNotifier => _inlineRefreshNotifier;

  Map<String, List<Map<String, dynamic>>> get inlineSectionData =>
      _inlineSectionData;
  Set<String> get inlineLoadingKeys => _inlineLoadingKeys;

  void dispose() {
    _inlineRefreshNotifier.dispose();
  }

  String inlineKey(String sectionId, dynamic rowId, String inlineId) =>
      '$sectionId::$rowId::$inlineId';

  String inlinePendingKey(String sectionId, String inlineId) =>
      '$sectionId::$inlineId';

  /// Notifica a listeners (ReferenceFormPage, Inline tables) que cambió el
  /// estado de inline drafts.
  void notifyInlineDataChanged() {
    _inlineRefreshNotifier.value++;
  }

  List<InlinePendingRow> findPendingRows(
    String sectionId,
    String inlineId,
  ) {
    final key = inlinePendingKey(sectionId, inlineId);
    final entries = _pendingInlineRows[key];
    if (entries == null) return const [];
    return entries;
  }

  InlinePendingRow? findPendingInlineRow(
    String sectionId,
    String inlineId,
    String pendingId,
  ) {
    final key = inlinePendingKey(sectionId, inlineId);
    final entries = _pendingInlineRows[key];
    if (entries == null || entries.isEmpty) return null;
    for (final entry in entries) {
      if (entry.pendingId == pendingId) {
        return entry;
      }
    }
    return null;
  }

  bool clearPendingRows(String sectionId) {
    final keys = _pendingInlineRows.keys
        .where((key) => key.startsWith('$sectionId::'))
        .toList(growable: false);
    if (keys.isEmpty) return false;
    for (final key in keys) {
      _pendingInlineRows.remove(key);
    }
    _setState(() {});
    notifyInlineDataChanged();
    return true;
  }

  Map<String, List<InlinePendingRow>> takePendingInlineRowsForSection(
    String sectionId,
  ) {
    final keys = _pendingInlineRows.keys
        .where((key) => key.startsWith('$sectionId::'))
        .toList(growable: false);
    final result = <String, List<InlinePendingRow>>{};
    if (keys.isEmpty) return result;
    for (final key in keys) {
      final inlineId = key.substring(sectionId.length + 2);
      final entries = _pendingInlineRows.remove(key);
      if (entries != null && entries.isNotEmpty) {
        result[inlineId] = entries;
      }
    }
    if (result.isNotEmpty) {
      _setState(() {});
      notifyInlineDataChanged();
    }
    return result;
  }

  void removePendingRows({
    required String sectionId,
    required String inlineId,
    required Iterable<String> pendingIds,
  }) {
    if (pendingIds.isEmpty) return;
    final key = inlinePendingKey(sectionId, inlineId);
    final entries = _pendingInlineRows[key];
    if (entries == null) return;
    entries.removeWhere((entry) => pendingIds.contains(entry.pendingId));
    if (entries.isEmpty) {
      _pendingInlineRows.remove(key);
    }
    _setState(() {});
    notifyInlineDataChanged();
  }

  void restoreNestedDraftsForEdit(
    String sectionId,
    InlinePendingRow entry,
  ) {
    if (entry.nestedInlineRows.isEmpty) return;
    for (final nested in entry.nestedInlineRows.entries) {
      final pendingKey = inlinePendingKey(sectionId, nested.key);
      _pendingInlineRows[pendingKey] =
          List<InlinePendingRow>.from(nested.value);
    }
    _setState(() {});
    notifyInlineDataChanged();
  }

  void captureNestedDraftsAfterEdit(
    String sectionId,
    InlinePendingRow entry,
  ) {
    final updated = takePendingInlineRowsForSection(sectionId);
    entry.nestedInlineRows
      ..clear()
      ..addAll(updated);
  }

  void addPendingInlineRow(
    String sectionId,
    InlineSectionConfig config,
    Map<String, dynamic> values,
    String targetSectionId, {
    Map<String, List<InlinePendingRow>> nestedInlineRows = const {},
  }) {
    final pendingKey = inlinePendingKey(sectionId, config.id);
    final entries = _pendingInlineRows.putIfAbsent(
      pendingKey,
      () => <InlinePendingRow>[],
    );
    final sectionContext = _sectionContextResolver(targetSectionId);
    final entry = _createPendingInlineRow(
      config,
      values,
      targetSectionId,
      sectionContext: sectionContext,
      nestedInlineRows: nestedInlineRows,
    );
    entries.add(entry);
    _setState(() {});
    notifyInlineDataChanged();
  }

  Map<String, String> buildPendingDisplayValues(
    InlineSectionConfig config,
    Map<String, dynamic> values,
    String targetSectionId,
  ) {
    final sectionContext = _sectionContextResolver(targetSectionId);
    return _buildPendingDisplayRow(
      config,
      values,
      targetSectionId,
      sectionContext,
    );
  }

  InlinePendingRow _createPendingInlineRow(
    InlineSectionConfig config,
    Map<String, dynamic> values,
    String targetSectionId, {
    required Map<String, dynamic> sectionContext,
    Map<String, List<InlinePendingRow>> nestedInlineRows =
        const <String, List<InlinePendingRow>>{},
    String? forcedPendingId,
  }) {
    final display = <String, String>{};
    display.addAll(
      _buildPendingDisplayRow(
        config,
        values,
        targetSectionId,
        sectionContext,
      ),
    );
    final tableValues = Map<String, String>.from(display);
    final pendingId = forcedPendingId ?? 'pending_${_pendingRowSequence++}';
    final nestedMap = <String, List<InlinePendingRow>>{};
    for (final entry in nestedInlineRows.entries) {
      nestedMap[entry.key] =
          entry.value.map(_clonePendingInlineRow).toList();
    }
    return InlinePendingRow(
      rawValues: Map<String, dynamic>.from(values),
      displayValues: display,
      tableValues: tableValues,
      pendingId: pendingId,
      nestedInlineRows: nestedMap,
    );
  }

  Map<String, String> _buildPendingDisplayRow(
    InlineSectionConfig config,
    Map<String, dynamic> values,
    String targetSectionId,
    Map<String, dynamic> sectionContext,
  ) {
    final pendingBuilder = kInlinePendingDisplayBuilders[config.id];
    if (pendingBuilder != null) {
      final builderContext = InlinePendingDisplayContext(
        inlineConfig: config,
        rawValues: values,
        sectionContext: sectionContext,
        resolveReferenceLabel: (fieldId, value) {
          final field = _findSectionField(targetSectionId, fieldId);
          if (field == null) return null;
          return _referenceLabelResolver(targetSectionId, field, value);
        },
        resolveReferenceMetadata: (fieldId, value) =>
            _referenceMetadataResolver(targetSectionId, fieldId, value),
      );
      final customDisplay = pendingBuilder(builderContext);
      return {
        for (final column in config.columns)
          column.key: customDisplay[column.key]?.toString() ?? '',
      };
    }
    final display = <String, String>{};
    for (final column in config.columns) {
      final pendingField =
          config.pendingFieldMapping[column.key] ?? column.key;
      var value = values[pendingField]?.toString() ?? '';
      if (value.isEmpty) {
        display[column.key] = '';
        continue;
      }
      final fieldMeta = _findSectionField(targetSectionId, pendingField);
      if (fieldMeta != null && fieldMeta.widgetType == 'reference') {
        final resolved =
            _referenceLabelResolver(targetSectionId, fieldMeta, value);
        if (resolved != null) {
          value = resolved;
        }
      }
      display[column.key] = value;
    }
    return display;
  }

  SectionField? _findSectionField(String sectionId, String fieldId) {
    final fields = _sectionFieldsResolver()[sectionId];
    if (fields == null) return null;
    for (final field in fields) {
      if (field.id == fieldId) return field;
    }
    return null;
  }

  InlinePendingRow _clonePendingInlineRow(InlinePendingRow source) {
    final nested = <String, List<InlinePendingRow>>{};
    for (final entry in source.nestedInlineRows.entries) {
      nested[entry.key] =
          entry.value.map(_clonePendingInlineRow).toList();
    }
    return InlinePendingRow(
      rawValues: Map<String, dynamic>.from(source.rawValues),
      displayValues: Map<String, String>.from(source.displayValues),
      tableValues: Map<String, String>.from(source.tableValues),
      pendingId: source.pendingId,
      nestedInlineRows: nested,
    );
  }

  Future<void> loadInlineSectionsForRow(
    String sectionId,
    TableRowData row,
  ) async {
    final inlineOverrides = _inlineOverridesResolver()[sectionId];
    if (inlineOverrides == null || inlineOverrides.isEmpty) return;
    final rowId = row['id'];
    if (rowId == null) return;
    final List<Future<void>> pending = [];
    for (final inline in inlineOverrides) {
      final key = inlineKey(sectionId, rowId, inline.id);
      _setState(() {
        _inlineLoadingKeys.add(key);
      });
      final foreignValue = inline.foreignKeyParentField == null
          ? rowId
          : row[inline.foreignKeyParentField];
      if (foreignValue == null) {
        _setState(() {
          _inlineLoadingKeys.remove(key);
          _inlineSectionData[key] = const [];
        });
        continue;
      }
      pending.add(
        _moduleRepository
            .fetchInlineRows(
              inline.dataSource,
              foreignKeyColumn: inline.foreignKeyColumn,
              foreignKeyValue: foreignValue,
            )
            .then((rows) {
          _setState(() {
            _inlineSectionData[key] = rows;
            _inlineLoadingKeys.remove(key);
          });
        }).catchError((error) {
          debugPrint('Error loading inline "$key": $error');
          _setState(() {
            _inlineLoadingKeys.remove(key);
            _inlineSectionData.remove(key);
          });
        }),
      );
    }
    if (pending.isEmpty) return;
    await Future.wait(pending);
  }

  Future<bool> persistPendingInlineRows({
    required String parentSectionId,
    required dynamic parentRowId,
  }) async {
    final inlineOverrides = _inlineOverridesResolver()[parentSectionId];
    if (inlineOverrides == null || inlineOverrides.isEmpty) return false;
    bool shouldReload = false;
    for (final inline in inlineOverrides) {
      final pendingKey = inlinePendingKey(parentSectionId, inline.id);
      final entries = _pendingInlineRows[pendingKey];
      if (entries == null || entries.isEmpty) continue;
      final targetSectionId = inline.formSectionId;
      final foreignKeyField = inline.formForeignKeyField;
      if (targetSectionId == null || foreignKeyField == null) continue;
      final dataSource = _sectionDataSourceResolver()[targetSectionId];
      if (dataSource == null) continue;
      for (final entry in entries) {
        final payload = _sanitizePayloadForSection(
          targetSectionId,
          entry.rawValues,
        );
        payload[foreignKeyField] = parentRowId;
        final savedRow = await _moduleRepository.insertRow(
          dataSource,
          payload,
        );
        final savedId = savedRow['id'];
        if (savedId != null && entry.nestedInlineRows.isNotEmpty) {
          await _persistNestedInlineRows(
            targetSectionId,
            entry.nestedInlineRows,
            savedId,
          );
        }
      }
      _pendingInlineRows.remove(pendingKey);
      shouldReload = true;
    }
    if (shouldReload) {
      notifyInlineDataChanged();
    }
    return shouldReload;
  }

  Future<void> _persistNestedInlineRows(
    String sectionId,
    Map<String, List<InlinePendingRow>> nestedRows,
    dynamic parentId,
  ) async {
    if (nestedRows.isEmpty) return;
    final overrides = _inlineOverridesResolver()[sectionId];
    if (overrides == null || overrides.isEmpty) return;
    for (final entry in nestedRows.entries) {
      InlineSectionConfig? config;
      for (final inline in overrides) {
        if (inline.id == entry.key) {
          config = inline;
          break;
        }
      }
      if (config == null) continue;
      final targetSectionId = config.formSectionId;
      final foreignKeyField = config.formForeignKeyField;
      if (targetSectionId == null || foreignKeyField == null) continue;
      final dataSource = _sectionDataSourceResolver()[targetSectionId];
      if (dataSource == null) continue;
      for (final pending in entry.value) {
        final payload = Map<String, dynamic>.from(pending.rawValues);
        final sanitized = _sanitizePayloadForSection(
          targetSectionId,
          payload,
        );
        sanitized[foreignKeyField] = parentId;
        final savedRow = await _moduleRepository.insertRow(
          dataSource,
          sanitized,
        );
        final savedId = savedRow['id'];
        if (savedId != null && pending.nestedInlineRows.isNotEmpty) {
          await _persistNestedInlineRows(
            targetSectionId,
            pending.nestedInlineRows,
            savedId,
          );
        }
      }
    }
  }

  Map<String, dynamic> _sanitizePayloadForSection(
    String sectionId,
    Map<String, dynamic> values,
  ) {
    final fields = _sectionFieldsResolver()[sectionId];
    if (fields == null || fields.isEmpty) {
      return Map<String, dynamic>.from(values)
        ..removeWhere((_, value) => value == null);
    }
    final allowed = <String>{for (final field in fields) field.id};
    final sanitized = <String, dynamic>{};
    for (final entry in values.entries) {
      if (allowed.contains(entry.key) && entry.value != null) {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }
}

typedef SectionContextResolver = Map<String, dynamic> Function(String sectionId);

typedef SectionOverridesResolver = Map<String, List<InlineSectionConfig>>
    Function();

typedef SectionFieldsResolver = Map<String, List<SectionField>> Function();

typedef SectionDataSourceResolver = Map<String, SectionDataSource> Function();

typedef InlineShellSetState = void Function(VoidCallback fn);

typedef ReferenceLabelResolver = String? Function(
  String sectionId,
  SectionField field,
  String value,
);

typedef ReferenceMetadataResolver = Map<String, dynamic>? Function(
  String sectionId,
  String fieldId,
  String value,
);
