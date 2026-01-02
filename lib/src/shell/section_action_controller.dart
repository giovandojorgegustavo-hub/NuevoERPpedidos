import 'package:erp_app/src/shared/table_view/table_view_template.dart';

/// Permite que las acciones propias de cada tabla controlen la navegación
/// dentro del shell sin depender directamente del estado interno.
abstract class SectionActionController {
  Future<void> showTable(String sectionId);

  Future<void> showCurrentTable();

  Future<void> showDetail(String sectionId, TableRowData row);

  Future<void> showCurrentDetail(TableRowData row);

  Future<void> editRow(String sectionId, TableRowData row);

  Future<void> editCurrentRow(TableRowData row);

  Future<void> createRow(String sectionId);

  Future<void> createRowInCurrentSection();
}
