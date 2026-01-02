import 'package:erp_app/src/domains/clientes/client_context_service.dart';
import 'package:erp_app/src/domains/movimientos/movimiento_inline_coordinator.dart';
import 'package:erp_app/src/domains/pedidos/pedido_pago_coordinator.dart';
import 'package:erp_app/src/shell/services/inline_draft_service.dart';

/// Centraliza el armado de contextos inline y filtros de referencias.
class InlineContextCoordinator {
  InlineContextCoordinator({
    required ClientContextService clientContextService,
    required PedidoPagoCoordinator pedidoPagoCoordinator,
    required MovimientoInlineCoordinator movimientoInlineCoordinator,
    required InlineDraftService inlineDraftService,
    required Map<String, Map<String, String>> formDraftValues,
    required Map<String, dynamic> Function(String sectionId)
        sectionContextResolver,
    required void Function(String sectionId, Map<String, dynamic>? values)
        sectionContextWriter,
    required void Function(
      String sectionId,
      String fieldId,
      Map<String, dynamic>? filter,
    )
        referenceFilterSetter,
    required void Function(String message) showMessage,
  })  : _clientContextService = clientContextService,
        _pedidoPagoCoordinator = pedidoPagoCoordinator,
        _movimientoInlineCoordinator = movimientoInlineCoordinator,
        _inlineDraftService = inlineDraftService,
        _formDraftValues = formDraftValues,
        _sectionContextResolver = sectionContextResolver,
        _sectionContextWriter = sectionContextWriter,
        _referenceFilterSetter = referenceFilterSetter,
        _showMessage = showMessage;

  final ClientContextService _clientContextService;
  final PedidoPagoCoordinator _pedidoPagoCoordinator;
  final MovimientoInlineCoordinator _movimientoInlineCoordinator;
  final InlineDraftService _inlineDraftService;
  final Map<String, Map<String, String>> _formDraftValues;
  final Map<String, dynamic> Function(String sectionId) _sectionContextResolver;
  final void Function(String sectionId, Map<String, dynamic>? values)
  _sectionContextWriter;
  final void Function(
    String sectionId,
    String fieldId,
    Map<String, dynamic>? filter,
  )
  _referenceFilterSetter;
  final void Function(String message) _showMessage;

  bool prepareInlineSectionContext(
    String parentSectionId,
    Map<String, dynamic> parentRow,
    String targetSectionId,
  ) {
    if (targetSectionId == 'fabricaciones_internas_consumos' ||
        targetSectionId == 'fabricaciones_internas_resultados') {
      final baseId = parentRow['idbase']?.toString();
      final recetaId = parentRow['idreceta']?.toString();
      if (baseId == null || baseId.isEmpty) {
        _showMessage('Selecciona una base antes de registrar productos.');
        _sectionContextWriter(targetSectionId, null);
        _referenceFilterSetter(targetSectionId, 'idproducto', null);
        return false;
      }
      if (recetaId == null || recetaId.isEmpty) {
        _showMessage('Selecciona una receta antes de registrar productos.');
        _sectionContextWriter(targetSectionId, null);
        _referenceFilterSetter(targetSectionId, 'idproducto', null);
        return false;
      }
      _sectionContextWriter(
        targetSectionId,
        {'idbase': baseId, 'idreceta': recetaId},
      );
      final filter = <String, dynamic>{'idreceta': recetaId};
      if (targetSectionId == 'fabricaciones_internas_consumos') {
        filter['idbase'] = baseId;
      }
      _referenceFilterSetter(targetSectionId, 'idproducto', filter);
      return true;
    }
    if (targetSectionId == 'fabricaciones_maquila_consumos') {
      final baseId = parentRow['idbase']?.toString();
      if (baseId == null || baseId.isEmpty) {
        _showMessage('Selecciona una base antes de registrar materiales.');
        _sectionContextWriter(targetSectionId, null);
        _referenceFilterSetter(targetSectionId, 'idproducto', null);
        return false;
      }
      _sectionContextWriter(targetSectionId, {'idbase': baseId});
      _referenceFilterSetter(
        targetSectionId,
        'idproducto',
        {'idbase': baseId},
      );
      return true;
    }
    if (targetSectionId == 'viajes_detalle') {
      return prepareViajeDetalleContext(parentSectionId, parentRow);
    }
    if (targetSectionId == 'compras_movimientos') {
      final compraId = parentRow['id']?.toString();
      if (compraId == null || compraId.isEmpty) {
        _sectionContextWriter(targetSectionId, null);
        return true;
      }
      _sectionContextWriter(targetSectionId, {'idcompra': compraId});
      return true;
    }
    if (targetSectionId != 'pedidos_movimientos') {
      _sectionContextWriter(targetSectionId, null);
      return true;
    }
    final result = _clientContextService.prepareInlineContext(
      parentSectionId: parentSectionId,
      parentRow: parentRow,
      targetSectionId: targetSectionId,
    );
    if (!result.canProceed) {
      if (result.errorMessage != null) {
        _showMessage(result.errorMessage!);
      }
      _movimientoInlineCoordinator.clearMovementReferenceFilters(
        targetSectionId,
      );
      _sectionContextWriter(targetSectionId, null);
      return false;
    }
    final clientContext = Map<String, dynamic>.from(
      result.clientContext ?? const <String, dynamic>{},
    );
    final clientId = result.clientId;
    final baseIdCandidate = parentRow['idbase']?.toString();
    final baseId = (baseIdCandidate != null && baseIdCandidate.isNotEmpty)
        ? baseIdCandidate
        : clientContext['idbase']?.toString();
    if (baseId != null && baseId.isNotEmpty) {
      clientContext['idbase'] = baseId;
    } else {
      clientContext.remove('idbase');
    }
    _sectionContextWriter(targetSectionId, clientContext);
    if (clientId != null && clientId.isNotEmpty) {
      _movimientoInlineCoordinator.applyMovementReferenceFilters(
        targetSectionId,
        clientId,
        baseId: baseId,
      );
    }
    return true;
  }

  bool prepareViajeDetalleContext(
    String parentSectionId,
    Map<String, dynamic>? viajeRow,
  ) {
    final viajeId = viajeRow?['id']?.toString();
    final baseId = _resolveViajeBaseId(parentSectionId, viajeRow);
    if (baseId == null || baseId.isEmpty) {
      _showMessage('Asigna una base al viaje antes de elegir un packing.');
      clearViajeDetalleContext();
      return false;
    }
    final contextValues = <String, dynamic>{
      'idbase': baseId,
      if (viajeId != null && viajeId.isNotEmpty) 'idviaje': viajeId,
    };
    _sectionContextWriter('viajes_detalle', contextValues);
    _referenceFilterSetter('viajes_detalle', 'idpacking', {'idbase': baseId});
    _applyViajeDetalleMovementFilters(
      parentSectionId: parentSectionId,
      viajeRow: viajeRow,
      baseId: baseId,
    );
    return true;
  }

  bool prepareViajeDetalleEditContext({
    required String parentSectionId,
    Map<String, dynamic>? parentRow,
    Map<String, dynamic>? detalleRow,
  }) {
    final viajeId =
        detalleRow?['idviaje']?.toString() ?? parentRow?['id']?.toString();
    final baseId =
        parentRow?['idbase']?.toString() ??
        detalleRow?['base_id']?.toString() ??
        detalleRow?['idbase']?.toString();
    if (viajeId == null || viajeId.isEmpty) {
      _showMessage('No se encontró el viaje asociado al detalle.');
      clearViajeDetalleContext();
      return false;
    }
    if (baseId == null || baseId.isEmpty) {
      _showMessage('Asigna una base al viaje antes de editar el detalle.');
      clearViajeDetalleContext();
      return false;
    }
    _sectionContextWriter('viajes_detalle', {
      'idviaje': viajeId,
      'idbase': baseId,
    });
    _referenceFilterSetter('viajes_detalle', 'idpacking', {'idbase': baseId});
    final currentMovimientoId = detalleRow?['idmovimiento']?.toString();
    _applyViajeDetalleMovementFilters(
      parentSectionId: parentSectionId,
      viajeRow: parentRow ?? detalleRow,
      baseId: baseId,
      excludeMovimientoId: currentMovimientoId,
    );
    return true;
  }

  void clearViajeDetalleContext() {
    _sectionContextWriter('viajes_detalle', null);
    _referenceFilterSetter('viajes_detalle', 'idpacking', null);
    _referenceFilterSetter('viajes_detalle', 'idmovimiento', null);
  }

  void preparePedidoPagoContext(Map<String, dynamic> pedidoRow) {
    final contextValues = _pedidoPagoCoordinator.buildPagoContext(pedidoRow);
    _sectionContextWriter('pedidos_pagos', contextValues);
  }

  void preparePedidoMovimientoEditContext(
    String parentSectionId,
    String formSectionId,
    Map<String, dynamic> row,
  ) {
    final clientId = row['idcliente']?.toString() ??
        _clientContextService.resolveClientId(parentSectionId, row);
    final baseId = row['idbase']?.toString();
    if (clientId != null && clientId.isNotEmpty) {
      final clientName =
          row['cliente_nombre']?.toString() ??
          _clientContextService.resolveClientName(
            parentSectionId,
            row,
            clientId,
          );
      _sectionContextWriter(formSectionId, {
        'idcliente': clientId,
        'cliente_nombre': clientName ?? '',
        'idbase': baseId,
      });
      _movimientoInlineCoordinator.applyMovementReferenceFilters(
        formSectionId,
        clientId,
        baseId: baseId,
      );
    }
  }

  String resolveMovimientoBaseId(
    String parentSectionId,
    Map<String, dynamic> parentRow,
  ) {
    final rowValue = parentRow['idbase']?.toString().trim();
    if (rowValue != null && rowValue.isNotEmpty) return rowValue;
    final draftValue = _formDraftValues[parentSectionId]?['idbase']?.trim();
    if (draftValue != null && draftValue.isNotEmpty) return draftValue;
    final contextBase =
        _sectionContextResolver(parentSectionId)['idbase']?.toString().trim();
    if (contextBase != null && contextBase.isNotEmpty) return contextBase;
    return '';
  }

  void updateMovementContextBase(String sectionId, String? baseId) {
    final normalized = baseId?.trim() ?? '';
    final currentContext =
        Map<String, dynamic>.from(_sectionContextResolver(sectionId));
    final existing = currentContext['idbase']?.toString() ?? '';
    if (normalized.isEmpty) {
      if (existing.isEmpty && currentContext.isEmpty) return;
      currentContext.remove('idbase');
    } else {
      if (existing == normalized) return;
      currentContext['idbase'] = normalized;
    }
    _sectionContextWriter(sectionId, currentContext);
  }

  void _applyViajeDetalleMovementFilters({
    required String parentSectionId,
    Map<String, dynamic>? viajeRow,
    required String baseId,
    String? excludeMovimientoId,
  }) {
    final excludeMovimientos = _collectViajeDetalleMovimientoIds(
      parentSectionId: parentSectionId,
      viajeRow: viajeRow,
      excludeMovimientoId: excludeMovimientoId,
    );
    final filter = <String, dynamic>{
      'idbase': baseId,
      'estado_texto': 'asignado',
    };
    if (excludeMovimientos.isNotEmpty) {
      filter['id__not_in'] = excludeMovimientos.join(',');
    }
    _referenceFilterSetter('viajes_detalle', 'idmovimiento', filter);
  }

  List<String> _collectViajeDetalleMovimientoIds({
    required String parentSectionId,
    Map<String, dynamic>? viajeRow,
    String? excludeMovimientoId,
  }) {
    final result = <String>{};
    final parentRowId =
        viajeRow?['id']?.toString() ?? viajeRow?['idviaje']?.toString();
    if (parentRowId != null && parentRowId.isNotEmpty) {
      final key = _inlineDraftService.inlineKey(
        parentSectionId,
        parentRowId,
        'viajes_detalle',
      );
      final persisted = _inlineDraftService.inlineSectionData[key];
      if (persisted != null) {
        for (final row in persisted) {
          final movimientoId = row['idmovimiento']?.toString();
          if (movimientoId == null ||
              movimientoId.isEmpty ||
              movimientoId == excludeMovimientoId) {
            continue;
          }
          result.add(movimientoId);
        }
      }
    }
    final pendingRows = _inlineDraftService.findPendingRows(
      parentSectionId,
      'viajes_detalle',
    );
    for (final pending in pendingRows) {
      final movimientoId = pending.rawValues['idmovimiento']?.toString();
      if (movimientoId == null ||
          movimientoId.isEmpty ||
          movimientoId == excludeMovimientoId) {
        continue;
      }
      result.add(movimientoId);
    }
    return result.toList(growable: false);
  }

  String? _resolveViajeBaseId(
    String parentSectionId,
    Map<String, dynamic>? viajeRow,
  ) {
    final candidates = <String?>[
      viajeRow?['idbase']?.toString(),
      _formDraftValues[parentSectionId]?['idbase'],
      if (parentSectionId == 'viajes')
        _formDraftValues['viajes_bases']?['idbase'],
      if (parentSectionId == 'viajes_bases')
        _formDraftValues['viajes']?['idbase'],
    ];
    for (final candidate in candidates) {
      final cleaned = candidate?.trim();
      if (cleaned != null && cleaned.isNotEmpty) {
        return cleaned;
      }
    }
    return null;
  }
}
