import 'package:erp_app/src/recursos/movimientos_constants.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_pending_row.dart';
import 'package:erp_app/src/shared/inline_table/inline_validation.dart';

/// Encapsula las reglas específicas de movimientos para mantener el shell
/// libre de validaciones de dominio.
class MovimientoService {
  const MovimientoService();

  List<FormFieldConfig> adjustMovimientoDetalleFields(
    List<FormFieldConfig> fields,
    Map<String, double>? remaining, {
    Map<String, double>? baseStock,
  }) {
    Set<String>? allowedIds;
    if (remaining != null) {
      final allowedProducts = remaining.entries.where(
        (entry) => entry.value > 0.0001,
      );
      allowedIds = allowedProducts.map((entry) => entry.key).toSet();
      if (allowedIds.isEmpty) return const [];
    }
    Set<String>? stockIds;
    if (baseStock != null && baseStock.isNotEmpty) {
      stockIds = baseStock.entries
          .where((entry) => entry.value > 0.0001)
          .map((entry) => entry.key)
          .toSet();
      if (stockIds.isEmpty && allowedIds == null) {
        return const [];
      }
    }
    Set<String>? effectiveIds;
    if (allowedIds != null) {
      effectiveIds = {...allowedIds};
    }
    if (stockIds != null) {
      if (effectiveIds == null) {
        effectiveIds = {...stockIds};
      } else {
        effectiveIds = effectiveIds.intersection(stockIds);
      }
    }
    if (effectiveIds != null && effectiveIds.isEmpty) {
      return const [];
    }
    return fields
        .map((field) {
          if (field.id == 'idproducto' && field.options != null) {
            final filteredOptions = effectiveIds == null
                ? field.options!
                : field.options!
                    .where((option) => effectiveIds!.contains(option.value))
                    .toList();
            if (effectiveIds != null && filteredOptions.isEmpty) {
              return null;
            }
            final helperParts = <String>[];
            if ((field.helperText ?? '').isNotEmpty) {
              helperParts.add(field.helperText!);
            }
            final pendingSummary = remaining == null
                ? null
                : _formatRemainingSummary(filteredOptions, remaining);
            if (pendingSummary != null && pendingSummary.isNotEmpty) {
              helperParts.add(pendingSummary);
            }
            final stockSummary = baseStock == null
                ? null
                : _formatStockSummary(filteredOptions, baseStock);
            if (stockSummary != null && stockSummary.isNotEmpty) {
              helperParts.add(stockSummary);
            }
            return _copyFormField(
              field,
              options: filteredOptions,
              helperText:
                  helperParts.isEmpty ? field.helperText : helperParts.join('\n'),
            );
          }
          if (field.id == 'cantidad') {
            return _copyFormField(
              field,
              helperText:
                  'Ingresa una cantidad menor o igual al pendiente del '
                  'producto seleccionado.',
            );
          }
          return field;
        })
        .whereType<FormFieldConfig>()
        .toList(growable: false);
  }

  String? validateUniqueMovimientoProducto({
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

  /// Retorna los filtros por campo que deben aplicarse cuando se selecciona un
  /// cliente al crear un movimiento.
  Map<String, Map<String, dynamic>> buildClientReferenceFilters(
    String clientId, {
    String? baseId,
  }) {
    return {
      kMovDestinoLimaDireccionField: {'idcliente': clientId},
      kMovDestinoLimaContactoField: {'idcliente': clientId},
      kMovDestinoProvinciaDireccionField: {'idcliente': clientId},
      if (baseId != null && baseId.isNotEmpty)
        'idpacking': {'idbase': baseId},
    };
  }

  /// Valida los campos generales de un movimiento (destino Lima/provincia)
  /// considerando si ya existen filas en el detalle.
  String? validateMovimientoSection(
    String sectionId,
    Map<String, String> values, {
    required bool hasDetalleRows,
  }) {
    if (sectionId != 'pedidos_movimientos' && sectionId != 'movimientos') {
      return null;
    }
    final isProvincia = (values['es_provincia'] ?? '').toLowerCase() == 'true';
    if (!isProvincia) {
      final direccion = values[kMovDestinoLimaDireccionField]?.trim();
      final requiredDireccion = validateInlineRequired(
        direccion,
        'Selecciona una dirección de Lima para el movimiento.',
      );
      if (requiredDireccion != null) return requiredDireccion;
      final contacto = values[kMovDestinoLimaContactoField]?.trim();
      final requiredContacto = validateInlineRequired(
        contacto,
        'Selecciona el número de contacto para Lima.',
      );
      if (requiredContacto != null) return requiredContacto;
    } else {
      final direccionProvincia =
          values[kMovDestinoProvinciaDireccionField]?.trim();
      final requiredProvincia = validateInlineRequired(
        direccionProvincia,
        'Selecciona la dirección del destino en provincia.',
      );
      if (requiredProvincia != null) return requiredProvincia;
    }
    if (!hasDetalleRows) {
      return 'Registra al menos un producto en el detalle del movimiento.';
    }
    if (sectionId == 'movimientos') {
      final baseId = values['idbase']?.trim();
      final requiredBase = validateInlineRequired(
        baseId,
        'Selecciona la base para el movimiento.',
      );
      if (requiredBase != null) return requiredBase;
    }
    return null;
  }

  /// Verifica que la cantidad solicitada respete los productos pendientes por
  /// asignar para un movimiento.
  String? validateMovimientoDetalleCantidad(
    Map<String, String> values,
    Map<String, double>? remaining,
  ) {
    if (remaining == null) return null;
    final productId = values['idproducto'] ?? '';
    final max = remaining[productId] ?? 0;
    final cantidadText = values['cantidad'] ?? '';
    final cantidad =
        double.tryParse(cantidadText.replaceAll(',', '.')) ?? 0;
    if (productId.isEmpty || cantidad <= 0) {
      return 'Completa el producto y la cantidad.';
    }
    return validateInlineMax(
      value: cantidad,
      max: max,
      message: 'Solo queda disponible ${max.toStringAsFixed(2)}.',
    );
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

  String? _formatRemainingSummary(
    List<FormFieldOption>? options,
    Map<String, double> remaining,
  ) {
    if (options == null || options.isEmpty) return null;
    final parts = <String>[];
    for (final option in options) {
      final pending = remaining[option.value];
      if (pending == null || pending <= 0) continue;
      parts.add('${option.label} (${pending.toStringAsFixed(2)})');
    }
    if (parts.isEmpty) return null;
    return 'Pendiente: ${parts.join(', ')}';
  }

  String? _formatStockSummary(
    List<FormFieldOption>? options,
    Map<String, double> baseStock,
  ) {
    if (options == null || options.isEmpty) return null;
    if (baseStock.isEmpty) return null;
    final parts = <String>[];
    for (final option in options) {
      final available = baseStock[option.value];
      if (available == null || available <= 0) continue;
      parts.add('${option.label} (${available.toStringAsFixed(2)})');
    }
    if (parts.isEmpty) return null;
    return 'Stock base: ${parts.join(', ')}';
  }

}
