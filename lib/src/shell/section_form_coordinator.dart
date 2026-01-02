import 'package:erp_app/src/domains/movimientos/movimiento_service.dart';
import 'package:erp_app/src/domains/pedidos/pedido_inline_service.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shared/utils/template_formatters.dart';
import 'package:erp_app/src/shared/utils/date_time_utils.dart'
    as date_time_utils;
import 'package:erp_app/src/shell/services/inline_draft_service.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';

/// Resultado de la creación de un borrador de formulario.
class DraftCreationResult {
  DraftCreationResult.success(this.savedRow)
    : isSuccess = true,
      errorMessage = null;

  DraftCreationResult.failure(this.errorMessage)
    : isSuccess = false,
      savedRow = null;

  final bool isSuccess;
  final TableRowData? savedRow;
  final String? errorMessage;
}

/// Coordina la preparación de payloads y validaciones de formularios de
/// secciones para mantener la lógica fuera de la capa de UI.
class SectionFormCoordinator {
  SectionFormCoordinator({
    required SectionStateController sectionStateController,
    required ModuleRepository moduleRepository,
    required InlineDraftService inlineDraftService,
    required PedidoInlineService pedidoInlineService,
    required MovimientoService movimientoService,
    required Map<String, dynamic> Function(String sectionId)
    sectionContextResolver,
    required bool Function(String sectionId, String inlineId)
    hasInlineRowsResolver,
  }) : _sectionStateController = sectionStateController,
       _moduleRepository = moduleRepository,
       _inlineDraftService = inlineDraftService,
       _pedidoInlineService = pedidoInlineService,
       _movimientoService = movimientoService,
       _sectionContextResolver = sectionContextResolver,
       _hasInlineRowsResolver = hasInlineRowsResolver;

  final SectionStateController _sectionStateController;
  final ModuleRepository _moduleRepository;
  final InlineDraftService _inlineDraftService;
  final PedidoInlineService _pedidoInlineService;
  final MovimientoService _movimientoService;
  final Map<String, dynamic> Function(String sectionId) _sectionContextResolver;
  final bool Function(String sectionId, String inlineId) _hasInlineRowsResolver;

  Map<String, dynamic> buildDefaultRow(String sectionId) {
    final defaults = <String, dynamic>{};
    final fields = _sectionStateController.sectionFields[sectionId];
    if (fields == null) return defaults;
    for (final field in fields) {
      final defaultValue = field.defaultValue;
      if (defaultValue == null) continue;
      if (defaultValue.toLowerCase() == 'now') {
        defaults[field.id] = date_time_utils.currentLocalIsoString();
      } else {
        defaults[field.id] = defaultValue;
      }
    }
    if (sectionId == 'pedidos_tabla') {
      defaults['registrado_at'] ??= date_time_utils.currentLocalIsoString();
    }
    return defaults;
  }

  bool areDraftRequirementsMet(String sectionId, Map<String, String> values) {
    final fields = _sectionStateController.sectionFields[sectionId];
    if (fields == null) return true;
    for (final field in fields) {
      if (!field.required || !field.visible) continue;
      if (field.visibleWhenField != null) {
        final shouldBeVisible = _matchesVisibilityCondition(
          field,
          values: values,
        );
        if (!shouldBeVisible) continue;
      }
      final value = values[field.id]?.trim() ?? '';
      if (value.isEmpty) {
        return false;
      }
    }
    return true;
  }

  DraftCreationResult validateDraftReadiness(
    String sectionId,
    Map<String, String> values,
  ) {
    if (areDraftRequirementsMet(sectionId, values)) {
      return DraftCreationResult.success(null);
    }
    return DraftCreationResult.failure(
      'Completa los campos obligatorios para continuar.',
    );
  }

  Future<DraftCreationResult> createDraftRow(
    String sectionId,
    Map<String, String> values,
  ) async {
    final readiness = validateDraftReadiness(sectionId, values);
    if (!readiness.isSuccess) return readiness;
    final dataSource = _sectionStateController.sectionDataSources[sectionId];
    if (dataSource == null) {
      return DraftCreationResult.failure(
        'No se encontró origen de datos para $sectionId.',
      );
    }
    final payload = preparePayload(values, sectionId: sectionId);
    try {
      final savedRow = await _moduleRepository.insertRow(dataSource, payload);
      _sectionStateController.setSelectedRow(sectionId, savedRow);
      _sectionStateController.setFormMode(sectionId, SectionFormMode.edit);
      await _inlineDraftService.loadInlineSectionsForRow(sectionId, savedRow);
      return DraftCreationResult.success(savedRow);
    } catch (error) {
      return DraftCreationResult.failure('No se pudo crear borrador: $error');
    }
  }

  Map<String, dynamic> preparePayload(
    Map<String, String> data, {
    String? sectionId,
  }) {
    final payload = <String, dynamic>{};
    final Map<String, dynamic> sectionContext = sectionId != null
        ? _sectionContextResolver(sectionId)
        : const <String, dynamic>{};
    final List<SectionField>? sectionFields =
        sectionId != null ? _sectionStateController.sectionFields[sectionId] : null;
    data.forEach((key, value) {
      if (key == 'id') return;
      if (sectionId != null) {
        final fieldMeta = _findSectionField(sectionId, key);
        if (fieldMeta != null) {
          if (!fieldMeta.persist) {
            return;
          }
          payload[key] = _resolvePayloadValue(
            fieldMeta,
            value,
            sectionContext,
          );
          return;
        }
      }
      payload[key] = value.isEmpty ? null : value;
    });
    if (sectionId != null && sectionFields != null) {
      for (final field in sectionFields) {
        if (!field.readOnly) continue;
        if (!field.persist) continue;
        if (payload.containsKey(field.id)) continue;
        final contextValue = sectionContext[field.id];
        if (contextValue == null) continue;
        payload[field.id] = _resolvePayloadValue(
          field,
          contextValue.toString(),
          sectionContext,
        );
      }
    }
    return payload;
  }

  String? ensureSectionValidation(
    String sectionId,
    Map<String, String> values,
  ) {
    final message = findSectionValidationError(sectionId, values);
    return message;
  }

  String? findSectionValidationError(
    String sectionId,
    Map<String, String> values,
  ) {
    final pedidoMessage = _pedidoInlineService.validatePedidoSection(
      sectionId,
      values,
      hasDetalle: _hasInlineRowsResolver('pedidos_tabla', 'pedidos_detalle'),
    );
    if (pedidoMessage != null) return pedidoMessage;
    final movimientoMessage = _movimientoService.validateMovimientoSection(
      sectionId,
      values,
      hasDetalleRows: _hasInlineRowsResolver(sectionId, 'movimientos_detalle'),
    );
    if (movimientoMessage != null) return movimientoMessage;
    if (sectionId == 'compras') {
      final proveedorId = values['idproveedor']?.trim() ?? '';
      if (proveedorId.isEmpty) {
        return 'Selecciona un proveedor antes de guardar la compra.';
      }
      if (!_hasInlineRowsResolver('compras', 'compras_detalle')) {
        return 'Agrega al menos un producto en el detalle de la compra.';
      }
    }
    if (sectionId == 'compras_movimientos' &&
        !_hasInlineRowsResolver(
          'compras_movimientos',
          'compras_movimiento_detalle',
        )) {
      return 'Registra al menos un producto en el movimiento de compra.';
    }
    if (sectionId == 'fabricaciones_maquila' &&
        !_hasInlineRowsResolver(
          'fabricaciones_maquila',
          'fabricaciones_maquila_consumos',
        )) {
      return 'Registra al menos un material entregado antes de guardar.';
    }
    if ((sectionId == 'viajes' || sectionId == 'viajes_bases') &&
        !_hasInlineRowsResolver(sectionId, 'viajes_detalle')) {
      return 'Registra al menos un detalle del viaje.';
    }
    return null;
  }

  dynamic _resolvePayloadValue(
    SectionField fieldMeta,
    String value,
    Map<String, dynamic> sectionContext,
  ) {
    dynamic rawValue = value;
    if (fieldMeta.readOnly) {
      final contextValue = sectionContext[fieldMeta.id];
      if (contextValue != null) {
        final contextText = contextValue.toString();
        if (contextValue is DateTime || contextText.isNotEmpty) {
          rawValue = contextValue;
        } else if (value.isEmpty) {
          rawValue = null;
        }
      } else if (value.isEmpty) {
        rawValue = null;
      }
    } else if (value.isEmpty) {
      rawValue = null;
    }
    return _normalizeFieldValue(fieldMeta, rawValue);
  }

  dynamic _normalizeFieldValue(SectionField field, dynamic rawValue) {
    if (rawValue == null) return null;
    if (rawValue is String) {
      final trimmed = rawValue.trim();
      if (trimmed.isEmpty) return null;
      rawValue = trimmed;
    }
    final fieldType = _resolveFieldType(field);
    if (fieldType == FormFieldType.dateTime) {
      return _normalizeDateTimeValue(rawValue);
    }
    return rawValue;
  }

  dynamic _normalizeDateTimeValue(dynamic rawValue) {
    final normalized = date_time_utils.normalizeToUtcIsoString(rawValue);
    return normalized ?? rawValue;
  }

  SectionField? _findSectionField(String sectionId, String fieldId) {
    final fields = _sectionStateController.sectionFields[sectionId];
    if (fields == null) return null;
    for (final field in fields) {
      if (field.id == fieldId) return field;
    }
    return null;
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

  bool _matchesVisibilityCondition(
    SectionField field, {
    required Map<String, String> values,
  }) {
    final compared = values[field.visibleWhenField!] ?? '';
    final normalizedCompared = compared.trim().toLowerCase();
    final targets = _normalizeVisibilityTargets(field.visibleWhenEquals);
    if (targets.isEmpty) {
      return normalizedCompared ==
          (field.visibleWhenEquals ?? '').trim().toLowerCase();
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
