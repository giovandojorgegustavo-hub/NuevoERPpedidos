import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';

/// Centraliza el estado específico de cada sección (datos cargados, overrides,
/// selección actual, modos de formulario, etc.) para evitar que `ShellPage`
/// manipule mapas globales dispersos.
class SectionStateController {
  final Map<String, SectionDataSource> _sectionDataSources = {};
  final Map<String, List<SectionField>> _sectionFields = {};
  final Map<String, List<TableRowData>> _sectionRows = {};
  final Map<String, List<TableColumnConfig>> _sectionColumns = {};
  final Set<String> _manualTableColumns = <String>{};
  final Map<String, Map<String, dynamic> Function(Map<String, dynamic>)>
      _rowTransformers = {};
  final Map<String, TableRowData?> _sectionSelectedRows = {};
  final Map<String, SectionFormMode> _sectionFormModes = {};
  final Map<String, List<DetailFieldOverride>> _detailFieldOverrides = {};
  final Map<String, String? Function(Map<String, dynamic>)>
      _detailSubtitleBuilders = {};
  final Map<String, List<InlineSectionConfig>> _inlineSectionOverrides = {};

  Map<String, SectionDataSource> get sectionDataSources => _sectionDataSources;
  Map<String, List<SectionField>> get sectionFields => _sectionFields;
  Map<String, List<TableRowData>> get sectionRows => _sectionRows;
  Map<String, List<TableColumnConfig>> get sectionColumns => _sectionColumns;
  Set<String> get manualTableColumns => _manualTableColumns;
  Map<String, Map<String, dynamic> Function(Map<String, dynamic>)>
      get rowTransformers => _rowTransformers;
  Map<String, TableRowData?> get sectionSelectedRows => _sectionSelectedRows;
  Map<String, SectionFormMode> get sectionFormModes => _sectionFormModes;
  Map<String, List<DetailFieldOverride>> get detailFieldOverrides =>
      _detailFieldOverrides;
  Map<String, String? Function(Map<String, dynamic>)>
      get detailSubtitleBuilders => _detailSubtitleBuilders;
  Map<String, List<InlineSectionConfig>> get inlineSectionOverrides =>
      _inlineSectionOverrides;

  void setSectionDataSources(Map<String, SectionDataSource> dataSources) {
    _sectionDataSources
      ..clear()
      ..addAll(dataSources);
  }

  void setSectionFields(Map<String, List<SectionField>> fields) {
    _sectionFields
      ..clear()
      ..addAll(fields);
  }

  void setRows(String sectionId, List<TableRowData> rows) {
    _sectionRows[sectionId] = _applyRowTransformations(
      sectionId,
      rows,
    );
  }

  void setColumns(String sectionId, List<TableColumnConfig> columns) {
    _sectionColumns[sectionId] = columns;
  }

  void markManualColumns(String sectionId) {
    _manualTableColumns.add(sectionId);
  }

  bool hasManualColumns(String sectionId) =>
      _manualTableColumns.contains(sectionId);

  void setRowTransformer(
    String sectionId,
    Map<String, dynamic> Function(Map<String, dynamic>) transformer,
  ) {
    _rowTransformers[sectionId] = transformer;
  }

  Map<String, dynamic> Function(Map<String, dynamic>)? transformerFor(
    String sectionId,
  ) {
    return _rowTransformers[sectionId];
  }

  TableRowData? selectedRow(String sectionId) =>
      _sectionSelectedRows[sectionId];

  void setSelectedRow(String sectionId, TableRowData row) {
    _sectionSelectedRows[sectionId] = row;
  }

  void clearSelectedRow(String sectionId) {
    _sectionSelectedRows.remove(sectionId);
  }

  SectionFormMode formMode(String sectionId) =>
      _sectionFormModes[sectionId] ?? SectionFormMode.edit;

  void setFormMode(String sectionId, SectionFormMode mode) {
    _sectionFormModes[sectionId] = mode;
  }

  void setDetailOverrides(
    String sectionId,
    List<DetailFieldOverride> overrides,
  ) {
    _detailFieldOverrides[sectionId] = overrides;
  }

  void setDetailSubtitleBuilder(
    String sectionId,
    String? Function(Map<String, dynamic>) builder,
  ) {
    _detailSubtitleBuilders[sectionId] = builder;
  }

  void setInlineOverrides(
    String sectionId,
    List<InlineSectionConfig> overrides,
  ) {
    _inlineSectionOverrides[sectionId] = overrides;
  }

  void clear() {
    _sectionDataSources.clear();
    _sectionFields.clear();
    _sectionRows.clear();
    _sectionColumns.clear();
    _manualTableColumns.clear();
    _rowTransformers.clear();
    _sectionSelectedRows.clear();
    _sectionFormModes.clear();
    _detailFieldOverrides.clear();
    _detailSubtitleBuilders.clear();
    _inlineSectionOverrides.clear();
  }

  List<TableRowData> _applyRowTransformations(
    String sectionId,
    List<TableRowData> rows,
  ) {
    if (rows.isEmpty) return rows;
    if (sectionId != 'viajes_detalle') return rows;
    rows.sort((a, b) {
      final codeA = _estadoPriority(a);
      final codeB = _estadoPriority(b);
      final compareCode = codeA.compareTo(codeB);
      if (compareCode != 0) return compareCode;
      final estadoA = (a['estado_detalle']?.toString() ?? '').toLowerCase();
      final estadoB = (b['estado_detalle']?.toString() ?? '').toLowerCase();
      return estadoA.compareTo(estadoB);
    });
    return rows;
  }

  int _estadoPriority(Map<String, dynamic> row) {
    final code = row['estado_detalle_codigo'];
    if (code is num) {
      return code.floor();
    }
    final key =
        row['estado_detalle_key']?.toString().toLowerCase().trim();
    final estado = (key != null && key.isNotEmpty)
        ? key
        : row['estado_detalle']
                ?.toString()
                .toLowerCase()
                .replaceAll(' ', '_') ??
            '';
    if (estado == 'en_camino') return 0;
    if (estado == 'llegado') return 1;
    if (estado == 'devuelto_pendiente') return 2;
    if (estado == 'devuelto_terminado') return 3;
    if (estado == 'incidente') return 4;
    return 9;
  }
}
