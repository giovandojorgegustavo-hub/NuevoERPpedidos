import 'dart:async';

import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shared/utils/date_time_utils.dart'
    as date_time_utils;
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/section_action_controller.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';

class ViajesDetalleService {
  ViajesDetalleService({
    required ModuleRepository moduleRepository,
    required SectionActionController sectionActionController,
    required Map<String, SectionDataSource> Function()
        sectionDataSourcesResolver,
    required Future<void> Function(String sectionId) refreshSection,
    required void Function(String message) showMessage,
  }) : _moduleRepository = moduleRepository,
       _sectionActionController = sectionActionController,
       _sectionDataSourcesResolver = sectionDataSourcesResolver,
       _refreshSection = refreshSection,
       _showMessage = showMessage;

  final ModuleRepository _moduleRepository;
  final SectionActionController _sectionActionController;
  final Map<String, SectionDataSource> Function() _sectionDataSourcesResolver;
  final Future<void> Function(String sectionId) _refreshSection;
  final void Function(String message) _showMessage;
  final Set<String> _pendingViajeIncidenteIds = <String>{};

  Future<void> marcarLlegada(List<TableRowData> rows) async {
    if (rows.isEmpty) return;
    final dataSource = _sectionDataSourcesResolver()['viajes_detalle'];
    if (dataSource == null) return;
    final nowIso = date_time_utils.currentUtcIsoString();
    try {
      for (final row in rows) {
        final id = row['id'];
        if (id == null) continue;
        await _moduleRepository.updateRow(dataSource, id, {
          'llegada_at': nowIso,
        });
      }
      await _refreshSection('viajes_detalle');
      await _refreshSection('viajes');
      _showMessage('Llegada registrada.');
    } catch (error) {
      _showMessage('No se pudo marcar la llegada: $error');
    }
  }

  Future<void> marcarDevuelto(TableRowData row) async {
    final dataSource = _sectionDataSourcesResolver()['viajes_detalle'];
    if (dataSource == null) return;
    final id = row['id'];
    if (id == null) return;
    final nowIso = date_time_utils.currentUtcIsoString();
    try {
      await _moduleRepository.updateRow(dataSource, id, {
        'devuelto_solicitado_at': nowIso,
      });
      await _refreshSection('viajes_detalle');
      await _refreshSection('viajes');
      await _refreshSection('pedidos_tabla');
      if (_sectionDataSourcesResolver().containsKey('viajes_devueltos')) {
        await _refreshSection('viajes_devueltos');
      }
      final devueltoRow =
          await _moduleRepository.fetchViajeDevueltoByDetalleId(
        id.toString(),
      );
      if (devueltoRow != null) {
        await _sectionActionController.editRow(
          'viajes_devueltos',
          devueltoRow,
        );
        _showMessage('Devolución registrada, completa los datos.');
      } else {
        _showMessage('Devolución registrada.');
      }
    } catch (error) {
      _showMessage('No se pudo registrar la devolución: $error');
    }
  }

  Future<void> deshacerDevuelto(TableRowData row) async {
    final dataSource = _sectionDataSourcesResolver()['viajes_detalle'];
    if (dataSource == null) return;
    final detalleId = row['id']?.toString();
    if (detalleId == null) return;
    final devueltoId = row['devuelto_id']?.toString();
    try {
      await _moduleRepository.updateRow(dataSource, detalleId, {
        'devuelto_solicitado_at': null,
      });
      if (devueltoId != null && devueltoId.isNotEmpty) {
        await _moduleRepository.deleteViajeDevuelto(devueltoId);
      }
      await _refreshSection('viajes_detalle');
      await _refreshSection('viajes');
      await _refreshSection('pedidos_tabla');
      if (_sectionDataSourcesResolver().containsKey('viajes_devueltos')) {
        await _refreshSection('viajes_devueltos');
      }
      _showMessage('Devolución revertida.');
    } catch (error) {
      _showMessage('No se pudo deshacer la devolución: $error');
    }
  }

  Future<void> revertirLlegada(List<TableRowData> rows) async {
    if (rows.isEmpty) return;
    final dataSource = _sectionDataSourcesResolver()['viajes_detalle'];
    if (dataSource == null) return;
    try {
      for (final row in rows) {
        final id = row['id'];
        if (id == null) continue;
        await _moduleRepository.updateRow(dataSource, id, {
          'llegada_at': null,
        });
      }
      await _refreshSection('viajes_detalle');
      await _refreshSection('viajes');
      _showMessage('Llegada revertida.');
    } catch (error) {
      _showMessage('No se pudo revertir la llegada: $error');
    }
  }

  Future<void> marcarIncidente(TableRowData row) async {
    final dataSource = _sectionDataSourcesResolver()['viajes_detalle'];
    if (dataSource == null) return;
    final detalleId = row['id']?.toString();
    final movimientoId = row['idmovimiento']?.toString();
    if (detalleId == null || movimientoId == null) {
      _showMessage('No se encontró el movimiento seleccionado.');
      return;
    }
    final existingIncidente = row['incidente_id']?.toString();
    if (existingIncidente != null && existingIncidente.isNotEmpty) {
      _showMessage('El movimiento ya tiene un incidente registrado.');
      return;
    }
    try {
      final estado = (row['estado_detalle']?.toString() ?? '').trim();
      if (estado == 'llegado') {
        await _moduleRepository.updateRow(dataSource, detalleId, {
          'llegada_at': null,
        });
      }
      final incidente = await _moduleRepository.createViajeIncidente(
        viajeDetalleId: detalleId,
        tipo: 'robado',
      );
      final incidenteId = incidente['id']?.toString();
      if (incidenteId == null) {
        _showMessage('No se pudo registrar el incidente.');
        return;
      }
      final detalleProductos =
          await _moduleRepository.fetchMovimientoDetalleProductos(
        movimientoId,
      );
      await _moduleRepository.ensureIncidenteDetalleRows(
        incidenteId,
        detalleProductos,
      );
      final incidenteRow =
          await _moduleRepository.fetchViajeIncidenteById(incidenteId);
      if (incidenteRow != null) {
        _pendingViajeIncidenteIds.add(incidenteId);
        await _sectionActionController.editRow(
          'viajes_incidentes',
          incidenteRow,
        );
        _showMessage(
          'Incidente registrado, completa el formulario y ajusta el detalle.',
        );
      } else {
        _showMessage(
          'Incidente registrado. Revisa la sección "Viajes incidentes" para completar los datos.',
        );
      }
      unawaited(_refreshIncidenteSections());
    } catch (error) {
      _showMessage('No se pudo registrar el incidente: $error');
    }
  }

  Future<void> revertirIncidente(List<TableRowData> rows) async {
    if (rows.isEmpty) return;
    final incidenteIds = rows
        .map((row) => row['incidente_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    if (incidenteIds.isEmpty) {
      _showMessage('No se seleccionaron incidentes a revertir.');
      return;
    }
    try {
      for (final incidenteId in incidenteIds) {
        _pendingViajeIncidenteIds.remove(incidenteId);
        await _moduleRepository.deleteViajeIncidente(incidenteId);
      }
      await _refreshIncidenteSections();
      _showMessage('Incidente revertido.');
    } catch (error) {
      _showMessage('No se pudo revertir el incidente: $error');
    }
  }

  Future<void> actualizarEstadoDevuelto(
    List<TableRowData> rows, {
    required String estado,
    required String timestampField,
    required String successMessage,
  }) async {
    if (rows.isEmpty) return;
    final dataSource = _sectionDataSourcesResolver()['viajes_devueltos'];
    if (dataSource == null) return;
    final nowIso = date_time_utils.currentUtcIsoString();
    try {
      for (final row in rows) {
        final id = row['id'];
        if (id == null) continue;
        await _moduleRepository.updateRow(dataSource, id, {
          'estado': estado,
          timestampField: nowIso,
        });
      }
      await _refreshSection('viajes_devueltos');
      await _refreshSection('pedidos_tabla');
      _showMessage(successMessage);
    } catch (error) {
      _showMessage('No se pudo actualizar el estado: $error');
    }
  }

  void marcarIncidenteGuardado(String? incidenteId) {
    final id = incidenteId?.trim();
    if (id == null || id.isEmpty) return;
    _pendingViajeIncidenteIds.remove(id);
  }

  Future<void> cancelarIncidentePendiente(String? incidenteId) async {
    final id = incidenteId?.trim();
    if (id == null || id.isEmpty) return;
    if (!_pendingViajeIncidenteIds.remove(id)) return;
    await _cancelarIncidentePendiente(id);
  }

  Future<void> _refreshIncidenteSections() async {
    await _refreshSection('viajes_detalle');
    await _refreshSection('viajes');
    await _refreshSection('pedidos_tabla');
    if (_sectionDataSourcesResolver().containsKey('viajes_incidentes')) {
      await _refreshSection('viajes_incidentes');
    }
  }

  Future<void> _cancelarIncidentePendiente(String incidenteId) async {
    try {
      await _moduleRepository.deleteViajeIncidente(incidenteId);
      await _refreshIncidenteSections();
      _showMessage('Incidente cancelado.');
    } catch (error) {
      _showMessage('No se pudo cancelar el incidente: $error');
    }
  }
}
