import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shared/form_view/form_view_template.dart';
import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/controllers/section_config_builders.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shell/section_action_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TableConfigBuilder', () {
    test('builds config with fallback columns and actions', () async {
      final state = SectionStateController();
      final dataSource = const SectionDataSource(
        sectionId: 'customers',
        listSchema: 'public',
        listRelation: 'customers',
        listIsView: true,
        formSchema: 'public',
        formRelation: 'customers',
        formIsView: false,
      );
      state.setSectionDataSources({'customers': dataSource});
      state.setRows('customers', [
        {'id': 1, 'name': 'Alice'},
      ]);
      final builder = TableConfigBuilder(
        sectionStateController: state,
        loadingSectionIdResolver: () => null,
        onRefresh: (sectionId) async {
          expect(sectionId, 'customers');
        },
        onRowSelected: (row) async {
          expect(row['name'], 'Alice');
        },
        onBulkDelete: (sectionId, rows) async {
          expect(sectionId, 'customers');
          expect(rows.length, 1);
        },
        onStartCreate: ([sectionId]) async {},
        actionController: _FakeSectionActionController(),
        columnsBuilder: (rows) => [
          const TableColumnConfig(key: 'name', label: 'Nombre'),
        ],
      );

      final config = builder.build(_moduleSection());
      expect(config, isNotNull);
      expect(config!.rows.length, 1);
      expect(config.columns.first.label, 'Nombre');
      config.onRefresh?.call();
      await config.rowTapAction?.onSelected(config.rows.take(1).toList());
      await config.bulkActions.first.onSelected(config.rows);
    });
  });

  group('DetailConfigBuilder', () {
    test('uses overrides and inline sections', () {
      final state = SectionStateController();
      state.setDetailOverrides('customers', const [
        DetailFieldOverride(label: 'Cliente', key: 'cliente'),
      ]);
      state.setDetailSubtitleBuilder(
        'customers',
        (row) => 'Cliente ${row['cliente']}',
      );
      state.setSelectedRow('customers', {'id': 1, 'cliente': 'Alice'});
      final builder = DetailConfigBuilder(
        sectionStateController: state,
        inlineSectionBuilder: (
          sectionId,
          row, {
          required bool forForm,
          SectionFormMode? formMode,
        }) =>
            const [InlineTableConfig(title: 'Inline', columns: [], rows: [])],
        columnLabelFormatter: (key) => key.toUpperCase(),
        detailValueFormatter: (key, value) => value?.toString() ?? '',
        handleDetailBack: () {},
        actionController: _FakeSectionActionController(),
      );

      final config = builder.build(_moduleSection());
      expect(config, isNotNull);
      expect(config!.fields.first.label, 'Cliente');
      expect(config.subtitle, 'Cliente Alice');
      expect(config.inlineSections.length, 1);
    });
  });

  group('FormConfigBuilder', () {
    test('builds form fields from metadata and references', () async {
      final state = SectionStateController();
      state.setSectionFields({
        'customers': const [
          SectionField(sectionId: 'customers', id: 'name', label: 'Nombre'),
          SectionField(
            sectionId: 'customers',
            id: 'status',
            label: 'Status',
            staticOptions: ['draft', 'final'],
          ),
        ],
      });
      final builder = _createFormBuilder(state);

      final config = builder.build(
        section: _moduleSection(),
        row: {'name': 'Alice'},
        mode: SectionFormMode.create,
      );
      expect(config, isNotNull);
      expect(config!.fields.length, 2);
      expect(config.fields.first.label, 'Nombre');
      expect(config.inlineTables.length, 1);
    });

    test('visibleWhen accepts multiple expected values', () async {
      final state = SectionStateController();
      state.setSectionFields({
        'customers': const [
          SectionField(sectionId: 'customers', id: 'tipo', label: 'Tipo'),
          SectionField(
            sectionId: 'customers',
            id: 'notas',
            label: 'Notas',
            visibleWhenField: 'tipo',
            visibleWhenEquals: 'ingreso,gasto',
          ),
        ],
      });
      final builder = _createFormBuilder(state);
      final config = builder.build(
        section: _moduleSection(),
        row: const {},
        mode: SectionFormMode.create,
      );
      expect(config, isNotNull);
      final notasField =
          config!.fields.firstWhere((field) => field.id == 'notas');
      final visibility = notasField.visibleWhen;
      expect(visibility, isNotNull);
      expect(visibility!({'tipo': 'ingreso'}), isTrue);
      expect(visibility({'tipo': 'gasto'}), isTrue);
      expect(visibility({'tipo': 'ajuste'}), isFalse);
    });
  });
}

FormConfigBuilder _createFormBuilder(SectionStateController state) =>
    FormConfigBuilder(
      sectionStateController: state,
      inlineLoader: (_, __) async {},
      inlineSectionBuilder: (
        sectionId,
        row, {
        required bool forForm,
        SectionFormMode? formMode,
      }) =>
          const [InlineTableConfig(title: 'Inline', columns: [], rows: [])],
      referenceOptionsResolver: (sectionId, fieldId) => const [
        ReferenceOption(value: '1', label: 'Cliente 1'),
      ],
      optionLabelFormatter: (value) => value.toUpperCase(),
      fieldTypeResolver: (field) => FormFieldType.text,
      dateFormatter: (value) => value,
      referenceHelperResolver: (sectionId, fieldId, value) => 'helper',
      referenceAddHandler: (field, sectionId) async =>
          const ReferenceOption(value: '2', label: 'Cliente 2'),
      columnsBuilder: (_) => const [],
      columnLabelFormatter: (key) => key,
      cancelHandler: (_) => () {},
      changedHandler: (_, __) {},
      submitHandler: (_) async {},
      referenceLoader: (_) async {},
      isMovementSection: (_) => false,
      movementContextPreparer: (_, __) {},
      shouldLoadInlineSections: (_, __) => false,
      formDraftValuesResolver: () => const <String, Map<String, String>>{},
    );

ModuleSection _moduleSection() =>
    const ModuleSection(id: 'customers', label: 'Clientes', icon: Icons.group);

class _FakeSectionActionController implements SectionActionController {
  @override
  Future<void> createRow(String sectionId) async {}

  @override
  Future<void> createRowInCurrentSection() async {}

  @override
  Future<void> editCurrentRow(TableRowData row) async {}

  @override
  Future<void> editRow(String sectionId, TableRowData row) async {}

  @override
  Future<void> showCurrentDetail(TableRowData row) async {}

  @override
  Future<void> showCurrentTable() async {}

  @override
  Future<void> showDetail(String sectionId, TableRowData row) async {}

  @override
  Future<void> showTable(String sectionId) async {}
}
