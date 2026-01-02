import 'package:erp_app/src/navegacion/inline_types.dart';
import 'package:erp_app/src/recursos/movimientos_constants.dart';
import 'package:erp_app/src/shared/inline_table/inline_helpers.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';

InlineTableConfig buildPedidosMovimientosInlineView(
  InlineSectionViewContext context,
) {
  final keyToLabel = buildInlineColumnLabelMap(context.inlineConfig);
  final rows = context.defaultConfig.rows
      .map(
        (row) => _formatMovimientoRow(
          row,
          keyToLabel,
          context.sectionContext,
        ),
      )
      .toList(growable: false);

  return rebuildInlineConfig(context, rows);
}

Map<String, String> buildPedidosMovimientosPendingDisplay(
  InlinePendingDisplayContext context,
) {
  final values = context.rawValues;
  final isProvincia = parseInlineBool(values['es_provincia']);
  final baseId = normalizeInlineValue(values['idbase']);
  final result = <String, String>{
    'base_nombre': baseId.isEmpty
        ? ''
        : context.resolveReferenceLabel('idbase', baseId) ?? '',
    'direccion_display': '',
    'referencia_display': '',
    'contacto_numero_display': '',
    'contacto_nombre_display': '',
  };
  if (isProvincia) {
    final direccionId =
        normalizeInlineValue(values[kMovDestinoProvinciaDireccionField]);
    final metadata = direccionId.isEmpty
        ? null
        : context.resolveReferenceMetadata(
            kMovDestinoProvinciaDireccionField,
            direccionId,
          );
    result['direccion_display'] = direccionId.isEmpty
        ? ''
        : metadata?['lugar_llegada']?.toString() ??
            context.resolveReferenceLabel(
              kMovDestinoProvinciaDireccionField,
              direccionId,
            ) ??
            '';
    result['contacto_numero_display'] =
        metadata?['dni']?.toString() ?? '';
    result['contacto_nombre_display'] =
        metadata?['nombre_completo']?.toString() ?? '';
  } else {
    final direccionId =
        normalizeInlineValue(values[kMovDestinoLimaDireccionField]);
    final direccionMetadata = direccionId.isEmpty
        ? null
        : context.resolveReferenceMetadata(
            kMovDestinoLimaDireccionField,
            direccionId,
          );
    result['direccion_display'] = direccionId.isEmpty
        ? ''
        : context.resolveReferenceLabel(
              kMovDestinoLimaDireccionField,
              direccionId,
            ) ??
            '';
    result['referencia_display'] =
        direccionMetadata?['referencia']?.toString() ?? '';
    final contactoId =
        normalizeInlineValue(values[kMovDestinoLimaContactoField]);
    final contactoMetadata = contactoId.isEmpty
        ? null
        : context.resolveReferenceMetadata(
            kMovDestinoLimaContactoField,
            contactoId,
          );
    final contactoNumero = context.resolveReferenceLabel(
          kMovDestinoLimaContactoField,
          contactoId,
        ) ??
        context.sectionContext['cliente_numero']?.toString() ??
        '';
    result['contacto_numero_display'] = contactoNumero;
    result['contacto_nombre_display'] =
        contactoMetadata?['nombre_contacto']?.toString() ??
            context.sectionContext['cliente_nombre']?.toString() ??
            '';
  }
  return result;
}

InlineTableRow _formatMovimientoRow(
  InlineTableRow row,
  Map<String, String> keyToLabel,
  Map<String, dynamic> sectionContext,
) {
  final pendingRaw =
      row.rawRow?['__pending_raw_values'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
  final isProvincia = parseInlineBool(
    row.rawRow?['es_provincia'] ?? pendingRaw['es_provincia'],
  );

  final base = inlineValueFromRow(row, 'base_nombre', keyToLabel);
  final direccion = inlineValueFromRow(row, 'direccion_display', keyToLabel);
  final referencia = isProvincia
      ? ''
      : inlineValueFromRow(row, 'referencia_display', keyToLabel);

  var numero =
      inlineValueFromRow(row, 'contacto_numero_display', keyToLabel);
  if (numero.isEmpty && !isProvincia) {
    numero = sectionContext['cliente_numero']?.toString() ?? '';
  }

  var nombre =
      inlineValueFromRow(row, 'contacto_nombre_display', keyToLabel);
  if (nombre.isEmpty && !isProvincia) {
    nombre = sectionContext['cliente_nombre']?.toString() ?? '';
  }

  final values = <String, String>{
    keyToLabel['base_nombre'] ?? 'Base': base,
    keyToLabel['direccion_display'] ?? 'Dirección': direccion,
    keyToLabel['referencia_display'] ?? 'Referencia': referencia,
    keyToLabel['contacto_numero_display'] ?? 'Número': numero,
    keyToLabel['contacto_nombre_display'] ?? 'Nombre que recibe': nombre,
  };

  return copyInlineRow(row, values);
}
