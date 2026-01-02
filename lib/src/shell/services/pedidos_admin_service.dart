import 'dart:async';

import 'package:erp_app/src/domains/movimientos/movimiento_coverage_service.dart';
import 'package:erp_app/src/shared/detail_view/detail_view_template.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PedidosAdminService {
  PedidosAdminService({
    required ModuleRepository moduleRepository,
    required MovimientoCoverageService movimientoCoverageService,
    required SectionDataSource? Function() pedidosDataSourceResolver,
    required Future<void> Function(String sectionId) refreshSection,
    required void Function(String message) showMessage,
    required VoidCallback syncSelectedPedidoRow,
  }) : _moduleRepository = moduleRepository,
       _movimientoCoverageService = movimientoCoverageService,
       _pedidosDataSourceResolver = pedidosDataSourceResolver,
       _refreshSection = refreshSection,
       _showMessage = showMessage,
       _syncSelectedPedidoRow = syncSelectedPedidoRow;

  final ModuleRepository _moduleRepository;
  final MovimientoCoverageService _movimientoCoverageService;
  final SectionDataSource? Function() _pedidosDataSourceResolver;
  final Future<void> Function(String sectionId) _refreshSection;
  final void Function(String message) _showMessage;
  final VoidCallback _syncSelectedPedidoRow;

  Future<void> actualizarEstadoAdminBulk(
    List<TableRowData> rows,
    String targetEstado,
  ) async {
    if (rows.isEmpty) return;
    final dataSource = _pedidosDataSourceResolver();
    if (dataSource == null) return;
    final actionable = rows
        .where((row) {
          final current = row['estado_admin']?.toString() ?? 'activo';
          return current != targetEstado;
        })
        .toList(growable: false);
    if (actionable.isEmpty) {
      _showMessage('Selecciona pedidos con un estado diferente.');
      return;
    }
    final userId = Supabase.instance.client.auth.currentUser?.id;
    try {
      for (final row in actionable) {
        final id = row['id'];
        if (id == null) continue;
        final payload = <String, dynamic>{
          'estado_admin': targetEstado,
          if (userId != null) 'editado_por': userId,
        };
        await _moduleRepository.updateRow(dataSource, id, payload);
        _movimientoCoverageService.invalidateCoverage(id.toString());
      }
      await _refreshSection('pedidos_tabla');
      _syncSelectedPedidoRow();
      final message = targetEstado == 'anulado_error'
          ? 'Pedido marcado como anulado por error.'
          : 'Pedido marcado como cancelado por el cliente.';
      _showMessage(message);
    } catch (error) {
      _showMessage('No se pudo actualizar el estado del pedido: $error');
    }
  }

  List<DetailActionConfig> buildDetailActions(TableRowData? row) {
    if (row == null) return const [];
    return [
      DetailActionConfig(
        label: 'Anular por error',
        icon: Icons.report_gmailerrorred_outlined,
        onPressed: () {
          unawaited(actualizarEstadoAdminBulk([row], 'anulado_error'));
        },
      ),
      DetailActionConfig(
        label: 'Cancelar cliente',
        icon: Icons.person_off_outlined,
        onPressed: () {
          unawaited(actualizarEstadoAdminBulk([row], 'cancelado_cliente'));
        },
      ),
    ];
  }
}
