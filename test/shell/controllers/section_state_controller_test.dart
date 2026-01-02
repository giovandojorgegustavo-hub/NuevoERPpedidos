import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/controllers/section_state_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SectionStateController', () {
    late SectionStateController controller;

    setUp(() {
      controller = SectionStateController();
    });

    test('stores and retrieves data sources, fields and rows', () {
      final source = SectionDataSource(
        sectionId: 'customers',
        listSchema: 'public',
        listRelation: 'customers',
        listIsView: true,
        formSchema: 'public',
        formRelation: 'customers',
        formIsView: false,
      );
      controller.setSectionDataSources({'customers': source});
      controller.setSectionFields({
        'customers': const [
          SectionField(sectionId: 'customers', id: 'name', label: 'Name'),
        ],
      });
      controller.setRows('customers', [
        {'id': 1, 'name': 'Alice'},
      ]);
      expect(controller.sectionDataSources['customers'], equals(source));
      expect(controller.sectionFields['customers']!.length, 1);
      expect(controller.sectionRows['customers']!.first['name'], 'Alice');
    });

    test('marks manual columns and row transformers', () {
      controller.markManualColumns('orders');
      expect(controller.hasManualColumns('orders'), isTrue);
      controller.setRowTransformer('orders', (row) => {...row, 'extra': 1});
      final transformer = controller.transformerFor('orders');
      expect(transformer, isNotNull);
      expect(transformer!({'id': 1})['extra'], 1);
    });

    test('selected rows and form modes persist per section', () {
      controller.setSelectedRow('orders', {'id': 10});
      expect(controller.selectedRow('orders')!['id'], 10);
      controller.setFormMode('orders', SectionFormMode.create);
      expect(controller.formMode('orders'), SectionFormMode.create);
      controller.clearSelectedRow('orders');
      expect(controller.selectedRow('orders'), isNull);
    });

    test('detail overrides and inline overrides are stored', () {
      controller.setDetailOverrides(
        'orders',
        [const DetailFieldOverride(label: 'Cliente', key: 'cliente')],
      );
      controller.setInlineOverrides(
        'orders',
        const [InlineSectionConfig(id: 'lines', title: 'Lines', dataSource: InlineSectionDataSource(schema: 'public', relation: 'lines'), foreignKeyColumn: 'order_id', columns: [])],
      );
      controller.setDetailSubtitleBuilder('orders', (row) => 'Test ${row['id']}');
      expect(controller.detailFieldOverrides['orders']!.first.label, 'Cliente');
      expect(controller.inlineSectionOverrides['orders']!.first.id, 'lines');
      expect(controller.detailSubtitleBuilders['orders']!(const {'id': 1}), 'Test 1');
    });

    test('clear removes all stored state', () {
      controller.setSectionDataSources({});
      controller.setSectionFields({});
      controller.setRows('orders', []);
      controller.markManualColumns('orders');
      controller.setSelectedRow('orders', {'id': 1});
      controller.setFormMode('orders', SectionFormMode.create);
      controller.clear();
      expect(controller.sectionDataSources, isEmpty);
      expect(controller.sectionFields, isEmpty);
      expect(controller.sectionRows, isEmpty);
      expect(controller.sectionSelectedRows, isEmpty);
      expect(controller.sectionFormModes, isEmpty);
      expect(controller.manualTableColumns, isEmpty);
    });
  });
}
