import 'package:erp_app/src/navegacion/inline_types.dart';
import 'package:erp_app/src/shared/inline_table/inline_helpers.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';

InlineTableConfig buildViajesDetalleInlineView(
  InlineSectionViewContext context,
) {
  final keyToLabel = buildInlineColumnLabelMap(context.inlineConfig);
  final rows = context.defaultConfig.rows
      .map(
        (row) => _formatViajeDetalleRow(
          row,
          keyToLabel,
        ),
      )
      .toList(growable: false);
  return rebuildInlineConfig(context, rows);
}

InlineTableRow _formatViajeDetalleRow(
  InlineTableRow row,
  Map<String, String> keyToLabel,
) {
  final values = <String, String>{
    keyToLabel['cliente_nombre'] ?? 'Cliente':
        inlineValueFromRow(row, 'cliente_nombre', keyToLabel),
    keyToLabel['cliente_numero'] ?? 'Número cliente':
        inlineValueFromRow(row, 'cliente_numero', keyToLabel),
    keyToLabel['direccion_display'] ?? 'Dirección':
        inlineValueFromRow(row, 'direccion_display', keyToLabel),
    keyToLabel['contacto_display'] ?? 'Contacto':
        inlineValueFromRow(row, 'contacto_display', keyToLabel),
    keyToLabel['estado_detalle'] ?? 'Estado':
        inlineValueFromRow(row, 'estado_detalle', keyToLabel),
    keyToLabel['packing_display'] ?? 'Packing':
        inlineValueFromRow(row, 'packing_display', keyToLabel),
  };
  return copyInlineRow(row, values);
}

Map<String, String> buildViajesDetallePendingDisplay(
  InlinePendingDisplayContext context,
) {
  final movimientoId = normalizeInlineValue(context.rawValues['idmovimiento']);
  if (movimientoId.isEmpty) {
    return {
      'cliente_nombre': '',
      'cliente_numero': '',
      'direccion_display': '',
    };
  }
  final metadata =
      context.resolveReferenceMetadata('idmovimiento', movimientoId) ?? {};
  final packingId = normalizeInlineValue(context.rawValues['idpacking']);
  final packingMetadata = packingId.isEmpty
      ? null
      : context.resolveReferenceMetadata('idpacking', packingId);
  final resolvedPackingName =
      packingMetadata?['nombre']?.toString() ??
          context.resolveReferenceLabel('idpacking', packingId) ??
          '';
  final resolvedPackingType =
      packingMetadata?['tipo']?.toString() ?? '';
  final resolvedPackingObs =
      packingMetadata?['observacion']?.toString() ?? '';
  final isProvincia = parseInlineBool(
    metadata['es_provincia'] ?? context.rawValues['es_provincia'],
  );
  final direccion = isProvincia
      ? _combineParts([
          _cleanInlineText(
            metadata['provincia_destino'] ??
                context.rawValues['provincia_destino'],
          ),
          _cleanInlineText(
            metadata['provincia_destinatario'] ??
                context.rawValues['provincia_destinatario'],
          ),
          _cleanInlineText(
            metadata['provincia_dni'] ?? context.rawValues['provincia_dni'],
          ),
        ])
      : _combineParts([
          _cleanInlineText(
            metadata['direccion_display'] ??
                metadata['direccion_texto'] ??
                metadata['direccion'],
          ),
          _cleanInlineText(
            metadata['referencia_display'] ??
                metadata['direccion_referencia'],
          ),
        ]);
  final contactoNumero = _cleanInlineText(
    metadata['contacto_numero_display'] ??
        metadata['contacto_numero'] ??
        metadata['cliente_numero'],
  );
  final contactoNombre = _cleanInlineText(
    metadata['contacto_nombre_display'] ??
        metadata['contacto_nombre'] ??
        metadata['cliente_nombre'],
  );
  final provinciaNombre = _cleanInlineText(
    metadata['provincia_destinatario'] ??
        context.rawValues['provincia_destinatario'],
  );
  final provinciaDni = _cleanInlineText(
    metadata['provincia_dni'] ?? context.rawValues['provincia_dni'],
  );
  final provinciaNombreFallback =
      provinciaNombre.isNotEmpty ? provinciaNombre : contactoNombre;
  final provinciaDniFallback =
      provinciaDni.isNotEmpty ? provinciaDni : contactoNumero;
  final contacto = isProvincia
      ? _combineParts([
          provinciaNombreFallback,
          provinciaDniFallback,
        ])
      : _combineParts([
          contactoNumero,
          contactoNombre,
        ]);
  final packingDisplay =
      context.resolveReferenceLabel('idpacking', packingId) ??
          _combineParts([
            resolvedPackingName,
            resolvedPackingType,
            resolvedPackingObs,
          ]);
  return {
    'cliente_nombre':
        metadata['cliente_nombre']?.toString() ??
            context.resolveReferenceLabel('idmovimiento', movimientoId) ??
            '',
    'cliente_numero': metadata['cliente_numero']?.toString() ?? '',
    'direccion_display': direccion,
    'contacto_display': contacto,
    'estado_detalle': 'En camino',
    'packing_display': packingDisplay,
  };
}

String _combineParts(List<String?> parts) {
  final filtered = parts
      .map((value) => value?.trim() ?? '')
      .where((value) => value.isNotEmpty)
      .toList();
  if (filtered.isEmpty) return '';
  return filtered.join(' / ');
}

String _cleanInlineText(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return '';
  return text;
}
