import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/services/pedidos_admin_service.dart';
import 'package:erp_app/src/shell/services/viajes_detalle_service.dart';
import 'package:erp_app/src/shell/services/viajes_provincia_service.dart';
import 'package:flutter/material.dart';

class SectionTableActionBuilder {
  SectionTableActionBuilder({
    required ViajesDetalleService viajesDetalleService,
    required ViajesProvinciaService viajesProvinciaService,
    required PedidosAdminService pedidosAdminService,
    required void Function(String message) showMessage,
  }) : _viajesDetalleService = viajesDetalleService,
       _viajesProvinciaService = viajesProvinciaService,
       _pedidosAdminService = pedidosAdminService,
       _showMessage = showMessage;

  final ViajesDetalleService _viajesDetalleService;
  final ViajesProvinciaService _viajesProvinciaService;
  final PedidosAdminService _pedidosAdminService;
  final void Function(String message) _showMessage;

  TableViewConfig build(ModuleSection? section, TableViewConfig baseConfig) {
    if (section == null) return baseConfig;
    if (section.id == 'viajes_detalle') {
      final TableAction marcarLlegada = TableAction(
        label: 'Marcar llegada',
        icon: Icons.check_circle_outline,
        onSelected: (rows) async {
          final filtered = rows
              .where((row) {
                final state = _detalleState(row);
                return state.isEmpty || state == 'en_camino';
              })
              .toList(growable: false);
          if (filtered.isEmpty) {
            _showMessage(
              'Solo puedes marcar llegada para movimientos en camino.',
            );
            return;
          }
          await _viajesDetalleService.marcarLlegada(filtered);
        },
        isVisible: (rows) => _everyState(
          rows,
          (state) => state.isEmpty || state == 'en_camino',
        ),
      );
      final TableAction marcarDevuelto = TableAction(
        label: 'Marcar devuelto',
        icon: Icons.undo_outlined,
        onSelected: (rows) async {
          if (rows.length != 1) {
            _showMessage('Selecciona un único movimiento para devolver.');
            return;
          }
          final row = rows.first;
          final state = _detalleState(row);
          final canReturn = state == 'en_camino';
          if (!canReturn) {
            _showMessage(
              'Solo puedes devolver movimientos en camino. '
              'Si ya llegaron, usa "No llegó" para revertir la llegada.',
            );
            return;
          }
          await _viajesDetalleService.marcarDevuelto(row);
        },
        isVisible: (rows) =>
            _everyState(rows, (state) => state == 'en_camino'),
      );
      final TableAction deshacerDevuelto = TableAction(
        label: 'Deshacer devuelto',
        icon: Icons.undo,
        onSelected: (rows) async {
          if (rows.length != 1) {
            _showMessage('Selecciona un único movimiento para revertir.');
            return;
          }
          final row = rows.first;
          final state = _detalleState(row);
          if (state != 'devuelto_pendiente') {
            _showMessage('Solo puedes deshacer devoluciones pendientes.');
            return;
          }
          await _viajesDetalleService.deshacerDevuelto(row);
        },
        isVisible: (rows) =>
            rows.length == 1 &&
            _everyState(rows, (state) => state == 'devuelto_pendiente'),
      );
      final TableAction revertirLlegada = TableAction(
        label: 'No llegó',
        icon: Icons.restore_outlined,
        onSelected: (rows) async {
          final filtered = rows
              .where((row) => _detalleState(row) == 'llegado')
              .toList(growable: false);
          if (filtered.isEmpty) {
            _showMessage(
              'Solo puedes revertir la llegada de movimientos marcados como llegados.',
            );
            return;
          }
          await _viajesDetalleService.revertirLlegada(filtered);
        },
        isVisible: (rows) => _everyState(rows, (state) => state == 'llegado'),
      );
      final TableAction marcarIncidente = TableAction(
        label: 'Marcar robado/dañado',
        icon: Icons.warning_amber_outlined,
        onSelected: (rows) async {
          if (rows.length != 1) {
            _showMessage(
              'Selecciona un único movimiento para registrar el incidente.',
            );
            return;
          }
          final row = rows.first;
          final state = _detalleState(row);
          if (state != 'en_camino') {
            _showMessage(
              'Solo puedes marcar robado/dañado movimientos en camino. '
              'Si ya llegaron, usa "No llegó" para revertir primero la llegada.',
            );
            return;
          }
          await _viajesDetalleService.marcarIncidente(row);
        },
        isVisible: (rows) =>
            rows.length == 1 &&
            _everyState(rows, (state) => state == 'en_camino'),
      );
      final TableAction revertirIncidente = TableAction(
        label: 'Revertir incidente',
        icon: Icons.settings_backup_restore_outlined,
        onSelected: (rows) async {
          final actionable = rows
              .where(
                (row) => (row['incidente_id']?.toString().isNotEmpty ?? false),
              )
              .toList(growable: false);
          if (actionable.isEmpty) {
            _showMessage('Selecciona movimientos con incidentes registrados.');
            return;
          }
          await _viajesDetalleService.revertirIncidente(actionable);
        },
        isVisible: (rows) => _allConIncidente(rows),
      );

      final bulkActions = [
        ...baseConfig.bulkActions,
        marcarLlegada,
        revertirLlegada,
        marcarDevuelto,
        deshacerDevuelto,
        marcarIncidente,
        revertirIncidente,
      ];

      return TableViewConfig(
        title: baseConfig.title,
        description: baseConfig.description,
        columns: baseConfig.columns,
        rows: baseConfig.rows,
        initialSort: baseConfig.initialSort,
        groupByColumn: baseConfig.groupByColumn,
        rowActions: baseConfig.rowActions,
        bulkActions: bulkActions,
        primaryAction: null,
        rowTapAction: baseConfig.rowTapAction,
        onRefresh: baseConfig.onRefresh,
        emptyPlaceholder: baseConfig.emptyPlaceholder,
      );
    }

    if (section.id == 'viajes_provincia') {
      final TableAction marcarLlegada = TableAction(
        label: 'Llegó',
        icon: Icons.check_circle_outline,
        onSelected: (rows) async {
          final filtered = rows
              .where((row) {
                final state = _detalleState(row);
                return state.isEmpty || state == 'en_camino';
              })
              .toList(growable: false);
          if (filtered.isEmpty) {
            _showMessage('Solo puedes marcar llegada en movimientos en camino.');
            return;
          }
          await _viajesProvinciaService.marcarLlegada(filtered);
        },
        isVisible: (rows) => _everyState(
          rows,
          (state) => state.isEmpty || state == 'en_camino',
        ),
      );
      final TableAction revertirLlegada = TableAction(
        label: 'No llegó',
        icon: Icons.restore_outlined,
        onSelected: (rows) async {
          final filtered = rows
              .where((row) => _detalleState(row) == 'llegado')
              .toList(growable: false);
          if (filtered.isEmpty) {
            _showMessage(
              'Solo puedes revertir llegadas marcadas.',
            );
            return;
          }
          await _viajesProvinciaService.revertirLlegada(filtered);
        },
        isVisible: (rows) => _everyState(rows, (state) => state == 'llegado'),
      );
      final TableAction cancelar = TableAction(
        label: 'Cancelar',
        icon: Icons.cancel_outlined,
        onSelected: (rows) async {
          final filtered = rows
              .where((row) => _detalleState(row) == 'en_camino')
              .toList(growable: false);
          if (filtered.isEmpty) {
            _showMessage(
              'Solo puedes cancelar viajes en camino. '
              'Si ya llegaron, usa "No llegó" primero.',
            );
            return;
          }
          await _viajesProvinciaService.cancelar(filtered);
        },
        isVisible: (rows) =>
            _everyState(rows, (state) => state == 'en_camino'),
      );

      final filteredBulkActions = baseConfig.bulkActions
          .where((action) => action.label != 'Eliminar')
          .toList(growable: false);
      final bulkActions = [
        ...filteredBulkActions,
        marcarLlegada,
        revertirLlegada,
        cancelar,
      ];

      return TableViewConfig(
        title: baseConfig.title,
        description: baseConfig.description,
        columns: baseConfig.columns,
        rows: baseConfig.rows,
        initialSort: baseConfig.initialSort,
        groupByColumn: baseConfig.groupByColumn,
        rowActions: baseConfig.rowActions,
        bulkActions: bulkActions,
        primaryAction: baseConfig.primaryAction,
        rowTapAction: baseConfig.rowTapAction,
        onRefresh: baseConfig.onRefresh,
        emptyPlaceholder: baseConfig.emptyPlaceholder,
      );
    }

    if (section.id == 'pedidos_tabla') {
      final TableAction cancelarPedido = TableAction(
        label: 'Cancelar',
        icon: Icons.cancel_outlined,
        onSelected: (rows) =>
            _pedidosAdminService.actualizarEstadoAdminBulk(
          rows,
          'cancelado_cliente',
        ),
      );
      final filteredBulkActions = baseConfig.bulkActions
          .where((action) => action.label != 'Eliminar')
          .toList(growable: false);
      final bulkActions = [
        ...filteredBulkActions,
        cancelarPedido,
      ];
      return TableViewConfig(
        title: baseConfig.title,
        description: baseConfig.description,
        columns: baseConfig.columns,
        rows: baseConfig.rows,
        initialSort: baseConfig.initialSort,
        groupByColumn: baseConfig.groupByColumn,
        rowActions: baseConfig.rowActions,
        bulkActions: bulkActions,
        primaryAction: baseConfig.primaryAction,
        rowTapAction: baseConfig.rowTapAction,
        onRefresh: baseConfig.onRefresh,
        emptyPlaceholder: baseConfig.emptyPlaceholder,
      );
    }

    if (section.id == 'viajes_devueltos') {
      final TableAction revertirDevuelto = TableAction(
        label: 'Revertir devolucion',
        icon: Icons.undo,
        onSelected: (rows) async {
          if (rows.isEmpty) {
            _showMessage('Selecciona devoluciones a revertir.');
            return;
          }
          await _viajesDetalleService.revertirDevolucion(rows);
        },
      );
      final TableAction devueltoBase = TableAction(
        label: 'Devuelto a base',
        icon: Icons.local_shipping_outlined,
        onSelected: (rows) async {
          final actionable = rows
              .where((row) {
                final estado = row['estado']?.toString() ?? 'pendiente';
                return estado != 'devuelto_base';
              })
              .toList(growable: false);
          if (actionable.isEmpty) {
            _showMessage(
              'Selecciona devoluciones que aún no han llegado a la base.',
            );
            return;
          }
          await _viajesDetalleService.actualizarEstadoDevuelto(
            actionable,
            estado: 'devuelto_base',
            timestampField: 'devuelto_recibido_at',
            successMessage: 'Devolución completada en base.',
          );
        },
      );

      final bulkActions = [
        ...baseConfig.bulkActions,
        revertirDevuelto,
        devueltoBase,
      ];
      return TableViewConfig(
        title: baseConfig.title,
        description: baseConfig.description,
        columns: baseConfig.columns,
        rows: baseConfig.rows,
        initialSort: baseConfig.initialSort,
        groupByColumn: baseConfig.groupByColumn,
        rowActions: baseConfig.rowActions,
        bulkActions: bulkActions,
        primaryAction: null,
        rowTapAction: baseConfig.rowTapAction,
        onRefresh: baseConfig.onRefresh,
        emptyPlaceholder: baseConfig.emptyPlaceholder,
      );
    }

    return baseConfig;
  }

  String _detalleState(TableRowData row) {
    final key = row['estado_detalle_key']?.toString().trim().toLowerCase();
    if (key != null && key.isNotEmpty) return key;
    final raw = row['estado_detalle']?.toString() ?? '';
    return raw.trim().toLowerCase().replaceAll(' ', '_');
  }

  bool _everyState(
    List<TableRowData> rows,
    bool Function(String state) predicate,
  ) {
    if (rows.isEmpty) return false;
    for (final row in rows) {
      if (!predicate(_detalleState(row))) return false;
    }
    return true;
  }

  bool _allConIncidente(List<TableRowData> rows) {
    if (rows.isEmpty) return false;
    for (final row in rows) {
      final incidente = row['incidente_id']?.toString().trim();
      if (incidente == null || incidente.isEmpty) return false;
    }
    return true;
  }
}
