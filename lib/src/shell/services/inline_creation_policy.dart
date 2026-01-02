import 'package:erp_app/src/domains/clientes/client_context_service.dart';
import 'package:erp_app/src/domains/pedidos/pedido_pago_coordinator.dart';
import 'package:erp_app/src/shell/models.dart';

/// Reglas de negocio que determinan si se puede crear registros inline.
class InlineCreationPolicy {
  InlineCreationPolicy({
    required ClientContextService clientContextService,
    required PedidoPagoCoordinator pedidoPagoCoordinator,
    required bool Function(String sectionId, String inlineId)
        hasInlineRowsResolver,
    required Map<String, String>? Function(String sectionId)
        formDraftValuesResolver,
  })  : _clientContextService = clientContextService,
        _pedidoPagoCoordinator = pedidoPagoCoordinator,
        _hasInlineRowsResolver = hasInlineRowsResolver,
        _formDraftValuesResolver = formDraftValuesResolver;

  final ClientContextService _clientContextService;
  final PedidoPagoCoordinator _pedidoPagoCoordinator;
  final bool Function(String sectionId, String inlineId) _hasInlineRowsResolver;
  final Map<String, String>? Function(String sectionId) _formDraftValuesResolver;

  String? validatePedidoInlineCreation({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
  }) {
    final clientId = _clientContextService.resolveClientId(
      parentSectionId,
      parentRow,
    );
    final hasDetalle = _hasInlineRowsResolver(
      'pedidos_tabla',
      'pedidos_detalle',
    );
    return _pedidoPagoCoordinator.validateInlineCreation(
      parentSectionId: parentSectionId,
      inline: inline,
      clientId: clientId,
      hasDetalle: hasDetalle,
    );
  }

  String? validateCompraInlineCreation({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
  }) {
    if (parentSectionId != 'compras') return null;
    const gatedInlineIds = {'compras_pagos', 'compras_movimientos'};
    if (!gatedInlineIds.contains(inline.id)) return null;
    String? proveedorId = parentRow['idproveedor']?.toString();
    proveedorId ??= _formDraftValuesResolver(parentSectionId)?['idproveedor']
        ?.trim();
    if (proveedorId == null || proveedorId.isEmpty) {
      return 'Selecciona un proveedor antes de registrar ${inline.title.toLowerCase()}.';
    }
    final hasDetalle = _hasInlineRowsResolver('compras', 'compras_detalle');
    if (!hasDetalle) {
      return 'Agrega al menos un producto en el detalle de la compra antes de registrar ${inline.title.toLowerCase()}.';
    }
    return null;
  }

  String? validateMaquilaInlineCreation({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required Map<String, dynamic> parentRow,
  }) {
    if (parentSectionId != 'fabricaciones_maquila') return null;
    if (inline.id != 'fabricaciones_maquila_resultados') return null;
    final hasEntregado = _hasMaquilaInlineRows(
      parentSectionId,
      'fabricaciones_maquila_consumos',
      parentRow,
    );
    if (!hasEntregado) {
      return 'Registra al menos un material entregado antes de recibir productos.';
    }
    final hasCostos = _hasMaquilaInlineRows(
      parentSectionId,
      'fabricaciones_maquila_costos',
      parentRow,
    );
    if (!hasCostos) {
      return 'Registra al menos un costo adicional antes de recibir productos.';
    }
    return null;
  }

  bool compraTieneMovimientos(Map<String, dynamic> row) {
    final value = row['tiene_movimientos'];
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim() ?? '';
    return text == 'true';
  }

  bool _hasMaquilaInlineRows(
    String sectionId,
    String inlineId,
    Map<String, dynamic> parentRow,
  ) {
    if (_hasInlineRowsResolver(sectionId, inlineId)) {
      return true;
    }
    final fallbackKey = inlineId == 'fabricaciones_maquila_consumos'
        ? 'consumos_registrados'
        : inlineId == 'fabricaciones_maquila_costos'
            ? 'costos_registrados'
            : null;
    if (fallbackKey == null) return false;
    final raw = parentRow[fallbackKey];
    if (raw == null) return false;
    if (raw is num) {
      return raw > 0;
    }
    final parsed = double.tryParse(raw.toString());
    return parsed != null && parsed > 0;
  }
}
