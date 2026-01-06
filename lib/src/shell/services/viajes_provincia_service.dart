import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shared/utils/date_time_utils.dart'
    as date_time_utils;
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/services/module_repository.dart';

class ViajesProvinciaService {
  ViajesProvinciaService({
    required ModuleRepository moduleRepository,
    required Map<String, SectionDataSource> Function()
        sectionDataSourcesResolver,
    required Future<void> Function(String sectionId) refreshSection,
    required void Function(String message) showMessage,
  }) : _moduleRepository = moduleRepository,
       _sectionDataSourcesResolver = sectionDataSourcesResolver,
       _refreshSection = refreshSection,
       _showMessage = showMessage;

  final ModuleRepository _moduleRepository;
  final Map<String, SectionDataSource> Function() _sectionDataSourcesResolver;
  final Future<void> Function(String sectionId) _refreshSection;
  final void Function(String message) _showMessage;

  Future<void> marcarLlegada(List<TableRowData> rows) async {
    if (rows.isEmpty) return;
    final dataSource = _sectionDataSourcesResolver()['viajes_provincia'];
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
      await _refreshSection('viajes_provincia');
      await _refreshSection('movimientos');
      await _refreshSection('pedidos_tabla');
      _showMessage('Llegada registrada.');
    } catch (error) {
      _showMessage('No se pudo marcar la llegada: $error');
    }
  }

  Future<void> revertirLlegada(List<TableRowData> rows) async {
    if (rows.isEmpty) return;
    final dataSource = _sectionDataSourcesResolver()['viajes_provincia'];
    if (dataSource == null) return;
    try {
      for (final row in rows) {
        final id = row['id'];
        if (id == null) continue;
        await _moduleRepository.updateRow(dataSource, id, {
          'llegada_at': null,
        });
      }
      await _refreshSection('viajes_provincia');
      await _refreshSection('movimientos');
      await _refreshSection('pedidos_tabla');
      _showMessage('Llegada revertida.');
    } catch (error) {
      _showMessage('No se pudo revertir la llegada: $error');
    }
  }

  Future<void> cancelar(List<TableRowData> rows) async {
    if (rows.isEmpty) return;
    final dataSource = _sectionDataSourcesResolver()['viajes_provincia'];
    if (dataSource == null) return;
    final ids = rows.map((row) => row['id']).whereType<Object>().toList();
    if (ids.isEmpty) return;
    try {
      await _moduleRepository.deleteRows(dataSource, ids);
      await _refreshSection('viajes_provincia');
      await _refreshSection('movimientos');
      await _refreshSection('pedidos_tabla');
      _showMessage('Viaje provincia cancelado.');
    } catch (error) {
      _showMessage('No se pudo cancelar el viaje provincia: $error');
    }
  }
}
