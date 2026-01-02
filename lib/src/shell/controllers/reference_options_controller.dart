import 'package:flutter/foundation.dart';

import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';

/// Centraliza el manejo de referencias y listas de opciones.
///
/// ShellPage actualmente mezcla filtros dinámicos, cachés por campo, helper
/// texts y lógica específica para abrir reference forms. Esta clase capturará
/// todo ese estado para exponer un API declarativa:
///   * cargar opciones de referencia para una sección completa.
///   * administrar filtros dinámicos por campo (ej. cliente seleccionado).
///   * exponer helper texts y metadata para tooltips de referencias.
///   * coordinar la creación de nuevas referencias via `ReferenceFormPage`.
///
/// La implementación concreta se migrará en pasos subsecuentes; por ahora solo
/// describimos la superficie y movemos el estado para romper el “god object”.
class ReferenceOptionsController {
  ReferenceOptionsController({
    required ModuleRepository moduleRepository,
    required ReferenceFormLauncher referenceFormLauncher,
    required SectionFieldsResolver sectionFieldsResolver,
    required SectionContextResolver sectionContextResolver,
    required SectionContextWriter sectionContextWriter,
    required SectionDataSourceResolver sectionDataSourceResolver,
    required ReferenceShellSetState setState,
    required SectionDefaultRowBuilder defaultRowBuilder,
    required FormFieldsBuilder formFieldsBuilder,
    required PayloadPreparer payloadPreparer,
    required ReferenceMessageHandler showMessage,
    required ClientScopedFormResolver isClientScopedReferenceForm,
    Map<String, List<ReferenceOption>>? initialOptions,
    Map<String, Map<String, Map<String, dynamic>>>? initialFilters,
    Map<String, List<ReferenceDisplayField>>? referenceDisplayConfigs,
  })  : _moduleRepository = moduleRepository,
        _referenceFormLauncher = referenceFormLauncher,
        _sectionFieldsResolver = sectionFieldsResolver,
        _sectionContextResolver = sectionContextResolver,
        _sectionContextWriter = sectionContextWriter,
        _sectionDataSourceResolver = sectionDataSourceResolver,
        _setState = setState,
        _defaultRowBuilder = defaultRowBuilder,
        _formFieldsBuilder = formFieldsBuilder,
        _payloadPreparer = payloadPreparer,
        _showMessage = showMessage,
        _isClientScopedReferenceForm = isClientScopedReferenceForm {
    if (initialOptions != null) {
      _referenceOptions.addAll(initialOptions);
    }
    if (initialFilters != null) {
      _referenceFieldFilters.addAll(initialFilters);
    }
    if (referenceDisplayConfigs != null) {
      _referenceDisplayFields.addAll(referenceDisplayConfigs);
    }
  }

  final ModuleRepository _moduleRepository;
  final ReferenceFormLauncher _referenceFormLauncher;
  final SectionFieldsResolver _sectionFieldsResolver;
  final SectionContextResolver _sectionContextResolver;
  final SectionContextWriter _sectionContextWriter;
  final SectionDataSourceResolver _sectionDataSourceResolver;
  final ReferenceShellSetState _setState;
  final SectionDefaultRowBuilder _defaultRowBuilder;
  final FormFieldsBuilder _formFieldsBuilder;
  final PayloadPreparer _payloadPreparer;
  final ReferenceMessageHandler _showMessage;
  final ClientScopedFormResolver _isClientScopedReferenceForm;

  final Map<String, List<ReferenceOption>> _referenceOptions = {};
  final Map<String, Map<String, Map<String, dynamic>>> _referenceFieldFilters =
      {};
  final Set<String> _referenceErrorKeys = {};
  final Map<String, List<ReferenceDisplayField>> _referenceDisplayFields = {};
  final Map<String, Future<void>> _pendingReferenceLoads = {};

  Map<String, List<ReferenceOption>> get referenceOptions =>
      Map.unmodifiable(_referenceOptions);

  Map<String, Map<String, Map<String, dynamic>>> get referenceFieldFilters =>
      Map.unmodifiable(_referenceFieldFilters);

  /// Registers helper display configs por campo, reutilizando la definición que
  /// hoy se encuentra embebida en ShellPage.
  void registerDisplayConfigs(
    Map<String, List<ReferenceDisplayField>> configs,
  ) {
    _referenceDisplayFields
      ..clear()
      ..addAll(configs);
  }

  /// Applies a filter para un campo referencia específico.
  void setReferenceFilter(
    String sectionId,
    String fieldId,
    Map<String, dynamic>? filter,
  ) {
    final sectionFilters =
        _referenceFieldFilters.putIfAbsent(sectionId, () => {});
    if (filter == null || filter.isEmpty) {
      sectionFilters.remove(fieldId);
      if (sectionFilters.isEmpty) {
        _referenceFieldFilters.remove(sectionId);
      }
    } else {
      sectionFilters[fieldId] = filter;
    }
    _referenceOptions.remove(_referenceKey(sectionId, fieldId));
    _setState(() {});
  }

  /// Loads reference options for todos los campos tipo reference de una sección.
  Future<void> loadReferenceOptionsForSection(
    String sectionId, {
    bool forceReload = false,
  }) async {
    final fields = _sectionFieldsResolver()[sectionId];
    if (fields == null) return;
    final List<Future<void>> pending = [];
    final sectionFilters = _referenceFieldFilters[sectionId];
    for (final field in fields) {
      if (!_requiresOptions(field)) continue;
      final key = _referenceKey(sectionId, field.id);
      if (forceReload) {
        _referenceOptions.remove(key);
        _referenceErrorKeys.remove(key);
      } else {
        final inflight = _pendingReferenceLoads[key];
        if (inflight != null) {
          pending.add(inflight);
          continue;
        }
        if (_referenceOptions.containsKey(key)) {
          continue;
        }
      }
      final filter = sectionFilters?[field.id];
      final extraColumns = _referenceExtraColumnsForField(sectionId, field.id);
      late final Future<void> tracked;
      final future = _moduleRepository
          .fetchReferenceOptions(
            field,
            filters: filter,
            extraColumns: extraColumns,
          )
          .then((options) {
        _referenceErrorKeys.remove(key);
        _setState(() {
          _referenceOptions[key] = options;
        });
      }).catchError((error) {
        if (_referenceErrorKeys.add(key)) {
          debugPrint(
            'Error cargando referencias para $key: $error',
          );
        }
      });
      tracked = future.whenComplete(() {
        if (identical(_pendingReferenceLoads[key], tracked)) {
          _pendingReferenceLoads.remove(key);
        }
      });
      _pendingReferenceLoads[key] = tracked;
      pending.add(tracked);
    }
    if (pending.isEmpty) return;
    await Future.wait(pending);
  }

  /// Returns helper text para mostrar metadata extra debajo de un dropdown.
  String? referenceHelperText(
    String sectionId,
    String fieldId,
    String? value,
  ) {
    if (value == null || value.isEmpty) return null;
    final config = _referenceDisplayFields['$sectionId::$fieldId'];
    if (config == null || config.isEmpty) return null;
    final options = _referenceOptions[_referenceKey(sectionId, fieldId)];
    if (options == null) return null;
    ReferenceOption? selected;
    for (final option in options) {
      if (option.value == value) {
        selected = option;
        break;
      }
    }
    final metadata = selected?.metadata;
    if (metadata == null) return null;
    final lines = <String>[];
    for (final field in config) {
      final raw = metadata[field.metadataKey]?.toString();
      if (raw == null || raw.isEmpty || raw == 'null') continue;
      lines.add('${field.label}: $raw');
    }
    if (lines.isEmpty) return null;
    return lines.join('\n');
  }

  List<ReferenceOption> optionsForField(
    String sectionId,
    String fieldId,
  ) {
    return _referenceOptions[_referenceKey(sectionId, fieldId)] ??
        const <ReferenceOption>[];
  }

  Map<String, dynamic>? referenceMetadataForValue(
    String sectionId,
    String fieldId,
    String value,
  ) {
    if (value.isEmpty) return null;
    final options = _referenceOptions[_referenceKey(sectionId, fieldId)];
    if (options == null) return null;
    for (final option in options) {
      if (option.value == value) return option.metadata;
    }
    return null;
  }

  String? resolveReferenceLabel(
    String sectionId,
    SectionField field,
    String value,
  ) {
    if (value.isEmpty) return null;
    final options = optionsForField(sectionId, field.id);
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return null;
  }

  void addOption(String sectionId, String fieldId, ReferenceOption option) {
    final key = _referenceKey(sectionId, fieldId);
    final current = _referenceOptions.putIfAbsent(key, () => []);
    if (current.any((existing) => existing.value == option.value)) return;
    current.add(option);
    _setState(() {});
  }

  void invalidateAll() {
    if (_referenceOptions.isEmpty) return;
    _referenceOptions.clear();
    _setState(() {});
  }

  Future<ReferenceOption?> handleReferenceAdd({
    required SectionField field,
    required String parentSectionId,
  }) async {
    final targetSectionId = field.referenceSectionId;
    if (targetSectionId == null) {
      _showMessage('No hay formulario asignado para ${field.label}.');
      return null;
    }
    final dataSource = _sectionDataSourceResolver()[targetSectionId];
    if (dataSource == null || dataSource.formRelation.isEmpty) {
      _showMessage('No se encontró la fuente de datos para $targetSectionId.');
      return null;
    }
    final parentContext = _sectionContextResolver(parentSectionId);
    final contextClientId = parentContext['idcliente']?.toString();
    final contextClientName = parentContext['cliente_nombre']?.toString();
    final contextBaseId = parentContext['idbase']?.toString();

    final targetContext = <String, dynamic>{};
    if (contextClientId != null && contextClientId.isNotEmpty) {
      targetContext['idcliente'] = contextClientId;
      targetContext['cliente_nombre'] = contextClientName ?? '';
    }
    if (contextBaseId != null && contextBaseId.isNotEmpty) {
      targetContext['idbase'] = contextBaseId;
    }

    if (targetContext.isEmpty) {
      _sectionContextWriter(targetSectionId, null);
    } else {
      _sectionContextWriter(targetSectionId, targetContext);
    }

    if (_isClientScopedReferenceForm(targetSectionId)) {
      if (contextClientId != null && contextClientId.isNotEmpty) {
        setReferenceFilter(
          targetSectionId,
          'idcliente',
          {'id': contextClientId},
        );
      } else {
        setReferenceFilter(targetSectionId, 'idcliente', null);
      }
    }
    await loadReferenceOptionsForSection(targetSectionId);
    final row = _defaultRowBuilder(targetSectionId);
    if (contextClientId != null && contextClientId.isNotEmpty) {
      row['idcliente'] = contextClientId;
    }
    if (contextBaseId != null && contextBaseId.isNotEmpty) {
      row['idbase'] = contextBaseId;
    }
    final fields = _formFieldsBuilder(
      targetSectionId,
      row,
      SectionFormMode.create,
    );
    if (fields == null) {
      _showMessage('No hay campos configurados para $targetSectionId.');
      return null;
    }
    final request = ReferenceFormRequest(
      sectionId: targetSectionId,
      field: field,
      initialValues: row,
      title: 'Nuevo ${field.label}',
      fields: fields,
    );
    final submittedValues = await _referenceFormLauncher(request);
    if (submittedValues == null) return null;
    final payload = _payloadPreparer(submittedValues, targetSectionId);
    final savedRow = await _moduleRepository.insertRow(
      dataSource,
      payload,
    );
    final newId = savedRow['id']?.toString();
    if (newId == null) return null;
    await loadReferenceOptionsForSection(parentSectionId);
    final loadedOption = await _findOptionOrFetch(
      parentSectionId,
      field,
      newId,
    );
    final labelColumn = field.referenceLabelColumn ?? 'nombre';
    final fallbackLabel = savedRow[labelColumn]?.toString();
    final newLabel = loadedOption?.label ?? fallbackLabel ?? newId;
    final metadata =
        loadedOption?.metadata ?? Map<String, dynamic>.from(savedRow);
    final option = ReferenceOption(
      value: newId,
      label: newLabel,
      metadata: metadata,
    );
    addOption(parentSectionId, field.id, option);
    return option;
  }

  ReferenceOption? _findOption(
    String sectionId,
    String fieldId,
    String value,
  ) {
    if (value.isEmpty) return null;
    final options = _referenceOptions[_referenceKey(sectionId, fieldId)];
    if (options == null) return null;
    for (final option in options) {
      if (option.value == value) {
        return option;
      }
    }
    return null;
  }

  bool _requiresOptions(SectionField field) {
    return field.widgetType == 'reference' &&
        field.referenceRelation != null &&
        field.referenceRelation!.isNotEmpty;
  }

  Future<ReferenceOption?> _findOptionOrFetch(
    String parentSectionId,
    SectionField field,
    String value,
  ) async {
    final cached = _findOption(parentSectionId, field.id, value);
    if (cached != null) return cached;
    if (value.isEmpty) return null;
    final extraColumns =
        _referenceExtraColumnsForField(parentSectionId, field.id);
    final options = await _moduleRepository.fetchReferenceOptions(
      field,
      filters: {'id': value},
      extraColumns: extraColumns,
      limit: 1,
    );
    if (options.isEmpty) return null;
    return options.first;
  }

  List<String> _referenceExtraColumnsForField(
    String sectionId,
    String fieldId,
  ) {
    final config = _referenceDisplayFields['$sectionId::$fieldId'];
    if (config == null) return const [];
    return config.map((entry) => entry.metadataKey).toList(growable: false);
  }

  String _referenceKey(String sectionId, String fieldId) =>
      '$sectionId::$fieldId';

  // TODO: mover aquí la lógica completa de reference forms.

  SectionDataSource? dataSourceForSection(String sectionId) {
    return _sectionDataSourceResolver()[sectionId];
  }
}

/// Similar al helper de inline controller, expone el contexto almacenado para
/// una sección (usado para defaults en reference forms).
typedef SectionContextResolver = Map<String, dynamic> Function(String sectionId);

/// Permite resolver fields declarados en metadata.
typedef SectionFieldsResolver = Map<String, List<SectionField>> Function();

typedef SectionDataSourceResolver = Map<String, SectionDataSource> Function();

/// Callback para crear formularios referencia (el controller no conoce de UI).
typedef ReferenceFormLauncher = Future<Map<String, String>?> Function(
  ReferenceFormRequest request,
);

/// Describe la solicitud para abrir un referencia form.
class ReferenceFormRequest {
  const ReferenceFormRequest({
    required this.sectionId,
    required this.field,
    required this.initialValues,
    required this.title,
    required this.fields,
    this.saveLabel = 'Guardar',
    this.cancelLabel = 'Cancelar',
  });

  final String sectionId;
  final SectionField field;
  final Map<String, dynamic> initialValues;
  final String title;
  final List<FormFieldConfig> fields;
  final String saveLabel;
  final String cancelLabel;
}

/// Describe campos extra que se muestran como helper text debajo de una opción.
class ReferenceDisplayField {
  const ReferenceDisplayField({required this.label, required this.metadataKey});

  final String label;
  final String metadataKey;
}

typedef ReferenceShellSetState = void Function(VoidCallback fn);

typedef SectionContextWriter = void Function(
  String sectionId,
  Map<String, dynamic>? values,
);

typedef SectionDefaultRowBuilder = Map<String, dynamic> Function(
  String sectionId,
);

typedef FormFieldsBuilder = List<FormFieldConfig>? Function(
  String sectionId,
  Map<String, dynamic> row,
  SectionFormMode mode,
);

typedef PayloadPreparer = Map<String, dynamic> Function(
  Map<String, String> data,
  String sectionId,
);

typedef ReferenceMessageHandler = void Function(String message);

typedef ClientScopedFormResolver = bool Function(String sectionId);
