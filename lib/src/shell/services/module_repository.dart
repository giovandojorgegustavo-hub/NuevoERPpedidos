import 'package:erp_app/src/shared/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models.dart';

class ModuleRepository {
  ModuleRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const int _maxNetworkRetries = 2;
  static const Duration _baseStockCacheTtl = Duration(seconds: 15);

  final Map<String, _CachedBaseStock> _baseStockCache = {};
  final Map<String, String> _productNameCache = {};

  String _qualifiedName(String schema, String relation) {
    return schema == 'public' ? relation : '$schema.$relation';
  }

  Future<T> _withNetworkRetry<T>(Future<T> Function() action) async {
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        final result = await action();
        return result;
      } on ClientException catch (error) {
        final shouldRetry =
            error.message.toLowerCase().contains('failed to fetch');
        if (!shouldRetry || attempt > _maxNetworkRetries) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 200 * attempt));
      }
    }
  }

  Future<ModuleMetadata> fetchModules() async {
    final modulesFuture = _withNetworkRetry(() async {
      final response = await _client
          .from('ui_modules')
          .select('id,nombre,descripcion,icon,orden,security_module,activo')
          .eq('activo', true)
          .order('orden', ascending: true);
      return (response as List).cast<Map<String, dynamic>>();
    });

    final sectionsFuture = _withNetworkRetry(() async {
      final response = await _client
          .from('ui_sections')
          .select('id,module_id,nombre,descripcion,icon,orden,activo')
          .eq('activo', true)
          .order('orden', ascending: true);
      return (response as List).cast<Map<String, dynamic>>();
    });

    final sourcesFuture = _withNetworkRetry(() async {
      final response = await _client
          .from('ui_section_data_sources')
          .select(
            'section_id,list_schema,list_relation,list_is_view,form_schema,form_relation,form_is_view,detail_schema,detail_relation,detail_is_view,activo',
          )
          .eq('activo', true);
      return (response as List).cast<Map<String, dynamic>>();
    });

    final fieldsFuture = _withNetworkRetry(() async {
      final response = await _client
          .from('v_ui_section_fields')
          .select(
            'section_id,field,label,requerido,read_only,orden,data_type,widget_type,reference_schema,reference_relation,reference_label_column,default_value',
          )
          .order('section_id')
          .order('orden');
      return (response as List).cast<Map<String, dynamic>>();
    });

    final modulesRows = await modulesFuture;
    final sectionsRows = await sectionsFuture;
    final sourcesRows = await sourcesFuture;

    final sourcesMap = <String, SectionDataSource>{
      for (final src in sourcesRows)
        src['section_id'] as String: SectionDataSource(
          sectionId: src['section_id'] as String,
          listSchema: src['list_schema'] as String? ?? 'public',
          listRelation: src['list_relation'] as String,
          listIsView: (src['list_is_view'] as bool?) ?? true,
          formSchema: src['form_schema'] as String? ?? 'public',
          formRelation: src['form_relation'] as String,
          formIsView: (src['form_is_view'] as bool?) ?? false,
          detailSchema: src['detail_schema'] as String?,
          detailRelation: src['detail_relation'] as String?,
          detailIsView: src['detail_is_view'] as bool?,
        ),
    };

    final modules = <ModuleConfig>[];
    for (final moduleRow in modulesRows) {
      final moduleId = moduleRow['id'] as String;
      final moduleSections = sectionsRows
          .where((section) => section['module_id'] == moduleId)
          .map(
            (section) => ModuleSection(
              id: section['id'] as String,
              label: section['nombre'] as String? ?? '',
              icon: resolveIcon(
                section['icon'] as String?,
                fallback: Icons.table_chart_outlined,
              ),
              description: section['descripcion'] as String? ?? '',
            ),
          )
          .toList(growable: false);

      modules.add(
        ModuleConfig(
          id: moduleId,
          name: moduleRow['nombre'] as String? ?? moduleId,
          icon: resolveIcon(
            moduleRow['icon'] as String?,
            fallback: Icons.folder_outlined,
          ),
          description: moduleRow['descripcion'] as String? ?? '',
          sections: moduleSections,
        ),
      );
    }

    List<Map<String, dynamic>> fieldsRows = const [];
    try {
      fieldsRows = await fieldsFuture;
    } catch (_) {
      fieldsRows = const [];
    }
    final fieldsMap = <String, List<SectionField>>{};
    for (final fieldRow in fieldsRows) {
      final sectionId = fieldRow['section_id'] as String;
      fieldsMap
          .putIfAbsent(sectionId, () => <SectionField>[])
          .add(
            SectionField(
              sectionId: sectionId,
              id: fieldRow['field'] as String,
              label:
                  fieldRow['label'] as String? ?? (fieldRow['field'] as String),
              required: fieldRow['requerido'] as bool? ?? false,
              readOnly: fieldRow['read_only'] as bool? ?? false,
              visible: true,
              order: (fieldRow['orden'] as int?) ?? 0,
              dataType: fieldRow['data_type'] as String?,
              widgetType: fieldRow['widget_type'] as String?,
              referenceSchema: fieldRow['reference_schema'] as String?,
              referenceRelation: fieldRow['reference_relation'] as String?,
              referenceLabelColumn:
                  fieldRow['reference_label_column'] as String?,
              defaultValue: fieldRow['default_value'] as String?,
            ),
          );
    }

    return ModuleMetadata(
      modules: modules,
      sectionDataSources: sourcesMap,
      sectionFields: fieldsMap,
    );
  }

  Future<List<Map<String, dynamic>>> fetchSectionRows(
    SectionDataSource dataSource, {
    int? limit,
  }) async {
    final relationName = _qualifiedName(
      dataSource.listSchema,
      dataSource.listRelation,
    );

    final effectiveLimit = dataSource.listLimit ?? limit ?? 100;
    final query = _client.from(relationName).select();
    final orderColumn = dataSource.listOrderBy;
    if (orderColumn != null && orderColumn.isNotEmpty) {
      query.order(orderColumn, ascending: dataSource.listOrderAscending);
    }

    final rows = await _withNetworkRetry(() async {
      final response = await query.limit(effectiveLimit);
      return (response as List).cast<Map<String, dynamic>>();
    });
    return rows;
  }

  Future<Map<String, dynamic>> insertRow(
    SectionDataSource dataSource,
    Map<String, dynamic> values,
  ) async {
    final relationName = _qualifiedName(
      dataSource.formSchema,
      dataSource.formRelation,
    );
    final response = await _client
        .from(relationName)
        .insert(values)
        .select()
        .single();
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> updateRow(
    SectionDataSource dataSource,
    dynamic id,
    Map<String, dynamic> values, {
    String idColumn = 'id',
  }) async {
    final relationName = _qualifiedName(
      dataSource.formSchema,
      dataSource.formRelation,
    );
    final response = await _client
        .from(relationName)
        .update(values)
        .eq(idColumn, id)
        .select()
        .single();
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>?> fetchFormRow(
    SectionDataSource dataSource,
    dynamic id, {
    String idColumn = 'id',
  }) async {
    final relationName = _qualifiedName(
      dataSource.formSchema,
      dataSource.formRelation,
    );
    final response = await _client
        .from(relationName)
        .select()
        .eq(idColumn, id)
        .maybeSingle();
    if (response == null) return null;
    return Map<String, dynamic>.from(response as Map);
  }

  Future<void> deleteRows(
    SectionDataSource dataSource,
    List<dynamic> ids, {
    String idColumn = 'id',
  }) async {
    if (ids.isEmpty) return;
    final relationName = _qualifiedName(
      dataSource.formSchema,
      dataSource.formRelation,
    );
    await _client.from(relationName).delete().inFilter(idColumn, ids);
  }

  Future<dynamic> callRpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    final response = await _withNetworkRetry(() async {
      return _client.rpc(functionName, params: params ?? const {});
    });
    return response;
  }

  Future<List<ReferenceOption>> fetchReferenceOptions(
    SectionField field, {
    int limit = 200,
    Map<String, dynamic>? filters,
    List<String> extraColumns = const [],
  }) async {
    final relation = field.referenceRelation;
    if (relation == null || relation.isEmpty) return const [];
    final schema = field.referenceSchema ?? 'public';
    final qualified = _qualifiedName(schema, relation);
    final labelColumn = field.referenceLabelColumn ?? 'nombre';
    final selectColumns = <String>{
      'id',
      labelColumn,
      ...extraColumns,
    }.where((column) => column.isNotEmpty).join(',');
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query = _client
        .from(qualified)
        .select(selectColumns);
    if (filters != null && filters.isNotEmpty) {
      final equalityFilters = <String, dynamic>{};
      filters.forEach((rawKey, rawValue) {
        if (rawKey.endsWith('__not_in')) {
          final column = rawKey.substring(0, rawKey.length - '__not_in'.length);
          final values = _normalizeFilterList(rawValue);
          if (values.isNotEmpty) {
            query = query.not(column, 'in', values);
          }
        } else {
          equalityFilters[rawKey] = rawValue;
        }
      });
      if (equalityFilters.isNotEmpty) {
        query = query.match(equalityFilters.cast<String, Object>());
      }
    }
    final rows = await _withNetworkRetry(() async {
      final response = await query
          .order(
            labelColumn,
            ascending: true,
          )
          .limit(limit);
      return (response as List).cast<Map<String, dynamic>>();
    });
    return rows
        .map(
          (row) => ReferenceOption(
            value: row['id']?.toString() ?? '',
            label: row[labelColumn]?.toString() ?? row['id']?.toString() ?? '',
            metadata: row,
          ),
        )
        .where((option) => option.value.isNotEmpty)
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchInlineRows(
    InlineSectionDataSource dataSource, {
    required String foreignKeyColumn,
    required dynamic foreignKeyValue,
  }) async {
    final relationName = _qualifiedName(dataSource.schema, dataSource.relation);
    final query = _client
        .from(relationName)
        .select()
        .eq(foreignKeyColumn, foreignKeyValue);
    if (dataSource.orderBy != null) {
      query.order(dataSource.orderBy!, ascending: dataSource.orderAscending);
    }
    final rows = await _withNetworkRetry(() async {
      final response = await query;
      return (response as List).cast<Map<String, dynamic>>();
    });
    return rows;
  }

  Future<Map<String, double>> fetchPedidoDetalleTotals(String pedidoId) async {
    final rows = await _withNetworkRetry(() async {
      final response = await _client
          .from('v_detallepedidos_ajustado')
          .select('idproducto,cantidad')
          .eq('idpedido', pedidoId);
      return (response as List).cast<Map<String, dynamic>>();
    });
    return _sumQuantityByProduct(rows);
  }

  Future<Map<String, double>> fetchMovimientoDetalleTotalsByPedido(
    String pedidoId,
  ) async {
    final rows = await _withNetworkRetry(() async {
      final response = await _client
          .from('detallemovimientopedidos')
          .select(
            'idproducto,cantidad,movimientopedidos!inner(idpedido),'
            'viajes_incidentes_detalle!left(cantidad)',
          )
          .eq('movimientopedidos.idpedido', pedidoId)
          .eq('movimientopedidos.estado', 'activo')
          .eq('estado', 'activo');
      return (response as List).cast<Map<String, dynamic>>();
    });
    final adjusted = rows.map((row) {
      double incidentTotal = 0;
      final incidentRows = row['viajes_incidentes_detalle'];
      if (incidentRows is List) {
        for (final entry in incidentRows) {
          final incidentQty = entry['cantidad'];
          final parsedIncident = incidentQty is num
              ? incidentQty.toDouble()
              : double.tryParse(incidentQty?.toString() ?? '') ?? 0;
          if (parsedIncident <= 0) continue;
          incidentTotal += parsedIncident;
        }
      }
      final originalQty = row['cantidad'];
      final parsedOriginal = originalQty is num
          ? originalQty.toDouble()
          : double.tryParse(originalQty?.toString() ?? '') ?? 0;
      final net = parsedOriginal - incidentTotal;
      return {
        ...row,
        'cantidad': net > 0 ? net : 0,
      };
    }).toList(growable: false);
    return _sumQuantityByProduct(adjusted);
  }

  Future<Map<String, dynamic>?> fetchViajeDevueltoByDetalleId(
    String viajeDetalleId,
  ) async {
    if (viajeDetalleId.isEmpty) return null;
    final response = await _withNetworkRetry(() async {
      final query = _client
          .from('v_viajes_devueltos_vistageneral')
          .select()
          .eq('idviaje_detalle', viajeDetalleId)
          .order('registrado_at', ascending: false)
          .limit(1);
      final result = await query.maybeSingle();
      return result;
    });
    if (response == null) return null;
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>?> fetchViajeIncidenteById(
    String incidenteId,
  ) async {
    if (incidenteId.isEmpty) return null;
    final response = await _withNetworkRetry(() async {
      final query = _client
          .from('v_viajes_incidentes_vistageneral')
          .select()
          .eq('id', incidenteId)
          .limit(1);
      final result = await query.maybeSingle();
      return result;
    });
    if (response == null) return null;
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> createViajeIncidente({
    required String viajeDetalleId,
    required String tipo,
    String? observacion,
  }) async {
    final payload = <String, dynamic>{
      'idviaje_detalle': viajeDetalleId,
      'tipo': tipo,
    };
    if (observacion != null && observacion.trim().isNotEmpty) {
      payload['observacion'] = observacion.trim();
    }
    final response = await _withNetworkRetry(() async {
      final result = await _client
          .from('viajes_incidentes')
          .insert(payload)
          .select()
          .single();
      return result;
    });
    return Map<String, dynamic>.from(response as Map);
  }

  Future<void> deleteViajeIncidente(String incidenteId) async {
    if (incidenteId.isEmpty) return;
    await _withNetworkRetry(() async {
      await _client
          .from('viajes_incidentes')
          .delete()
          .eq('id', incidenteId);
    });
  }

  Future<void> deleteViajeDevuelto(String devueltoId) async {
    if (devueltoId.isEmpty) return;
    await _withNetworkRetry(() async {
      await _client
          .from('viajes_devueltos')
          .delete()
          .eq('id', devueltoId);
    });
  }

  Future<List<Map<String, dynamic>>> fetchMovimientoDetalleProductos(
    String movimientoId,
  ) async {
    if (movimientoId.isEmpty) return const [];
    final response = await _withNetworkRetry(() async {
      final rows = await _client
          .from('detallemovimientopedidos')
          .select('id,idproducto,cantidad')
          .eq('idmovimiento', movimientoId);
      return (rows as List).cast<Map<String, dynamic>>();
    });
    return response;
  }

  Future<void> ensureIncidenteDetalleRows(
    String incidenteId,
    List<Map<String, dynamic>> movimientoDetalles,
  ) async {
    if (incidenteId.isEmpty || movimientoDetalles.isEmpty) return;
    final existing = await _withNetworkRetry(() async {
      final rows = await _client
          .from('viajes_incidentes_detalle')
          .select('iddetalle_movimiento')
          .eq('idincidente', incidenteId);
      return (rows as List).cast<Map<String, dynamic>>();
    });
    final existingIds = existing
        .map((row) => row['iddetalle_movimiento']?.toString())
        .whereType<String>()
        .toSet();
    final payload = <Map<String, dynamic>>[];
    for (final detalle in movimientoDetalles) {
      final detalleId = detalle['id']?.toString();
      if (detalleId == null || existingIds.contains(detalleId)) continue;
      final cantidadValue = detalle['cantidad'];
      final cantidad = cantidadValue is num
          ? cantidadValue.toDouble()
          : double.tryParse(cantidadValue?.toString() ?? '') ?? 0;
      if (cantidad <= 0) continue;
      payload.add({
        'idincidente': incidenteId,
        'iddetalle_movimiento': detalleId,
        'cantidad': cantidad,
      });
    }
    if (payload.isEmpty) return;
    await _withNetworkRetry(() async {
      await _client.from('viajes_incidentes_detalle').insert(payload);
    });
  }

  Future<Map<String, double>> fetchCompraDetalleTotals(String compraId) async {
    final rows = await _withNetworkRetry(() async {
      final response = await _client
          .from('v_compras_detalle_vistageneral')
          .select('idproducto,cantidad')
          .eq('idcompra', compraId);
      return (response as List).cast<Map<String, dynamic>>();
    });
    return _sumQuantityByProduct(rows);
  }

  Future<Map<String, double>> fetchCompraMovimientoDetalleTotals(
    String compraId,
  ) async {
    final rows = await _withNetworkRetry(() async {
      final response = await _client
          .from('compras_movimiento_detalle')
          .select('idproducto,cantidad,compras_movimientos!inner(es_reversion)')
          .eq('compras_movimientos.idcompra', compraId);
      return (response as List).cast<Map<String, dynamic>>();
    });
    return _sumQuantityByProduct(
      rows,
      multiplier: (row) {
        final movement = row['compras_movimientos'];
        final isReversion =
            (movement is Map && movement['es_reversion'] == true);
        return isReversion ? -1 : 1;
      },
    );
  }

  Map<String, double> _sumQuantityByProduct(
    List<Map<String, dynamic>> rows, {
    double Function(Map<String, dynamic> row)? multiplier,
  }) {
    final totals = <String, double>{};
    for (final row in rows) {
      final productId = row['idproducto']?.toString();
      if (productId == null || productId.isEmpty) continue;
      final quantity = row['cantidad'];
      final parsed = quantity is num
          ? quantity.toDouble()
          : double.tryParse(quantity?.toString() ?? '') ?? 0;
      if (parsed == 0) continue;
      final factor = multiplier?.call(row) ?? 1;
      if (factor == 0) continue;
      totals[productId] = (totals[productId] ?? 0) + (parsed * factor);
    }
    return totals;
  }

  List<String> _normalizeFilterList(dynamic value) {
    if (value is Iterable) {
      return value
          .map((entry) => entry?.toString() ?? '')
          .where((entry) => entry.trim().isNotEmpty)
          .map((entry) => entry.trim())
          .toList();
    }
    final text = value?.toString() ?? '';
    if (text.trim().isEmpty) return const [];
    return text
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchStockDisponiblePorBase(
    String baseId,
  ) async {
    if (baseId.isEmpty) return const [];
    final now = DateTime.now();
    final cached = _baseStockCache[baseId];
    if (cached != null &&
        now.difference(cached.timestamp) <= _baseStockCacheTtl) {
      return _cloneRowList(cached.rows);
    }
    final rows = await _withNetworkRetry(() async {
      final response = await _client
          .from('v_stock_disponible_por_base')
          .select(
            'idbase,base_nombre,id,nombre,cantidad_disponible,costo_unitario',
          )
          .eq('idbase', baseId);
      return (response as List).cast<Map<String, dynamic>>();
    });
    final normalized = _cloneRowList(rows);
    _baseStockCache[baseId] = _CachedBaseStock(
      timestamp: now,
      rows: normalized,
    );
    return _cloneRowList(normalized);
  }

  Future<Map<String, String>> fetchProductNames(
    Iterable<String> productIds,
  ) async {
    final uniqueIds = productIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    if (uniqueIds.isEmpty) return const {};
    final pending = uniqueIds
        .where((id) => !_productNameCache.containsKey(id))
        .toSet();
    if (pending.isNotEmpty) {
      final rows = await _withNetworkRetry(() async {
        final response = await _client
            .from('productos')
            .select('id,nombre')
            .inFilter('id', pending.toList());
        return (response as List).cast<Map<String, dynamic>>();
      });
      for (final row in rows) {
        final id = row['id']?.toString();
        final name = row['nombre']?.toString();
        if (id == null || id.isEmpty || name == null || name.isEmpty) continue;
        _productNameCache[id] = name;
      }
    }
    final names = <String, String>{};
    for (final id in uniqueIds) {
      final cachedName = _productNameCache[id];
      if (cachedName != null && cachedName.isNotEmpty) {
        names[id] = cachedName;
      }
    }
    return names;
  }

  List<Map<String, dynamic>> _cloneRowList(
    List<Map<String, dynamic>> rows,
  ) {
    return rows
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }
}

class _CachedBaseStock {
  const _CachedBaseStock({
    required this.timestamp,
    required this.rows,
  });

  final DateTime timestamp;
  final List<Map<String, dynamic>> rows;
}
