import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_pending_row.dart';
import 'package:erp_app/src/shared/inline_table/inline_validation.dart';
import 'package:erp_app/src/shell/models.dart';

class PedidoInlineValidationResult {
  const PedidoInlineValidationResult._(this.isValid, this.message);

  final bool isValid;
  final String? message;

  factory PedidoInlineValidationResult.success() =>
      const PedidoInlineValidationResult._(true, null);

  factory PedidoInlineValidationResult.error(String message) =>
      PedidoInlineValidationResult._(false, message);
}

/// Reúne las reglas de negocio asociadas a los pedidos (detalles, pagos, etc.)
/// para que el shell solo orqueste y delegue la validación/calculos.
class PedidoInlineService {
  const PedidoInlineService();

  PedidoInlineValidationResult validateInlineCreation({
    required String parentSectionId,
    required InlineSectionConfig inline,
    required String? clientId,
    required bool hasDetalle,
  }) {
    if (parentSectionId != 'pedidos_tabla') {
      return PedidoInlineValidationResult.success();
    }
    if (inline.id != 'pedidos_movimientos' &&
        inline.id != 'pedidos_pagos') {
      return PedidoInlineValidationResult.success();
    }
    if (clientId == null || clientId.trim().isEmpty) {
      return PedidoInlineValidationResult.error(
        'Selecciona un cliente en el pedido antes de registrar '
        '${inlineFriendlyName(inline.id)}.',
      );
    }
    if (!hasDetalle) {
      return PedidoInlineValidationResult.error(
        'Agrega al menos un registro en el detalle del pedido antes de '
        'registrar ${inlineFriendlyName(inline.id)}.',
      );
    }
    return PedidoInlineValidationResult.success();
  }

  String inlineFriendlyName(String inlineId) {
    switch (inlineId) {
      case 'pedidos_movimientos':
        return 'movimientos';
      case 'pedidos_pagos':
        return 'pagos';
      default:
        return 'registros';
    }
  }

  /// Suma los montos registrados del detalle del pedido.
  double detalleTotalAmount({
    required Iterable<Map<String, dynamic>> persistedDetalle,
    required Iterable<InlinePendingRow> pendingDetalle,
  }) {
    double total = 0;
    final pendingOverrideIds = _collectPendingOverrideIds(pendingDetalle);
    for (final row in persistedDetalle) {
      final rowId = _normalizeRowId(row['id']);
      if (rowId != null && pendingOverrideIds.contains(rowId)) continue;
      total += _parseAmount(row['precioventa']);
    }
    for (final row in pendingDetalle) {
      total += _parseAmount(row.rawValues['precioventa']);
    }
    return total;
  }

  /// Suma los pagos registrados (persistidos + pendientes), permitiendo
  /// excluir un registro puntual cuando se está editando.
  double pagosTotalAmount({
    required Iterable<Map<String, dynamic>> persistedPagos,
    required Iterable<InlinePendingRow> pendingPagos,
    String? excludePendingId,
    dynamic excludeRowId,
  }) {
    double total = 0;
    final pendingOverrideIds = _collectPendingOverrideIds(pendingPagos);
    final normalizedExcludeRowId = _normalizeRowId(excludeRowId);
    for (final row in persistedPagos) {
      final rowId = _normalizeRowId(row['id']);
      if (normalizedExcludeRowId != null && rowId == normalizedExcludeRowId) {
        continue;
      }
      if (rowId != null && pendingOverrideIds.contains(rowId)) continue;
      total += _parseAmount(row['monto']);
    }
    for (final row in pendingPagos) {
      if (excludePendingId != null && row.pendingId == excludePendingId) {
        continue;
      }
      final rowId = _normalizeRowId(row.rawValues['id']);
      if (normalizedExcludeRowId != null && rowId == normalizedExcludeRowId) {
        continue;
      }
      total += _parseAmount(row.rawValues['monto']);
    }
    return total;
  }

  double remainingPagoAmount({
    required Iterable<Map<String, dynamic>> detallePersisted,
    required Iterable<InlinePendingRow> detallePending,
    required Iterable<Map<String, dynamic>> pagosPersisted,
    required Iterable<InlinePendingRow> pagosPending,
    String? excludePagoPendingId,
    dynamic excludePagoRowId,
  }) {
    final detalleTotal = detalleTotalAmount(
      persistedDetalle: detallePersisted,
      pendingDetalle: detallePending,
    );
    final pagosTotal = pagosTotalAmount(
      persistedPagos: pagosPersisted,
      pendingPagos: pagosPending,
      excludePendingId: excludePagoPendingId,
      excludeRowId: excludePagoRowId,
    );
    final remaining = detalleTotal - pagosTotal;
    if (remaining <= 0) return 0;
    return double.parse(remaining.toStringAsFixed(2));
  }

  PedidoPagoBalance buildPagoBalance({
    required Iterable<Map<String, dynamic>> detallePersisted,
    required Iterable<InlinePendingRow> detallePending,
    required Iterable<Map<String, dynamic>> pagosPersisted,
    required Iterable<InlinePendingRow> pagosPending,
    String? excludePagoPendingId,
    dynamic excludePagoRowId,
  }) {
    final detalleTotal = detalleTotalAmount(
      persistedDetalle: detallePersisted,
      pendingDetalle: detallePending,
    );
    final pagosTotal = pagosTotalAmount(
      persistedPagos: pagosPersisted,
      pendingPagos: pagosPending,
      excludePendingId: excludePagoPendingId,
      excludeRowId: excludePagoRowId,
    );
    final remaining = (detalleTotal - pagosTotal).clamp(0, double.infinity);
    return PedidoPagoBalance(
      total: detalleTotal,
      paid: pagosTotal,
      remaining: double.parse(remaining.toStringAsFixed(2)),
    );
  }

  List<FormFieldConfig> adjustPagoFields(
    List<FormFieldConfig> fields,
    PedidoPagoBalance balance, {
    Map<String, dynamic>? pedidoRow,
  }) {
    final helperText = _buildPagoHelperText(balance, pedidoRow);
    return fields
        .map((field) {
          if (field.id == 'monto') {
            return _copyFormField(
              field,
              helperText: helperText,
            );
          }
          return field;
        })
        .toList(growable: false);
  }

  String? validateUniquePedidoProducto({
    required Iterable<Map<String, dynamic>> persistedRows,
    required Iterable<InlinePendingRow> pendingRows,
    required String productId,
    required String inlineTitle,
    String? excludePendingId,
    dynamic excludeRowId,
  }) {
    if (productId.isEmpty) return null;
    final duplicated = isInlineValueDuplicated(
      persistedRows: persistedRows,
      pendingRows: pendingRows,
      fieldName: 'idproducto',
      value: productId,
      excludePendingId: excludePendingId,
      excludeRowId: excludeRowId,
    );
    if (!duplicated) return null;
    final friendly = inlineTitle.toLowerCase();
    return 'Ya agregaste este producto en $friendly.';
  }

  String? validatePagoAmount({
    required double amount,
    required double remaining,
  }) {
    return validateInlineMax(
      value: amount,
      max: remaining,
      message: 'Solo puedes registrar hasta ${remaining.toStringAsFixed(2)}.',
    );
  }

  /// Valida los formularios propios del dominio de pedidos.
  String? validatePedidoSection(
    String sectionId,
    Map<String, String> values, {
    required bool hasDetalle,
  }) {
    if (sectionId == 'pedidos_tabla') {
      final clientId = values['idcliente']?.trim();
      final requiredClient = validateInlineRequired(
        clientId,
        'Selecciona un cliente antes de guardar el pedido.',
      );
      if (requiredClient != null) return requiredClient;
      if (!hasDetalle) {
        return 'Agrega al menos un producto en el detalle del pedido.';
      }
    } else if (sectionId == 'pedidos_pagos') {
      final accountId = values['idcuenta']?.trim();
      final requiredAccount = validateInlineRequired(
        accountId,
        'Selecciona una cuenta bancaria para registrar el pago.',
      );
      if (requiredAccount != null) return requiredAccount;
    }
    return null;
  }

  FormFieldConfig _copyFormField(
    FormFieldConfig field, {
    List<FormFieldOption>? options,
    String? helperText,
  }) {
    return FormFieldConfig(
      id: field.id,
      label: field.label,
      initialValue: field.initialValue,
      helperText: helperText ?? field.helperText,
      helperBuilder: field.helperBuilder,
      required: field.required,
      readOnly: field.readOnly,
      fieldType: field.fieldType,
      options: options ?? field.options,
      onAddReference: field.onAddReference,
      visibleWhen: field.visibleWhen,
      sectionId: field.sectionId,
    );
  }

  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _buildPagoHelperText(
    PedidoPagoBalance balance,
    Map<String, dynamic>? pedidoRow,
  ) {
    final remainingText = _formatAmount(balance.remaining);
    if (pedidoRow == null) {
      return 'Saldo disponible: $remainingText';
    }
    final hasTotals = pedidoRow.containsKey('total_con_cargos') ||
        pedidoRow.containsKey('total_pagado') ||
        pedidoRow.containsKey('saldo');
    if (!hasTotals) {
      return 'Saldo disponible: $remainingText';
    }
    final lines = <String>[];
    final hasBreakdown = _rowHasKeys(pedidoRow, const [
      'total_penalidad',
      'total_monto_ida',
      'total_monto_vuelta',
      'total_recargo_provincia',
    ]);
    if (hasBreakdown) {
      final penalidad = _readRowAmount(pedidoRow, 'total_penalidad') ?? 0;
      final ida = _readRowAmount(pedidoRow, 'total_monto_ida') ?? 0;
      final vuelta = _readRowAmount(pedidoRow, 'total_monto_vuelta') ?? 0;
      final provincia =
          _readRowAmount(pedidoRow, 'total_recargo_provincia') ?? 0;
      lines.add(
        'Penalidad: ${_formatAmount(penalidad)} | '
        'Ida: ${_formatAmount(ida)} | '
        'Vuelta: ${_formatAmount(vuelta)} | '
        'Provincia: ${_formatAmount(provincia)}',
      );
    }
    lines.add(
      'Total: ${_formatAmount(balance.total)} | '
      'Pagado: ${_formatAmount(balance.paid)} | '
      'Saldo: ${_formatAmount(balance.remaining)}',
    );
    return lines.join('\n');
  }

  bool _rowHasKeys(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      if (!row.containsKey(key)) return false;
    }
    return true;
  }

  double? _readRowAmount(Map<String, dynamic> row, String key) {
    if (!row.containsKey(key)) return null;
    final value = row[key];
    if (value == null) return null;
    return _parseAmount(value);
  }

  String _formatAmount(double value) => value.toStringAsFixed(2);

  Set<String> _collectPendingOverrideIds(
    Iterable<InlinePendingRow> pendingRows,
  ) {
    final ids = <String>{};
    for (final row in pendingRows) {
      final rowId = _normalizeRowId(row.rawValues['id']);
      if (rowId != null) ids.add(rowId);
    }
    return ids;
  }

  String? _normalizeRowId(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

}

class PedidoPagoBalance {
  const PedidoPagoBalance({
    required this.total,
    required this.paid,
    required this.remaining,
  });

  final double total;
  final double paid;
  final double remaining;
}
