import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:erp_app/src/domains/clientes/client_context_service.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_coverage_service.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_inline_coordinator.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_service.dart';
import 'package:erp_app/src/domains/pedidos/pedido_inline_service.dart';
import 'package:erp_app/src/domains/pedidos/pedido_pago_coordinator.dart';
import 'package:erp_app/src/recursos/movimientos_constants.dart';
import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/logger/app_logger.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shared/utils/date_time_utils.dart'
    as date_time_utils;
import 'package:erp_app/src/shared/utils/template_formatters.dart';
import 'package:erp_app/src/shell/controllers/navigation_controller.dart';
import 'package:erp_app/src/shell/controllers/reference_options_controller.dart';
import 'package:erp_app/src/shell/controllers/section_config_builders.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/controllers/section_table_action_builder.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/reference_form_page.dart';
import 'package:erp_app/src/shell/section_action_controller.dart';
import 'package:erp_app/src/shell/section_form_coordinator.dart';
import 'package:erp_app/src/shell/services/pedidos_admin_service.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/services/inline_flow_service.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';
import 'package:erp_app/src/shell/services/viajes_detalle_service.dart';
import 'package:erp_app/src/shell/services/viajes_provincia_service.dart';
import 'package:erp_app/src/shell/shell_constants.dart';
import 'package:erp_app/src/shell/shell_controller.dart';

class _ReferenceOptionRowConfig {
  const _ReferenceOptionRowConfig({
    required this.fieldId,
    required this.labelColumn,
    this.metadataColumns = const {},
  });

  final String fieldId;
  final String labelColumn;
  final Map<String, String> metadataColumns;
}

const Map<String, List<_ReferenceOptionRowConfig>>
    _rowReferenceOptionConfigs = {
  'viajes_detalle': [
    _ReferenceOptionRowConfig(
      fieldId: 'idpacking',
      labelColumn: 'packing_display',
      metadataColumns: {
        'nombre': 'packing_nombre',
        'tipo': 'packing_tipo',
        'observacion': 'packing_observacion',
      },
    ),
  ],
};

/// Holds shell-wide orchestration state so that [ShellPage] can focus on UI.
class ShellViewModel extends ChangeNotifier {
  ShellViewModel({
    required ContextProvider contextProvider,
    ModuleRepository? moduleRepository,
    PedidoInlineService? pedidoInlineService,
    MovimientoService? movimientoService,
  })  : _contextProvider = contextProvider,
        _moduleRepository = moduleRepository ?? ModuleRepository(),
        _pedidoInlineService =
            pedidoInlineService ?? const PedidoInlineService(),
        _movimientoService = movimientoService ?? const MovimientoService(),
        _sectionStateController = SectionStateController(),
        _navigationController = NavigationController() {
    _initialize();
  }

  final ContextProvider _contextProvider;
  final ModuleRepository _moduleRepository;
  final PedidoInlineService _pedidoInlineService;
  final MovimientoService _movimientoService;
  late final MovimientoCoverageService _movimientoCoverageService;
  final List<GlobalNavAction> _globalActions = kDefaultGlobalNavActions;
  final SectionStateController _sectionStateController;
  final NavigationController _navigationController;
  late final SectionActionController _sectionActionController;
  late final InlineDraftService _inlineDraftService;
  late final ReferenceOptionsController _referenceController;
  late final TableConfigBuilder _tableConfigBuilder;
  late final DetailConfigBuilder _detailConfigBuilder;
  late final FormConfigBuilder _formConfigBuilder;
  late final SectionFormCoordinator _sectionFormCoordinator;
  late final ClientContextService _clientContextService;
  late final PedidoPagoCoordinator _pedidoPagoCoordinator;
  late final MovimientoInlineCoordinator _movimientoInlineCoordinator;
  late final ShellController _controller;
  late final VoidCallback _controllerListener;
  late final InlineFlowService _inlineFlowService;
  late final ViajesDetalleService _viajesDetalleService;
  late final ViajesProvinciaService _viajesProvinciaService;
  late final PedidosAdminService _pedidosAdminService;
  late final SectionTableActionBuilder _tableActionBuilder;

  final Map<String, List<ReferenceDisplayField>> _referenceDisplayConfigs = {
    'pedidos_movimientos::$kMovDestinoLimaDireccionField': [
      ReferenceDisplayField(label: 'Referencia', metadataKey: 'referencia'),
    ],
    'movimientos::$kMovDestinoLimaDireccionField': [
      ReferenceDisplayField(label: 'Referencia', metadataKey: 'referencia'),
    ],
    'pedidos_movimientos::$kMovDestinoLimaContactoField': [
      ReferenceDisplayField(
        label: 'Nombre del contacto',
        metadataKey: 'nombre_contacto',
      ),
    ],
    'movimientos::$kMovDestinoLimaContactoField': [
      ReferenceDisplayField(
        label: 'Nombre del contacto',
        metadataKey: 'nombre_contacto',
      ),
    ],
    'pedidos_movimientos::$kMovDestinoProvinciaDireccionField': [
      ReferenceDisplayField(
        label: 'Nombre completo',
        metadataKey: 'nombre_completo',
      ),
      ReferenceDisplayField(label: 'DNI', metadataKey: 'dni'),
    ],
    'movimientos::$kMovDestinoProvinciaDireccionField': [
      ReferenceDisplayField(
        label: 'Nombre completo',
        metadataKey: 'nombre_completo',
      ),
      ReferenceDisplayField(label: 'DNI', metadataKey: 'dni'),
    ],
    'viajes_detalle::idmovimiento': [
      ReferenceDisplayField(label: 'Cliente', metadataKey: 'cliente_nombre'),
      ReferenceDisplayField(
        label: 'Número cliente',
        metadataKey: 'cliente_numero',
      ),
      ReferenceDisplayField(
        label: 'Dirección',
        metadataKey: 'direccion_display',
      ),
      ReferenceDisplayField(
        label: 'Número contacto',
        metadataKey: 'contacto_numero_display',
      ),
      ReferenceDisplayField(
        label: 'Nombre contacto',
        metadataKey: 'contacto_nombre_display',
      ),
      ReferenceDisplayField(
        label: 'Destino provincia',
        metadataKey: 'provincia_destino',
      ),
      ReferenceDisplayField(
        label: 'Nombre destinatario',
        metadataKey: 'provincia_destinatario',
      ),
      ReferenceDisplayField(
        label: 'DNI destinatario',
        metadataKey: 'provincia_dni',
      ),
      ReferenceDisplayField(
        label: 'Base',
        metadataKey: 'base_nombre',
      ),
      ReferenceDisplayField(
        label: 'ID base',
        metadataKey: 'idbase',
      ),
    ],
    'viajes_provincia::idmovimiento': [
      ReferenceDisplayField(label: 'Cliente', metadataKey: 'cliente_nombre'),
      ReferenceDisplayField(
        label: 'Número cliente',
        metadataKey: 'cliente_numero',
      ),
      ReferenceDisplayField(
        label: 'Dirección',
        metadataKey: 'direccion_display',
      ),
      ReferenceDisplayField(
        label: 'Número contacto',
        metadataKey: 'contacto_numero_display',
      ),
      ReferenceDisplayField(
        label: 'Nombre contacto',
        metadataKey: 'contacto_nombre_display',
      ),
      ReferenceDisplayField(
        label: 'Destino provincia',
        metadataKey: 'provincia_destino',
      ),
      ReferenceDisplayField(
        label: 'Nombre destinatario',
        metadataKey: 'provincia_destinatario',
      ),
      ReferenceDisplayField(
        label: 'DNI destinatario',
        metadataKey: 'provincia_dni',
      ),
      ReferenceDisplayField(
        label: 'Base',
        metadataKey: 'base_nombre',
      ),
      ReferenceDisplayField(
        label: 'ID base',
        metadataKey: 'idbase',
      ),
    ],
    'viajes_detalle::idpacking': [
      ReferenceDisplayField(label: 'Nombre', metadataKey: 'nombre'),
      ReferenceDisplayField(label: 'Tipo', metadataKey: 'tipo'),
      ReferenceDisplayField(label: 'Observación', metadataKey: 'observacion'),
    ],
    'fabricaciones_internas_consumos::idproducto': [
      ReferenceDisplayField(
        label: 'Disponible',
        metadataKey: 'cantidad_disponible',
      ),
      ReferenceDisplayField(
        label: 'Costo promedio',
        metadataKey: 'costo_unitario',
      ),
    ],
    'fabricaciones_maquila_consumos::idproducto': [
      ReferenceDisplayField(
        label: 'Stock disponible',
        metadataKey: 'cantidad_disponible',
      ),
      ReferenceDisplayField(
        label: 'Costo promedio',
        metadataKey: 'costo_unitario',
      ),
    ],
    'transferencias_detalle::idproducto': [
      ReferenceDisplayField(
        label: 'Stock disponible',
        metadataKey: 'cantidad_disponible',
      ),
    ],
  };
  final Map<String, Map<String, String>> _formDraftValues = {};
  bool _controllerReady = false;
  bool _controllerRebuildPending = false;
  bool _isDisposed = false;

  bool get isLoadingModules => _controller.isLoadingModules;
  String? get loadingError => _controller.loadingError;
  String? get loadingSectionId => _controller.loadingSectionId;
  UserProfile? get userProfile => _controller.userProfile;

  List<ModuleConfig> get modules => _controller.modules;
  ModuleConfig? get activeModule => _controller.activeModule;
  String? get activeSectionId => _controller.activeSectionId;
  SectionContentMode get activeContentMode => _controller.activeContentMode;
  SectionContentMode get currentMode => _controller.activeContentMode;
  bool get showMobileModulePicker => _controller.showMobileModulePicker;
  bool get showDesktopModulePicker => _controller.showDesktopModulePicker;
  bool get hasNavigationSnapshots => _controller.hasNavigationSnapshots;

  bool get isAdmin => _controller.isAdmin;
  bool get isBaseUser => _controller.isBaseUser;
  bool get hasAssignedBase => _controller.hasAssignedBase;

  List<GlobalNavAction> get visibleGlobalActions => isAdmin
      ? _globalActions
      : _globalActions
          .where((action) => action.id != 'users')
          .toList(growable: false);

  ModuleSection? get currentSection => _currentSection();
  TableRowData? get selectedRow => activeSectionId == null
      ? null
      : _sectionSelectedRows[activeSectionId!];
  Map<String, String>? get draft =>
      activeSectionId == null ? null : _formDraftValues[activeSectionId!];

  TableViewConfig? get tableConfig => _buildTableConfig(currentSection);
  DetailViewConfig? get detailConfig => _buildDetailConfig(currentSection);
  FormViewConfig? get formConfig => currentMode == SectionContentMode.form
      ? _buildFormConfig(currentSection)
      : null;
  bool get isSectionLoading =>
      currentSection != null && loadingSectionId == currentSection!.id;

  void init() {
    _controller.initializeShell();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _inlineDraftService.dispose();
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  Future<void> openModule(
    ModuleConfig module, {
    required bool fromMobile,
  }) async {
    _logNavigationEvent(
      fromMobile ? 'module_selected_mobile' : 'module_selected',
      module: module,
    );
    await _controller.onModuleSelected(module, fromMobile: fromMobile);
  }

  Future<void> openSection(String sectionId) async {
    _logNavigationEvent('section_selected', sectionId: sectionId);
    if (sectionId == 'viajes_detalle') {
      _setSectionContext(sectionId, null);
      _setReferenceFilter(sectionId, 'idpacking', null);
    }
    await _controller.onSectionSelected(sectionId);
  }

  void showModulePicker({required bool isMobile, required bool visible}) {
    if (!_controllerReady) return;
    _controller.showModulePicker(isMobile: isMobile, visible: visible);
  }

  void setContentMode(SectionContentMode mode) {
    _controller.onContentModeChanged(mode);
  }

  Future<void> openTable() async {
    _setContentMode(SectionContentMode.table);
  }

  Future<void> openDetail(TableRowData row) async {
    await _handleRowSelected(row);
  }

  Future<void> openForm({
    SectionFormMode mode = SectionFormMode.create,
    String? sectionId,
    TableRowData? row,
  }) async {
    final targetSectionId = sectionId ?? activeSectionId;
    if (targetSectionId == null) return;
    if (mode == SectionFormMode.create) {
      await _startCreate(targetSectionId);
      return;
    }
    final resolvedRow = row ?? _sectionSelectedRows[targetSectionId];
    if (resolvedRow == null) return;
    _setSelectedRow(targetSectionId, resolvedRow);
    _setSectionFormMode(targetSectionId, mode);
    _setContentMode(SectionContentMode.form);
  }

  Future<void> save([Map<String, String>? values]) async {
    final sectionId = activeSectionId;
    if (sectionId == null) return;
    final payload = values ?? _formDraftValues[sectionId];
    if (payload == null) return;
    await _handleFormSubmit(payload);
  }

  void cancel([String? sectionId]) {
    final targetSectionId = sectionId ?? activeSectionId;
    if (targetSectionId == null) return;
    _handleFormCancel(targetSectionId);
  }

  Future<void> refresh([String? sectionId]) async {
    final targetSectionId = sectionId ?? activeSectionId;
    if (targetSectionId == null) return;
    await _controller.onRefreshSection(targetSectionId);
  }

  Future<void> handleGlobalAction(GlobalNavAction action) async {
    if (action.id == 'logout') {
      await Supabase.instance.client.auth.signOut();
      return;
    }
    if (action.id == 'users') {
      if (!isAdmin) {
        _showMessage('Solo administradores pueden gestionar usuarios.');
        return;
      }
      await _activateSectionFromGlobal('usuarios');
      return;
    }

    final context = _resolveContext();
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Acción "${action.label}" aún no implementada.')),
    );
  }

  Map<String, SectionDataSource> get _sectionDataSources =>
      _controller.sectionDataSources;
  Map<String, TableRowData?> get _sectionSelectedRows =>
      _controller.sectionSelectedRows;
  Map<String, SectionFormMode> get _sectionFormModes =>
      _controller.sectionFormModes;
  Map<String, List<InlineSectionConfig>> get _inlineSectionOverrides =>
      _controller.inlineSectionOverrides;

  void _initialize() {
    _sectionActionController = _ShellSectionActionController(this);
    _inlineDraftService = InlineDraftService(
      moduleRepository: _moduleRepository,
      setState: _setState,
      sectionContextResolver: _sectionContext,
      inlineOverridesResolver: () =>
          _sectionStateController.inlineSectionOverrides,
      sectionFieldsResolver: () => _sectionStateController.sectionFields,
      sectionDataSourceResolver: () =>
          _sectionStateController.sectionDataSources,
      referenceLabelResolver: _resolveReferenceLabel,
      referenceMetadataResolver: _referenceMetadataForValue,
    );
    _sectionFormCoordinator = SectionFormCoordinator(
      sectionStateController: _sectionStateController,
      moduleRepository: _moduleRepository,
      inlineDraftService: _inlineDraftService,
      pedidoInlineService: _pedidoInlineService,
      movimientoService: _movimientoService,
      sectionContextResolver: _sectionContext,
      hasInlineRowsResolver: _hasInlineRows,
    );
    _referenceController = ReferenceOptionsController(
      moduleRepository: _moduleRepository,
      referenceFormLauncher: _launchReferenceForm,
      sectionFieldsResolver: () => _sectionStateController.sectionFields,
      sectionContextResolver: _sectionContext,
      sectionContextWriter: _setSectionContext,
      sectionDataSourceResolver: () =>
          _sectionStateController.sectionDataSources,
      setState: _setState,
      defaultRowBuilder: _sectionFormCoordinator.buildDefaultRow,
      formFieldsBuilder: _buildFormFieldsForSection,
      payloadPreparer: (values, sectionId) =>
          _sectionFormCoordinator.preparePayload(values, sectionId: sectionId),
      showMessage: _showMessage,
      isClientScopedReferenceForm: _isClientScopedReferenceForm,
      referenceDisplayConfigs: _referenceDisplayConfigs,
    );
    _movimientoCoverageService = MovimientoCoverageService(
      moduleRepository: _moduleRepository,
      inlineDraftService: _inlineDraftService,
      sectionContextGetter: _sectionContext,
      sectionContextSetter: _setSectionContext,
      sectionRowResolver: (sectionId) => _sectionSelectedRows[sectionId],
      inlineConfigResolver: _findInlineConfig,
      referenceLoader: _loadReferenceOptionsForSection,
      mountedResolver: () => !_isDisposed,
      setState: _setState,
    );
    _clientContextService = ClientContextService(
      referenceOptionsController: _referenceController,
      draftResolver: (sectionId) => _formDraftValues[sectionId],
    );
    _pedidoPagoCoordinator = PedidoPagoCoordinator(
      pedidoInlineService: _pedidoInlineService,
      inlineDraftService: _inlineDraftService,
    );
    _movimientoInlineCoordinator = MovimientoInlineCoordinator(
      movimientoService: _movimientoService,
      movimientoCoverageService: _movimientoCoverageService,
      inlineDraftService: _inlineDraftService,
      referenceFilterSetter: _setReferenceFilter,
    );
    _controller = ShellController(
      moduleRepository: _moduleRepository,
      sectionStateController: _sectionStateController,
      navigationController: _navigationController,
      inlineDraftService: _inlineDraftService,
      referenceOptionsController: _referenceController,
      sectionFormCoordinator: _sectionFormCoordinator,
      clientContextService: _clientContextService,
      pedidoPagoCoordinator: _pedidoPagoCoordinator,
      movimientoInlineCoordinator: _movimientoInlineCoordinator,
      movimientoCoverageService: _movimientoCoverageService,
    );
    _viajesDetalleService = ViajesDetalleService(
      moduleRepository: _moduleRepository,
      sectionActionController: _sectionActionController,
      sectionDataSourcesResolver: () => _controller.sectionDataSources,
      refreshSection: (sectionId) => _controller.onRefreshSection(sectionId),
      showMessage: _showMessage,
    );
    _viajesProvinciaService = ViajesProvinciaService(
      moduleRepository: _moduleRepository,
      sectionDataSourcesResolver: () => _controller.sectionDataSources,
      refreshSection: (sectionId) => _controller.onRefreshSection(sectionId),
      showMessage: _showMessage,
    );
    _pedidosAdminService = PedidosAdminService(
      moduleRepository: _moduleRepository,
      movimientoCoverageService: _movimientoCoverageService,
      refreshSection: (sectionId) => _controller.onRefreshSection(sectionId),
      showMessage: _showMessage,
      syncSelectedPedidoRow: _syncSelectedPedidoRow,
    );
    _tableActionBuilder = SectionTableActionBuilder(
      viajesDetalleService: _viajesDetalleService,
      viajesProvinciaService: _viajesProvinciaService,
      pedidosAdminService: _pedidosAdminService,
      showMessage: _showMessage,
    );
    _controllerListener = _emit;
    _controller.addListener(_controllerListener);
    _controllerReady = true;
    _inlineFlowService = InlineFlowService(
      moduleRepository: _moduleRepository,
      sectionStateController: _sectionStateController,
      inlineDraftService: _inlineDraftService,
      sectionFormCoordinator: _sectionFormCoordinator,
      clientContextService: _clientContextService,
      pedidoPagoCoordinator: _pedidoPagoCoordinator,
      movimientoInlineCoordinator: _movimientoInlineCoordinator,
      movimientoCoverageService: _movimientoCoverageService,
      pedidoInlineService: _pedidoInlineService,
      movimientoService: _movimientoService,
      referenceFilterSetter: _setReferenceFilter,
      formDraftValues: _formDraftValues,
      sectionContextResolver: _sectionContext,
      sectionContextWriter: _setSectionContext,
      hasInlineRowsResolver: _hasInlineRows,
      shouldLoadInlineSections: _shouldLoadInlineSections,
      loadReferenceOptionsForSection: _loadReferenceOptionsForSection,
      contextProvider: _contextProvider,
      showMessage: _showMessage,
      stateSetter: _setState,
      mountedResolver: () => !_isDisposed,
      activeModuleResolver: () => activeModule,
      activeSectionResolver: () => activeSectionId,
      globalActionsResolver: () => visibleGlobalActions,
      onSectionSelected: openSection,
      onGlobalAction: handleGlobalAction,
      sectionActionController: _sectionActionController,
      pushNavigationSnapshot: _pushNavigationSnapshot,
      sectionExistsResolver: _sectionExists,
      moduleSectionResolver: (sectionId) => _findModuleSectionById(sectionId),
      sectionRefresher: (sectionId) => _controller.onRefreshSection(sectionId),
      movimientoDraftSanitizer: _sanitizeMovimientoDraftValues,
    );
    _tableConfigBuilder = TableConfigBuilder(
      sectionStateController: _sectionStateController,
      loadingSectionIdResolver: () => _controller.loadingSectionId,
      onRefresh: (sectionId) => _controller.onRefreshSection(sectionId),
      onRowSelected: (row) async => _handleRowSelected(row),
      onBulkDelete: (sectionId, rows) => _handleBulkDelete(sectionId, rows),
      onStartCreate: _startCreate,
      actionController: _sectionActionController,
      columnsBuilder: _buildColumns,
    );
    _detailConfigBuilder = DetailConfigBuilder(
      sectionStateController: _sectionStateController,
      inlineSectionBuilder:
          (
            sectionId,
            row, {
            required bool forForm,
            SectionFormMode? formMode,
          }) => _inlineFlowService.buildInlineTablesWithContext(
            sectionId,
            row,
            forForm: forForm,
            formMode: formMode,
          ),
      columnLabelFormatter: formatColumnLabel,
      detailValueFormatter: formatDetailValue,
      handleDetailBack: _handleDetailBack,
      actionController: _sectionActionController,
    );
    _formConfigBuilder = FormConfigBuilder(
      sectionStateController: _sectionStateController,
      inlineLoader: (sectionId, row) =>
          _inlineDraftService.loadInlineSectionsForRow(sectionId, row),
      inlineSectionBuilder:
          (
            sectionId,
            row, {
            required bool forForm,
            SectionFormMode? formMode,
          }) => _inlineFlowService.buildInlineTablesWithContext(
            sectionId,
            row,
            forForm: forForm,
            formMode: formMode,
          ),
      referenceOptionsResolver: (sectionId, fieldId) =>
          _referenceController.optionsForField(sectionId, fieldId),
      optionLabelFormatter: formatOptionLabel,
      fieldTypeResolver: _resolveFieldType,
      dateFormatter: formatDateTimeString,
      referenceHelperResolver: (sectionId, fieldId, currentValue) =>
          _referenceController.referenceHelperText(
            sectionId,
            fieldId,
            currentValue,
          ),
      referenceAddHandler: _handleReferenceAdd,
      columnsBuilder: _buildColumns,
      columnLabelFormatter: formatColumnLabel,
      cancelHandler: (sectionId) => () => _handleFormCancel(sectionId),
      changedHandler: (sectionId, values) =>
          _handleFormChanged(sectionId, values),
      submitHandler: (values) => _handleFormSubmit(values),
      referenceLoader: _loadReferenceOptionsForSection,
      isMovementSection: _isMovementSection,
      movementContextPreparer: (sectionId, row) => _movimientoCoverageService
          .prepareMovementDetailContext(sectionId, row),
      shouldLoadInlineSections: _shouldLoadInlineSections,
      formDraftValuesResolver: () => _formDraftValues,
    );
    _inlineFlowService.attachBuilders(
      formBuilder: _formConfigBuilder,
      detailBuilder: _detailConfigBuilder,
    );
  }

  BuildContext? _resolveContext() {
    if (_isDisposed) return null;
    final context = _contextProvider();
    if (!context.mounted) return null;
    return context;
  }

  void _setState(VoidCallback fn) {
    fn();
    if (_isDisposed) return;
    _emit();
  }

  void _emit() {
    if (_isDisposed) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      if (_controllerRebuildPending) return;
      _controllerRebuildPending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controllerRebuildPending = false;
        if (_isDisposed) return;
        notifyListeners();
      });
      return;
    }
    notifyListeners();
  }

  void _showMessage(String message) {
    final context = _resolveContext();
    if (context == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _logNavigationEvent(
    String label, {
    ModuleConfig? module,
    String? sectionId,
  }) {
    final currentModule = module ?? activeModule;
    final currentSection = sectionId ?? activeSectionId;
    debugPrint(
      '[nav] $label module=${currentModule?.id ?? '-'}'
      '(${currentModule?.name ?? '-'}) section=${currentSection ?? '-'}',
    );
  }

  Map<String, dynamic> _sectionContext(String sectionId) {
    if (!_controllerReady) return const {};
    return _controller.sectionContext(sectionId);
  }

  void _setSectionContext(
    String sectionId,
    Map<String, dynamic>? contextValues,
  ) {
    if (!_controllerReady) return;
    _controller.setSectionContext(sectionId, contextValues);
  }

  void _setReferenceFilter(
    String sectionId,
    String fieldId,
    Map<String, dynamic>? filter,
  ) {
    _referenceController.setReferenceFilter(sectionId, fieldId, filter);
  }

  Map<String, dynamic>? _referenceMetadataForValue(
    String sectionId,
    String fieldId,
    String value,
  ) {
    return _referenceController.referenceMetadataForValue(
      sectionId,
      fieldId,
      value,
    );
  }

  bool _isMovementSection(String sectionId) =>
      _movimientoInlineCoordinator.isMovementSection(sectionId);

  bool _isClientScopedReferenceForm(String sectionId) {
    return sectionId == 'direccion_form' ||
        sectionId == 'direccion_provincia_form' ||
        sectionId == 'numrecibe_form';
  }

  InlineSectionConfig? _findInlineConfig(String sectionId, String inlineId) {
    final overrides = _inlineSectionOverrides[sectionId];
    if (overrides == null) return null;
    for (final config in overrides) {
      if (config.id == inlineId) return config;
    }
    return null;
  }

  ModuleSection? _findModuleSectionById(String sectionId) {
    if (!_controllerReady) return null;
    return _controller.findModuleSectionById(sectionId);
  }

  void _pushNavigationSnapshot() {
    if (!_controllerReady) return;
    final module = activeModule;
    final sectionId = activeSectionId;
    if (module == null || sectionId == null) return;
    final currentRow = _sectionSelectedRows[sectionId];
    final snapshot = NavigationSnapshot(
      moduleId: module.id,
      sectionId: sectionId,
      contentMode: activeContentMode,
      selectedRow: currentRow == null
          ? null
          : Map<String, dynamic>.from(currentRow),
    );
    _controller.pushSnapshot(snapshot);
  }

  void _handleDetailBack() {
    if (!_controllerReady) {
      _setContentMode(SectionContentMode.table);
      return;
    }
    final snapshot = _controller.popSnapshot();
    if (snapshot == null) {
      final sectionId = activeSectionId;
      _setContentMode(SectionContentMode.table);
      if (sectionId != null) {
        unawaited(_controller.onRefreshSection(sectionId));
      }
      return;
    }
    final module = _controller.findModuleById(snapshot.moduleId);
    _setState(() {
      if (module != null) {
        _navigationController.setActiveModule(module);
      }
      _navigationController.setActiveSectionId(snapshot.sectionId);
      if (snapshot.selectedRow != null) {
        _sectionSelectedRows[snapshot.sectionId] = Map<String, dynamic>.from(
          snapshot.selectedRow!,
        );
      }
      _controller.onContentModeChanged(snapshot.contentMode);
    });
    unawaited(_controller.onRefreshSection(snapshot.sectionId));
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

  Future<Map<String, String>?> _launchReferenceForm(
    ReferenceFormRequest request,
  ) async {
    final context = _resolveContext();
    if (context == null) return null;
    return Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (routeContext) {
          final config = FormViewConfig(
            title: request.title,
            fields: request.fields,
            onSubmit: (values) {
              if (!_ensureSectionValidation(
                request.sectionId,
                values,
                feedbackContext: routeContext,
              )) {
                return;
              }
              if (!routeContext.mounted) return;
              Navigator.of(routeContext).pop(values);
            },
            onCancel: () => Navigator.of(routeContext).pop(),
            saveLabel: request.saveLabel,
            cancelLabel: request.cancelLabel,
          );
          return ReferenceFormPage(title: request.title, config: config);
        },
      ),
    );
  }

  ModuleSection? _currentSection() {
    final module = activeModule;
    final sectionId = activeSectionId;
    if (module == null || sectionId == null) return null;
    for (final section in module.sections) {
      if (section.id == sectionId) return section;
    }
    return null;
  }

  TableViewConfig? _buildTableConfig(ModuleSection? section) {
    final baseConfig = _tableConfigBuilder.build(section);
    if (baseConfig == null) return null;
    return _tableActionBuilder.build(section, baseConfig);
  }

  DetailViewConfig? _buildDetailConfig(ModuleSection? section) {
    final config = _detailConfigBuilder.build(section);
    if (config == null) return null;
    if (section?.id == 'pedidos_tabla') {
      final acciones = _pedidosAdminService.buildDetailActions(
        _sectionSelectedRows['pedidos_tabla'],
      );
      if (acciones.isNotEmpty) {
        return config.copyWith(
          moreActions: [...config.moreActions, ...acciones],
        );
      }
    }
    return config;
  }

  FormViewConfig? _buildFormConfig(ModuleSection? section) {
    return _formConfigBuilder.buildForSection(section);
  }

  List<FormFieldConfig>? _buildFormFieldsForSection(
    String sectionId,
    Map<String, dynamic> row,
    SectionFormMode mode,
  ) {
    return _formConfigBuilder.buildFields(sectionId, row, mode);
  }

  FormFieldType _resolveFieldType(SectionField field) {
    if (field.widgetType == 'reference' || field.staticOptions.isNotEmpty) {
      return FormFieldType.dropdown;
    }
    final widgetType = field.widgetType?.toLowerCase();
    if (widgetType == 'datetime') {
      return FormFieldType.dateTime;
    }
    if (widgetType == 'number') {
      return FormFieldType.number;
    }
    final dataType = field.dataType?.toLowerCase() ?? '';
    if (dataType.contains('timestamp') ||
        dataType.contains('date') ||
        isDateFieldKey(field.id)) {
      return FormFieldType.dateTime;
    }
    if (dataType.contains('int') ||
        dataType.contains('numeric') ||
        dataType.contains('decimal') ||
        dataType.contains('double')) {
      return FormFieldType.number;
    }
    return FormFieldType.text;
  }

  Future<void> _handleRowSelected(TableRowData row) async {
    await _controller.onRowSelected(row);
    if (activeSectionId == 'viajes_detalle') {
      _applyViajesDetalleContextFromRow(row);
    }
  }

  Future<void> _loadReferenceOptionsForSection(String sectionId) async {
    await _referenceController.loadReferenceOptionsForSection(sectionId);
  }

  Future<void> _forceLoadReferenceOptionsForSection(String sectionId) async {
    await _referenceController.loadReferenceOptionsForSection(
      sectionId,
      forceReload: true,
    );
  }

  bool _shouldLoadInlineSections(String sectionId, Map<String, dynamic> row) {
    return _controller.shouldLoadInlineSections(sectionId, row);
  }

  // TODO(codex): Extract pedido/movimiento specific rules from this method into
  // dedicated services so ShellPage only orchestrates inline flows.
  String? _resolveReferenceLabel(
    String sectionId,
    SectionField field,
    String value,
  ) {
    return _referenceController.resolveReferenceLabel(sectionId, field, value);
  }

  bool _ensureBaseAssignmentForSection(String sectionId) {
    if (sectionId != 'viajes_bases' &&
        sectionId != 'comunicaciones_base') {
      return true;
    }
    if (hasAssignedBase) return true;
    _showMessage(
      'Tu usuario no tiene una base asignada. Pide a un administrador que la configure para continuar.',
    );
    return false;
  }

  void _prefillViajesBaseDefaults(Map<String, dynamic> defaults) {
    if (!isBaseUser || !hasAssignedBase) return;
    final options = _referenceController.optionsForField(
      'viajes_bases',
      'idbase',
    );
    if (options.isEmpty) return;
    defaults['idbase'] ??= options.first.value;
  }

  void _prefillComunicacionesBaseDefaults(Map<String, dynamic> defaults) {
    if (!isBaseUser || !hasAssignedBase) return;
    final baseId = userProfile?.baseId?.trim();
    if (baseId == null || baseId.isEmpty) return;
    defaults['idbase'] ??= baseId;
  }

  Future<void> _startCreate([String? targetSectionId]) async {
    final sectionId = targetSectionId ?? activeSectionId;
    if (sectionId == null) return;
    final dataSource = _sectionDataSources[sectionId];
    if (dataSource == null || dataSource.formRelation.isEmpty) return;
    if (!_ensureBaseAssignmentForSection(sectionId)) return;
    if (sectionId == 'viajes_provincia') {
      await _forceLoadReferenceOptionsForSection(sectionId);
    } else {
      await _loadReferenceOptionsForSection(sectionId);
    }
    if (sectionId == 'viajes_detalle') {
      _setSectionContext('viajes_detalle', null);
      _setReferenceFilter('viajes_detalle', 'idpacking', null);
    }
    final defaults = _sectionFormCoordinator.buildDefaultRow(sectionId);
    if (sectionId == 'viajes_bases') {
      _prefillViajesBaseDefaults(defaults);
    }
    if (sectionId == 'comunicaciones_base') {
      _prefillComunicacionesBaseDefaults(defaults);
    }
    _setState(() {
      _sectionStateController.setFormMode(sectionId, SectionFormMode.create);
      _sectionStateController.setSelectedRow(sectionId, defaults);
      if (_controllerReady) {
        _navigationController.setActiveSectionId(sectionId);
        _controller.onContentModeChanged(SectionContentMode.form);
      }
      _formDraftValues[sectionId] = const {};
      _inlineDraftService.clearPendingRows(sectionId);
    });
    AppLogger.event(
      'section_create_started',
      payload: {'sectionId': sectionId},
    );
  }

  Future<void> _switchToSection(String sectionId) async {
    await _controller.onSectionSelected(sectionId);
  }

  bool _sectionExists(String sectionId) {
    if (!_controllerReady) return false;
    return _controller.sectionExists(sectionId);
  }

  ModuleConfig? _moduleForSection(String sectionId) {
    if (!_controllerReady) return null;
    return _controller.moduleForSection(sectionId);
  }

  void _setSelectedRow(String sectionId, TableRowData row) {
    _setState(() {
      _sectionStateController.setSelectedRow(sectionId, row);
      _inlineDraftService.clearPendingRows(sectionId);
    });
    _registerReferenceOptionsFromRow(sectionId, row);
  }

  void _setSectionFormMode(String sectionId, SectionFormMode mode) {
    _setState(() {
      _sectionStateController.setFormMode(sectionId, mode);
    });
  }

  void _registerReferenceOptionsFromRow(
    String sectionId,
    TableRowData row,
  ) {
    final configs = _rowReferenceOptionConfigs[sectionId];
    if (configs == null || configs.isEmpty) return;
    final fields = _sectionStateController.sectionFields[sectionId];
    if (fields == null) return;
    for (final config in configs) {
      final value = row[config.fieldId]?.toString().trim();
      if (value == null || value.isEmpty) continue;
      SectionField? fieldMeta;
      for (final field in fields) {
        if (field.id == config.fieldId) {
          fieldMeta = field;
          break;
        }
      }
      if (fieldMeta == null) continue;
      final existingLabel = _referenceController.resolveReferenceLabel(
        sectionId,
        fieldMeta,
        value,
      );
      if (existingLabel != null) continue;
      final rawLabel = row[config.labelColumn]?.toString().trim();
      final label = rawLabel == null || rawLabel.isEmpty ? value : rawLabel;
      final metadata = <String, dynamic>{};
      config.metadataColumns.forEach((metaKey, columnKey) {
        final raw = row[columnKey];
        if (raw == null) return;
        final text = raw.toString();
        if (text.trim().isEmpty || text == 'null') return;
        metadata[metaKey] = raw;
      });
      _referenceController.addOption(
        sectionId,
        config.fieldId,
        ReferenceOption(
          value: value,
          label: label,
          metadata: metadata,
        ),
      );
    }
  }

  void _setContentMode(SectionContentMode mode) {
    _controller.onContentModeChanged(mode);
  }

  void _handleFormCancel(String sectionId) {
    _inlineDraftService.clearPendingRows(sectionId);
    if (sectionId == 'viajes_incidentes') {
      final incidenteId =
          _sectionSelectedRows['viajes_incidentes']?['id']?.toString();
      unawaited(
        _viajesDetalleService.cancelarIncidentePendiente(incidenteId),
      );
    }
    _controller.onContentModeChanged(SectionContentMode.table);
  }

  void _handleFormChanged(String sectionId, Map<String, String> values) {
    final previousDraft = _formDraftValues[sectionId];
    final programmaticChange = consumeFormProgrammaticChangeFlag(values);
    final normalized = _maybeResetMovimientoFields(
      sectionId,
      values,
      programmaticChange: programmaticChange,
    );
    final sanitizedForLog =
        identical(normalized, values) ? null : normalized;
    if (_shouldLogMovimientoDrafts(sectionId)) {
      debugPrint(
        '[drafts] section=$sectionId previous=$previousDraft raw=$values sanitized=$sanitizedForLog',
      );
    }
    _formDraftValues[sectionId] = normalized;
    if (sectionId == 'viajes_detalle') {
      _updateViajesDetalleContextFromMovimiento(normalized);
    }
    final previousBase = previousDraft?['idbase'] ?? '';
    final currentBase = normalized['idbase'] ?? '';
    if (previousBase != currentBase && currentBase.isNotEmpty) {
      unawaited(
        _inlineFlowService.validateMovimientoBaseSelection(sectionId),
      );
    }
  }

  Map<String, String> _maybeResetMovimientoFields(
    String sectionId,
    Map<String, String> values, {
    bool programmaticChange = false,
  }) {
    final shouldLog = _shouldLogMovimientoDrafts(sectionId);
    final sanitized = _sanitizeMovimientoDraftValues(
      sectionId,
      values,
      programmaticChange: programmaticChange,
    );
    if (!shouldLog) {
      return sanitized ?? values;
    }
    final isProvincia = (values['es_provincia'] ?? '').toLowerCase() == 'true';
    debugPrint(
      '[drafts-reset] section=$sectionId esProvincia=$isProvincia before=$values',
    );
    if (sanitized == null) {
      debugPrint('[drafts-reset] section=$sectionId no field reset needed');
      return values;
    }
    debugPrint('[drafts-reset] section=$sectionId after reset=$sanitized');
    final currentRow = _sectionStateController.sectionSelectedRows[sectionId];
    if (currentRow != null) {
      final adjustedRow = Map<String, dynamic>.from(currentRow);
      for (final entry in sanitized.entries) {
        adjustedRow[entry.key] = entry.value;
      }
      _setState(() {
        _sectionStateController.setSelectedRow(sectionId, adjustedRow);
      });
      if (shouldLog) {
        debugPrint(
          '[drafts-reset] section=$sectionId applied to selectedRow=$adjustedRow',
        );
      }
    } else {
      _setState(() {});
      if (shouldLog) {
        debugPrint(
          '[drafts-reset] section=$sectionId no selected row to adjust',
        );
      }
    }
    return sanitized;
  }

  void _updateViajesDetalleContextFromMovimiento(
    Map<String, String> values,
  ) {
    final movimientoId = values['idmovimiento']?.trim() ?? '';
    if (movimientoId.isEmpty) {
      _setSectionContext('viajes_detalle', null);
      _setReferenceFilter('viajes_detalle', 'idpacking', null);
      unawaited(_loadReferenceOptionsForSection('viajes_detalle'));
      return;
    }
    final metadata = _referenceMetadataForValue(
      'viajes_detalle',
      'idmovimiento',
      movimientoId,
    );
    final baseId = metadata?['idbase']?.toString().trim();
    if (baseId == null || baseId.isEmpty) {
      _setSectionContext('viajes_detalle', null);
      _setReferenceFilter('viajes_detalle', 'idpacking', null);
      unawaited(_loadReferenceOptionsForSection('viajes_detalle'));
      return;
    }
    _setSectionContext('viajes_detalle', {'idbase': baseId});
    _setReferenceFilter('viajes_detalle', 'idpacking', {'idbase': baseId});
    unawaited(_loadReferenceOptionsForSection('viajes_detalle'));
  }

  void _applyViajesDetalleContextFromRow(TableRowData row) {
    final candidates = <String?>[
      row['base_id']?.toString(),
      row['idbase']?.toString(),
    ];
    String? baseId;
    for (final candidate in candidates) {
      final cleaned = candidate?.trim();
      if (cleaned != null && cleaned.isNotEmpty) {
        baseId = cleaned;
        break;
      }
    }
    if (baseId == null || baseId.isEmpty) {
      _setSectionContext('viajes_detalle', null);
      _setReferenceFilter('viajes_detalle', 'idpacking', null);
    } else {
      _setSectionContext('viajes_detalle', {'idbase': baseId});
      _setReferenceFilter('viajes_detalle', 'idpacking', {'idbase': baseId});
    }
    unawaited(_loadReferenceOptionsForSection('viajes_detalle'));
  }

  Map<String, String>? _sanitizeMovimientoDraftValues(
    String sectionId,
    Map<String, String> values, {
    bool programmaticChange = false,
  }) {
    if (sectionId != 'movimientos' && sectionId != 'pedidos_movimientos') {
      return null;
    }
    if (programmaticChange) {
      return null;
    }
    final isProvincia = (values['es_provincia'] ?? '').toLowerCase() == 'true';
    final updated = Map<String, String>.from(values);
    bool didChange = false;
    if (isProvincia) {
      for (final field in [
        kMovDestinoLimaDireccionField,
        kMovDestinoLimaContactoField,
      ]) {
        if ((updated[field] ?? '').isNotEmpty) {
          updated[field] = '';
          didChange = true;
        }
      }
    } else {
      if ((updated[kMovDestinoProvinciaDireccionField] ?? '').isNotEmpty) {
        updated[kMovDestinoProvinciaDireccionField] = '';
        didChange = true;
      }
    }
    return didChange ? updated : null;
  }

  bool _shouldLogMovimientoDrafts(String sectionId) {
    return sectionId == 'movimientos' || sectionId == 'pedidos_movimientos';
  }

  bool _ensureSectionValidation(
    String sectionId,
    Map<String, String> values, {
    BuildContext? feedbackContext,
  }) {
    final error = _sectionFormCoordinator.ensureSectionValidation(
      sectionId,
      values,
    );
    if (error == null) return true;
    if (feedbackContext != null) {
      if (feedbackContext.mounted) {
        ScaffoldMessenger.of(
          feedbackContext,
        ).showSnackBar(SnackBar(content: Text(error)));
      } else {
        _showMessage(error);
      }
    } else {
      _showMessage(error);
    }
    return false;
  }

  bool _hasInlineRows(String sectionId, String inlineId) {
    return _controller.hasInlineRows(sectionId, inlineId);
  }

  Future<void> _handleFormSubmit(Map<String, String> data) async {
    final sectionId = activeSectionId;
    if (sectionId == null) return;
    final dataSource = _sectionDataSources[sectionId];
    if (dataSource == null) return;
    if (!_ensureSectionValidation(sectionId, data)) return;

    final mode = _sectionFormModes[sectionId] ?? SectionFormMode.create;
    final payload = _sectionFormCoordinator.preparePayload(
      data,
      sectionId: sectionId,
    );
    if (sectionId == 'pedidos_tabla') {
      final normalized = date_time_utils.normalizeToUtcIsoString(
        payload['registrado_at'],
      );
      payload['registrado_at'] =
          normalized ?? date_time_utils.normalizeToUtcIsoString(DateTime.now());
    }
    debugPrint('[form-submit] section=$sectionId payload=$payload');

    try {
      Map<String, dynamic> savedRow;
      if (mode == SectionFormMode.create) {
        savedRow = await _moduleRepository.insertRow(dataSource, payload);
        final rowId = savedRow['id'];
        if (rowId != null) {
          final persisted = await _inlineDraftService.persistPendingInlineRows(
            parentSectionId: sectionId,
            parentRowId: rowId,
          );
          if (persisted) {
            final currentRow = _sectionSelectedRows[sectionId];
            if (currentRow != null) {
              await _inlineDraftService.loadInlineSectionsForRow(
                sectionId,
                currentRow,
              );
            }
          }
          if (sectionId == 'compras' || sectionId == 'compras_movimientos') {
            final detalleCerrado =
                savedRow['detalle_cerrado']?.toString().toLowerCase().trim() ==
                    'true';
            if (!detalleCerrado) {
              savedRow = await _moduleRepository.updateRow(
                dataSource,
                rowId,
                {'detalle_cerrado': true},
              );
            }
          }
        }
      } else {
        final currentId = _sectionSelectedRows[sectionId]?['id'] ?? data['id'];
        if (currentId == null) {
          throw StateError('No se encontró el ID para actualizar.');
        }
        savedRow = await _moduleRepository.updateRow(
          dataSource,
          currentId,
          payload,
        );
        final rowId = savedRow['id'] ?? currentId;
        if (rowId != null) {
          await _inlineDraftService.persistPendingInlineRows(
            parentSectionId: sectionId,
            parentRowId: rowId,
          );
          if (sectionId == 'compras' || sectionId == 'compras_movimientos') {
            final detalleCerrado =
                savedRow['detalle_cerrado']?.toString().toLowerCase().trim() ==
                    'true';
            if (!detalleCerrado) {
              savedRow = await _moduleRepository.updateRow(
                dataSource,
                rowId,
                {'detalle_cerrado': true},
              );
            }
          }
        }
        await _inlineDraftService.loadInlineSectionsForRow(sectionId, savedRow);
      }
      if (sectionId == 'viajes_incidentes') {
        _viajesDetalleService.marcarIncidenteGuardado(
          savedRow['id']?.toString(),
        );
      }
      if (_isMovementSection(sectionId)) {
        final pedidoId = _movimientoCoverageService.resolvePedidoIdFromMovement(
          sectionId,
          savedRow,
        );
        if (pedidoId != null) {
          _movimientoCoverageService.invalidateCoverage(pedidoId);
        }
        final compraId = _movimientoCoverageService.resolveCompraIdFromMovement(
          sectionId,
          savedRow,
        );
        if (compraId != null) {
          _movimientoCoverageService.invalidateCoverage(
            compraId,
            type: MovementDocumentType.compra,
          );
        }
      } else if (sectionId == 'pedidos_tabla') {
        final pedidoId = savedRow['id']?.toString();
        _movimientoCoverageService.invalidateCoverage(pedidoId);
      }

      await _controller.onRefreshSection(sectionId);
      if (sectionId == 'viajes_provincia') {
        unawaited(_forceLoadReferenceOptionsForSection(sectionId));
      }
      _setState(() {
        _sectionSelectedRows[sectionId] = savedRow;
        _sectionFormModes[sectionId] = SectionFormMode.edit;
      });
      _controller.onContentModeChanged(SectionContentMode.table);
      _showMessage(
        mode == SectionFormMode.create
            ? 'Registro creado.'
            : 'Registro actualizado.',
      );
    } catch (error) {
      _showMessage('No se pudo guardar: $error');
    }
  }

  Future<ReferenceOption?> _handleReferenceAdd(
    SectionField field,
    String parentSectionId,
  ) async {
    return _referenceController.handleReferenceAdd(
      field: field,
      parentSectionId: parentSectionId,
    );
  }

  Future<void> _handleBulkDelete(
    String sectionId,
    List<TableRowData> rows,
  ) async {
    if (rows.isEmpty) return;
    final context = _resolveContext();
    if (context == null) return;
    const actionLabel = 'Eliminar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionLabel registros'),
        content: Text(
          rows.length == 1
              ? '¿$actionLabel el registro seleccionado?'
              : '¿$actionLabel ${rows.length} registros seleccionados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _controller.onBulkDelete(sectionId, rows);
      _showMessage(
        rows.length == 1
            ? 'Registro eliminado.'
            : '${rows.length} registros eliminados.',
      );
    } catch (error) {
      _showMessage('No se pudieron eliminar: $error');
    }
  }

  Future<void> _handleBulkCancel(
    String sectionId,
    List<TableRowData> rows,
  ) async {
    if (rows.isEmpty) return;
    final context = _resolveContext();
    if (context == null) return;
    const actionLabel = 'Cancelar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionLabel registros'),
        content: Text(
          rows.length == 1
              ? '¿$actionLabel el registro seleccionado?'
              : '¿$actionLabel ${rows.length} registros seleccionados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final dataSource = _sectionDataSources[sectionId];
    if (dataSource == null) return;
    final nowIso = date_time_utils.currentUtcIsoString();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    try {
      var canceledCount = 0;
      for (final row in rows) {
        final estadoRaw = row['estado_codigo'] ?? row['estado'];
        final estado = estadoRaw?.toString().toLowerCase().trim();
        if (estado == 'cancelado') continue;
        final id = row['id'];
        if (id == null) continue;
        await _moduleRepository.updateRow(dataSource, id, {
          'estado': 'cancelado',
          'editado_at': nowIso,
          if (userId != null) 'editado_por': userId,
        });
        canceledCount += 1;
      }
      await _controller.onRefreshSection(sectionId);
      if (canceledCount == 0) {
        _showMessage('No hay registros para cancelar.');
      } else {
        _showMessage(
          canceledCount == 1
              ? 'Registro cancelado.'
              : '$canceledCount registros cancelados.',
        );
      }
    } catch (error) {
      _showMessage('No se pudieron cancelar: $error');
    }
  }

  void _syncSelectedPedidoRow() {
    final selected = _sectionSelectedRows['pedidos_tabla'];
    if (selected == null) return;
    final selectedId = selected['id'];
    if (selectedId == null) return;
    final rows = _controller.sectionRows['pedidos_tabla'];
    if (rows == null || rows.isEmpty) return;
    for (final row in rows) {
      if (row['id'] == selectedId) {
        _setState(
          () => _sectionStateController.setSelectedRow(
            'pedidos_tabla',
            Map<String, dynamic>.from(row),
          ),
        );
        break;
      }
    }
  }

  Future<void> _activateSectionFromGlobal(String sectionId) async {
    final module = _moduleForSection(sectionId);
    if (module == null) {
      _showMessage('No se encontró la vista solicitada.');
      return;
    }
    await _controller.onModuleSelected(module, fromMobile: false);
    await _controller.onSectionSelected(sectionId);
    _controller.showModulePicker(isMobile: true, visible: false);
    _controller.showModulePicker(isMobile: false, visible: false);
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
}

class _ShellSectionActionController implements SectionActionController {
  const _ShellSectionActionController(this._viewModel);

  final ShellViewModel _viewModel;

  @override
  Future<void> showTable(String sectionId) async {
    AppLogger.event('action_show_table', payload: {'sectionId': sectionId});
    await _viewModel._switchToSection(sectionId);
    _viewModel._setContentMode(SectionContentMode.table);
  }

  @override
  Future<void> showCurrentTable() async {
    final sectionId = _viewModel.activeSectionId;
    if (sectionId == null) return;
    await showTable(sectionId);
  }

  @override
  Future<void> showDetail(String sectionId, TableRowData row) async {
    AppLogger.event(
      'action_show_detail',
      payload: {'sectionId': sectionId, 'rowId': _viewModel._rowIdentifier(row)},
    );
    await _viewModel._switchToSection(sectionId);
    _viewModel._setSelectedRow(sectionId, row);
    _viewModel._inlineDraftService.loadInlineSectionsForRow(sectionId, row);
    _viewModel._setContentMode(SectionContentMode.detail);
  }

  @override
  Future<void> showCurrentDetail(TableRowData row) async {
    final sectionId = _viewModel.activeSectionId;
    if (sectionId == null) return;
    await showDetail(sectionId, row);
  }

  @override
  Future<void> editRow(String sectionId, TableRowData row) async {
    AppLogger.event(
      'action_edit_row',
      payload: {'sectionId': sectionId, 'rowId': _viewModel._rowIdentifier(row)},
    );
    await _viewModel._switchToSection(sectionId);
    _viewModel._setSelectedRow(sectionId, row);
    _viewModel._setSectionFormMode(sectionId, SectionFormMode.edit);
    _viewModel._setContentMode(SectionContentMode.form);
  }

  @override
  Future<void> editCurrentRow(TableRowData row) async {
    final sectionId = _viewModel.activeSectionId;
    if (sectionId == null) return;
    await editRow(sectionId, row);
  }

  @override
  Future<void> createRow(String sectionId) async {
    AppLogger.event('action_create_row', payload: {'sectionId': sectionId});
    await _viewModel._switchToSection(sectionId);
    await _viewModel._startCreate(sectionId);
  }

  @override
  Future<void> createRowInCurrentSection() async {
    final sectionId = _viewModel.activeSectionId;
    if (sectionId == null) return;
    await createRow(sectionId);
  }

  @override
  Future<void> cancelRows(String sectionId, List<TableRowData> rows) async {
    await _viewModel._handleBulkCancel(sectionId, rows);
  }
}
