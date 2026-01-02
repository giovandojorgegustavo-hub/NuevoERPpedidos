import 'package:erp_app/src/shared/inline_table/inline_validation.dart';
import 'package:erp_app/src/shared/inline_table/inline_pending_row.dart';
import 'package:flutter_test/flutter_test.dart';

InlinePendingRow _pendingRow(String pendingId, Map<String, dynamic> rawValues) {
  return InlinePendingRow(
    rawValues: rawValues,
    displayValues: const {},
    tableValues: const {},
    pendingId: pendingId,
  );
}

void main() {
  group('isInlineValueDuplicated', () {
    test('detects duplicates in persisted rows', () {
      final duplicated = isInlineValueDuplicated(
        persistedRows: const [
          {'id': 1, 'idproducto': '10'},
        ],
        pendingRows: const [],
        fieldName: 'idproducto',
        value: '10',
      );

      expect(duplicated, isTrue);
    });

    test('respects excludeRowId for persisted rows', () {
      final duplicated = isInlineValueDuplicated(
        persistedRows: const [
          {'id': 1, 'idproducto': '10'},
        ],
        pendingRows: const [],
        fieldName: 'idproducto',
        value: '10',
        excludeRowId: 1,
      );

      expect(duplicated, isFalse);
    });

    test('detects duplicates in pending rows and respects exclusion', () {
      final pendingRows = [
        _pendingRow('p1', {'idproducto': '20'}),
      ];

      final duplicated = isInlineValueDuplicated(
        persistedRows: const [],
        pendingRows: pendingRows,
        fieldName: 'idproducto',
        value: '20',
      );

      expect(duplicated, isTrue);

      final excluded = isInlineValueDuplicated(
        persistedRows: const [],
        pendingRows: pendingRows,
        fieldName: 'idproducto',
        value: '20',
        excludePendingId: 'p1',
      );

      expect(excluded, isFalse);
    });
  });

  group('validateInlineRequired', () {
    test('returns message for null or empty values', () {
      expect(
        validateInlineRequired(null, 'required'),
        equals('required'),
      );
      expect(
        validateInlineRequired('   ', 'required'),
        equals('required'),
      );
    });

    test('returns null for non-empty values', () {
      expect(validateInlineRequired('ok', 'required'), isNull);
    });
  });

  group('validateInlineMax', () {
    test('returns message when value exceeds max', () {
      final message = validateInlineMax(
        value: 11,
        max: 10,
        message: 'too high',
      );

      expect(message, equals('too high'));
    });

    test('returns null when value is within max', () {
      final message = validateInlineMax(
        value: 10,
        max: 10,
        message: 'too high',
      );

      expect(message, isNull);
    });
  });
}
