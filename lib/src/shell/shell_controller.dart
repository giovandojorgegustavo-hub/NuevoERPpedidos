import 'dart:async';

import 'package:erp_app/src/domains/clientes/client_context_service.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_coverage_service.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_inline_coordinator.dart';
import 'package:erp_app/src/domains/pedidos/pedido_pago_coordinator.dart';
import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/navegacion/registro_vistas.dart';
import 'package:erp_app/src/shared/logger/app_logger.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shared/utils/row_normalizers.dart';
import 'package:erp_app/src/shared/utils/template_formatters.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/controllers/navigation_controller.dart';
import 'package:erp_app/src/shell/controllers/reference_options_controller.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/section_form_coordinator.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Controlador central encargado de orquestar el estado del shell.
/// Fase 1: expone el estado necesario y prepara los contractos para las
/// operaciones futuras. La lógica aún vive en `ShellPage`.
class ShellController extends ChangeNotifier {
  ShellController({
    required ModuleRepository moduleRepository,
    required SectionStateController sectionStateController,
    required NavigationController navigationController,
    required InlineDraftService inlineDraftService,
    required ReferenceOptionsController referenceOptionsController,
    required SectionFormCoordinator sectionFormCoordinator,
    required ClientContextService clientContextService,
    required PedidoPagoCoordinator pedidoPagoCoordinator,
    required MovimientoInlineCoordinator movimientoInlineCoordinator,
    required MovimientoCoverageService movimientoCoverageService,
  })  : _moduleRepository = moduleRepository,
        _sectionStateController = sectionStateController,
        _navigationController = navigationController,
        _inlineDraftService = inlineDraftService,
        _referenceOptionsController = referenceOptionsController,
        _sectionFormCoordinator = sectionFormCoordinator,
        _clientContextService = clientContextService,
        _pedidoPagoCoordinator = pedidoPagoCoordinator,
        _movimientoInlineCoordinator = movimientoInlineCoordinator,
        _movimientoCoverageService = movimientoCoverageService;

  final ModuleRepository _moduleRepository;
  final SectionStateController _sectionStateController;
  final NavigationController _navigationController;
  final InlineDraftService _inlineDraftService;
  final ReferenceOptionsController _referenceOptionsController;
  final SectionFormCoordinator _sectionFormCoordinator;
  final ClientContextService _clientContextService;
  final PedidoPagoCoordinator _pedidoPagoCoordinator;
  final MovimientoInlineCoordinator _movimientoInlineCoordinator;
  final MovimientoCoverageService _movimientoCoverageService;

  bool isLoadingModules = true;
  String? loadingError;
  String? loadingSectionId;
  UserProfile? userProfile;

  final Map<String, Map<String, dynamic>> _sectionContextValues = {};

  /// --- Getters públicos utilizados por la vista ---

  List<ModuleConfig> get modules => _navigationController.modules;
  ModuleConfig? get activeModule => _navigationController.activeModule;
  String? get activeSectionId => _navigationController.activeSectionId;
  SectionContentMode get activeContentMode =>
      _navigationController.activeContentMode;
  bool get showMobileModulePicker =>
      _navigationController.showMobileModulePicker;
  bool get showDesktopModulePicker =>
      _navigationController.showDesktopModulePicker;
  bool get hasNavigationSnapshots => _navigationController.hasSnapshots;

  Map<String, SectionDataSource> get sectionDataSources =>
      _sectionStateController.sectionDataSources;
  Map<String, List<SectionField>> get sectionFields =>
      _sectionStateController.sectionFields;
  Map<String, List<TableRowData>> get sectionRows =>
      _sectionStateController.sectionRows;
  Map<String, List<TableColumnConfig>> get sectionColumns =>
      _sectionStateController.sectionColumns;
  Set<String> get manualTableColumns =>
      _sectionStateController.manualTableColumns;
  Map<String, Map<String, dynamic> Function(Map<String, dynamic>)>
      get rowTransformers => _sectionStateController.rowTransformers;
  Map<String, TableRowData?> get sectionSelectedRows =>
      _sectionStateController.sectionSelectedRows;
  Map<String, SectionFormMode> get sectionFormModes =>
      _sectionStateController.sectionFormModes;
  Map<String, List<DetailFieldOverride>> get detailFieldOverrides =>
      _sectionStateController.detailFieldOverrides;
  Map<String, String? Function(Map<String, dynamic>)>
      get detailSubtitleBuilders =>
          _sectionStateController.detailSubtitleBuilders;
  Map<String, List<InlineSectionConfig>> get inlineSectionOverrides =>
      _sectionStateController.inlineSectionOverrides;

  InlineDraftService get inlineDraftService => _inlineDraftService;
  ReferenceOptionsController get referenceOptionsController =>
      _referenceOptionsController;
  SectionFormCoordinator get sectionFormCoordinator => _sectionFormCoordinator;
  ClientContextService get clientContextService => _clientContextService;
  PedidoPagoCoordinator get pedidoPagoCoordinator => _pedidoPagoCoordinator;
  MovimientoInlineCoordinator get movimientoInlineCoordinator =>
      _movimientoInlineCoordinator;
  MovimientoCoverageService get movimientoCoverageService =>
      _movimientoCoverageService;
  ModuleRepository get moduleRepository => _moduleRepository;
  ModuleSection? findModuleSectionById(String sectionId) {
    return _navigationController.findModuleSectionById(sectionId);
  }

  ModuleConfig? findModuleById(String? moduleId) {
    return _navigationController.findModuleById(moduleId);
  }

  void showModulePicker({required bool isMobile, required bool visible}) {
    _navigationController.showModulePicker(
      isMobile: isMobile,
      visible: visible,
    );
    notifyListeners();
  }

  void pushSnapshot(NavigationSnapshot snapshot) {
    _navigationController.pushSnapshot(snapshot);
  }

  NavigationSnapshot? popSnapshot() {
    return _navigationController.popSnapshot();
  }

  void resetNavigationStack() {
    _navigationController.resetNavigationStack();
  }

  Map<String, dynamic> sectionContext(String sectionId) {
    return _sectionContextValues[sectionId] ?? const <String, dynamic>{};
  }

  void setSectionContext(String sectionId, Map<String, dynamic>? values) {
    if (values == null || values.isEmpty) {
      _sectionContextValues.remove(sectionId);
    } else {
      _sectionContextValues[sectionId] = values;
    }
    notifyListeners();
  }

  /// --- Métodos placeholder que se implementarán en fases siguientes ---

  bool sectionExists(String sectionId) {
    return _navigationController.sectionExists(sectionId);
  }

  ModuleConfig? moduleForSection(String sectionId) {
    for (final module in _navigationController.modules) {
      for (final section in module.sections) {
        if (section.id == sectionId) return module;
      }
    }
    return null;
  }

  bool get isAdmin => (userProfile?.role.toLowerCase().trim() ?? '') == 'admin';
  bool get isBaseUser => userProfile?.isBaseUser ?? false;
  bool get hasAssignedBase => userProfile?.hasAssignedBase ?? false;

  Future<void> initializeShell() async {
    final modulesFuture = _moduleRepository.fetchModules();
    await _loadUserProfile();
    await _loadModules(metadataFuture: modulesFuture);
  }

  Future<void> onModuleSelected(
    ModuleConfig module, {
    required bool fromMobile,
  }) async {
    resetNavigationStack();
    _navigationController.selectModule(module, fromMobile: fromMobile);
    notifyListeners();
    final sectionId = activeSectionId;
    if (sectionId != null) {
      await onRefreshSection(sectionId);
    }
  }

  Future<void> onSectionSelected(String sectionId) async {
    resetNavigationStack();
    _navigationController.selectSection(sectionId);
    notifyListeners();
    await onRefreshSection(sectionId);
  }

  Future<void> onRowSelected(TableRowData row) async {
    final sectionId = activeSectionId;
    if (sectionId == null) return;
    resetNavigationStack();
    _sectionStateController.setSelectedRow(sectionId, row);
    _sectionStateController.setFormMode(sectionId, SectionFormMode.edit);
    _navigationController.setActiveContentMode(SectionContentMode.detail);
    _inlineDraftService.clearPendingRows(sectionId);
    notifyListeners();
    AppLogger.event(
      'row_selected',
      payload: {'sectionId': sectionId, 'rowId': _rowIdentifier(row)},
    );
    await _inlineDraftService.loadInlineSectionsForRow(sectionId, row);
  }

  Future<void> onRefreshSection(String sectionId) async {
    await _loadSectionData(sectionId);
  }

  Future<void> onBulkDelete(
    String sectionId,
    List<TableRowData> rows,
  ) async {
    final dataSource = sectionDataSources[sectionId];
    if (dataSource == null || dataSource.formRelation.isEmpty) return;
    final ids = rows
        .map((row) => row['id'])
        .whereType<dynamic>()
        .toList(growable: false);
    if (ids.isEmpty) return;
    await _moduleRepository.deleteRows(dataSource, ids);
    await _loadSectionData(sectionId);
  }

  void onContentModeChanged(SectionContentMode mode) {
    _navigationController.setActiveContentMode(mode);
    notifyListeners();
  }

  bool hasInlineRows(String sectionId, String inlineId) {
    final pendingRows = _inlineDraftService.findPendingRows(
      sectionId,
      inlineId,
    );
    if (pendingRows.isNotEmpty) return true;
    final row = _sectionStateController.sectionSelectedRows[sectionId];
    final rowId = row?['id'];
    if (rowId == null) return false;
    final key = _inlineDraftService.inlineKey(sectionId, rowId, inlineId);
    if (_inlineDraftService.inlineLoadingKeys.contains(key)) {
      return true;
    }
    final persisted = _inlineDraftService.inlineSectionData[key];
    return persisted != null && persisted.isNotEmpty;
  }

  bool shouldLoadInlineSections(String sectionId, Map<String, dynamic> row) {
    final overrides = inlineSectionOverrides[sectionId];
    if (overrides == null || overrides.isEmpty) return false;
    final rowId = row['id'];
    if (rowId == null) return false;
    for (final inline in overrides) {
      final key = _inlineDraftService.inlineKey(sectionId, rowId, inline.id);
      if (!_inlineDraftService.inlineSectionData.containsKey(key) &&
          !_inlineDraftService.inlineLoadingKeys.contains(key)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _loadUserProfile() async {
    AppLogger.event('profile_load_start');
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        userProfile = null;
        _applyProfileReferenceFilters(null);
        notifyListeners();
        return;
      }
      final response = await Supabase.instance.client
          .from('perfiles')
          .select('user_id,nombre,rol,idbase')
          .eq('user_id', user.id)
          .maybeSingle();
      if (response == null) {
        userProfile = null;
        _applyProfileReferenceFilters(null);
      } else {
        final data = Map<String, dynamic>.from(response);
        userProfile = UserProfile(
          userId: data['user_id']?.toString() ?? user.id,
          name: data['nombre']?.toString(),
          role: data['rol']?.toString() ?? 'atencion',
          baseId: data['idbase']?.toString(),
        );
        _applyProfileReferenceFilters(userProfile);
        AppLogger.event(
          'profile_load_success',
          payload: {'role': userProfile?.role},
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error('profile_load_failed', error, stackTrace: stackTrace);
      userProfile = null;
      _applyProfileReferenceFilters(null);
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadModules({Future<ModuleMetadata>? metadataFuture}) async {
    isLoadingModules = true;
    loadingError = null;
    notifyListeners();
    AppLogger.event('modules_load_start');
    try {
      final metadata =
          await (metadataFuture ?? _moduleRepository.fetchModules());
      AppLogger.event(
        'modules_load_success',
        payload: {'modules': metadata.modules.length},
      );
      resetNavigationStack();
      _sectionStateController.clear();
      final filtered = _filterModulesByProfile(metadata.modules);
      _navigationController.setModules(filtered);
      _sectionStateController.setSectionDataSources(
        metadata.sectionDataSources,
      );
      _sectionStateController.setSectionFields(metadata.sectionFields);
      _applyStaticOverrides();
      isLoadingModules = false;
      loadingError = null;
      notifyListeners();
      final initialSectionId = activeSectionId;
      if (initialSectionId != null) {
        await _loadSectionData(initialSectionId);
      }
    } catch (error, stackTrace) {
      AppLogger.error('modules_load_failed', error, stackTrace: stackTrace);
      loadingError = error.toString();
      isLoadingModules = false;
      notifyListeners();
    }
  }

  void _applyProfileReferenceFilters(UserProfile? profile) {
    final baseId = profile?.baseId?.trim();
    if (baseId == null || baseId.isEmpty) {
      _referenceOptionsController.setReferenceFilter('viajes_bases', 'idbase', null);
      return;
    }
    _referenceOptionsController.setReferenceFilter(
      'viajes_bases',
      'idbase',
      {'idbase': baseId},
    );
  }

  List<ModuleConfig> _filterModulesByProfile(List<ModuleConfig> modules) {
    final role = userProfile?.role.toLowerCase().trim() ?? '';
    List<ModuleConfig> scopedModules = modules;
    if (role == 'bases') {
      scopedModules = modules
          .where((module) => module.id == 'base')
          .toList(growable: false);
    } else if (role == 'atencion') {
      const allowed = {'pedidos', 'reporte_asistencia'};
      scopedModules = modules
          .where((module) => allowed.contains(module.id))
          .toList(growable: false);
    } else if (role == 'gerente') {
      scopedModules = modules
          .where(
            (module) =>
                module.id != 'contabilidad' &&
                module.id != 'reportes_generales',
          )
          .toList(growable: false);
    }
    if (scopedModules.isEmpty) {
      scopedModules = modules;
    }
    final filtered = <ModuleConfig>[];
    for (final module in scopedModules) {
      final sections = module.sections
          .where((section) {
            if (isBaseUser && section.id == 'viajes') return false;
            if (!isBaseUser && section.id == 'viajes_bases') return false;
            if (!isAdmin && section.id == 'cuentas_bancarias_asignadas') {
              return false;
            }
            return true;
          })
          .toList(growable: false);
      if (sections.isEmpty) continue;
      if (sections.length == module.sections.length) {
        filtered.add(module);
      } else {
        filtered.add(_copyModuleWithSections(module, sections));
      }
    }
    return filtered.isEmpty ? scopedModules : filtered;
  }

  ModuleConfig _copyModuleWithSections(
    ModuleConfig module,
    List<ModuleSection> sections,
  ) {
    return ModuleConfig(
      id: module.id,
      name: module.name,
      icon: module.icon,
      description: module.description,
      sections: sections,
    );
  }

  Future<void> _loadSectionData(String sectionId) async {
    final dataSource = sectionDataSources[sectionId];
    if (dataSource == null) return;
    loadingSectionId = sectionId;
    notifyListeners();
    AppLogger.event('section_load_start', payload: {'sectionId': sectionId});
    try {
      final data = await _moduleRepository.fetchSectionRows(dataSource);
      final baseRows = data
          .map<TableRowData>((row) => Map<String, dynamic>.from(row))
          .map<TableRowData>(normalizeRowForDisplay)
          .toList(growable: false);
      final transformer = rowTransformers[sectionId];
      final rows = transformer == null
          ? baseRows
          : baseRows
              .map<TableRowData>((row) => transformer(row))
              .toList(growable: false);
      _sectionStateController.setRows(sectionId, rows);
      if (!manualTableColumns.contains(sectionId)) {
        _sectionStateController.setColumns(sectionId, _buildColumns(rows));
      }
      if (rows.isNotEmpty &&
          _sectionStateController.sectionSelectedRows[sectionId] == null) {
        _sectionStateController.setSelectedRow(sectionId, rows.first);
      }
      AppLogger.event(
        'section_load_success',
        payload: {'sectionId': sectionId, 'rows': rows.length},
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'section_load_failed',
        error,
        stackTrace: stackTrace,
        payload: {'sectionId': sectionId},
      );
      loadingError = error.toString();
    } finally {
      if (loadingSectionId == sectionId) {
        loadingSectionId = null;
      }
      notifyListeners();
    }
  }

  void _applyStaticOverrides() {
    _sectionStateController.manualTableColumns.clear();
    _sectionStateController.rowTransformers.clear();
    _sectionStateController.detailFieldOverrides.clear();
    _sectionStateController.detailSubtitleBuilders.clear();
    _sectionStateController.inlineSectionOverrides.clear();
    for (final entry in kSectionOverrides.entries) {
      final override = entry.value;
      if (override.formFields != null) {
        _sectionStateController.sectionFields[entry.key] =
            override.formFields!;
      }
      if (override.dataSource != null) {
        _sectionStateController.sectionDataSources[entry.key] =
            override.dataSource!;
      }
      if (override.tableColumns != null) {
        _sectionStateController.sectionColumns[entry.key] =
            override.tableColumns!;
        _sectionStateController.manualTableColumns.add(entry.key);
      }
      if (override.rowTransformer != null) {
        _sectionStateController.rowTransformers[entry.key] =
            override.rowTransformer!;
      }
      if (override.detailFields != null) {
        _sectionStateController.detailFieldOverrides[entry.key] =
            override.detailFields!;
      }
      if (override.detailSubtitleBuilder != null) {
        _sectionStateController.detailSubtitleBuilders[entry.key] =
            override.detailSubtitleBuilder!;
      }
      if (override.inlineSections != null) {
        _sectionStateController.inlineSectionOverrides[entry.key] =
            override.inlineSections!;
      }
    }
  }

  String? _rowIdentifier(TableRowData row) {
    final directId = row['id'];
    if (directId != null) return directId.toString();
    for (final entry in row.entries) {
      final key = entry.key.toLowerCase();
      if (key == 'uuid' || key == 'guid') {
        return entry.value?.toString();
      }
      if (key.startsWith('id')) {
        final value = entry.value;
        if (value != null) return value.toString();
      }
    }
    return null;
  }

  List<TableColumnConfig> _buildColumns(List<TableRowData> rows) {
    if (rows.isEmpty) return [];
    final keys = rows.first.keys;
    return keys
        .map(
          (key) => TableColumnConfig(key: key, label: formatColumnLabel(key)),
        )
        .toList(growable: false);
  }
}
