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
    required Future<void> Function(String sectionId) refreshSection,
    required void Function(String message) showMessage,
    required VoidCallback syncSelectedPedidoRow,
  }) : _moduleRepository = moduleRepository,
       _movimientoCoverageService = movimientoCoverageService,
       _refreshSection = refreshSection,
       _showMessage = showMessage,
       _syncSelectedPedidoRow = syncSelectedPedidoRow;

  final ModuleRepository _moduleRepository;
  final MovimientoCoverageService _movimientoCoverageService;
  final Future<void> Function(String sectionId) _refreshSection;
  final void Function(String message) _showMessage;
  final VoidCallback _syncSelectedPedidoRow;

  Future<void> actualizarEstadoAdminBulk(
    List<TableRowData> rows,
    String targetEstado,
  ) async {
    if (rows.isEmpty) return;
    final actionable = rows
        .where((row) {
          final estadoGeneral =
              row['estado_general']?.toString().toLowerCase().trim();
          return estadoGeneral != 'cancelado';
        })
        .toList(growable: false);
    if (actionable.isEmpty) {
      _showMessage('Selecciona pedidos que aun no esten cancelados.');
      return;
    }
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final motivo = targetEstado == 'anulado_error'
        ? 'Anulado por error'
        : 'Cancelado por cliente';
    try {
      for (final row in actionable) {
        final id = row['id'];
        if (id == null) continue;
        await _moduleRepository.callRpc(
          'fn_pedidos_cancelar',
          params: {
            'p_idpedido': id,
            'p_estado_admin': targetEstado,
            'p_motivo': motivo,
            if (userId != null) 'p_usuario': userId,
          },
        );
        _movimientoCoverageService.invalidateCoverage(id.toString());
      }
      await _refreshSection('pedidos_tabla');
      _syncSelectedPedidoRow();
      final message = targetEstado == 'anulado_error'
          ? 'Pedido anulado por error.'
          : 'Pedido cancelado por el cliente.';
      _showMessage(message);
    } catch (error) {
      _showMessage('No se pudo cancelar el pedido: $error');
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
