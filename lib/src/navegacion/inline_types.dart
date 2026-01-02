import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:erp_app/src/shell/models.dart';

typedef InlineSectionViewBuilder = InlineTableConfig Function(
  InlineSectionViewContext context,
);

typedef InlinePendingDisplayBuilder = Map<String, String> Function(
  InlinePendingDisplayContext context,
);

class InlineSectionViewContext {
  const InlineSectionViewContext({
    required this.inlineConfig,
    required this.defaultConfig,
    required this.parentRow,
    required this.parentSectionId,
    required this.parentSectionContext,
    required this.sectionContext,
    required this.forForm,
    required this.builderSectionId,
  });

  final InlineSectionConfig inlineConfig;
  final InlineTableConfig defaultConfig;
  final Map<String, dynamic> parentRow;
  final String parentSectionId;
  final Map<String, dynamic> parentSectionContext;
  final Map<String, dynamic> sectionContext;
  final bool forForm;
  final String builderSectionId;
}

class InlinePendingDisplayContext {
  const InlinePendingDisplayContext({
    required this.inlineConfig,
    required this.rawValues,
    required this.sectionContext,
    required this.resolveReferenceLabel,
    required this.resolveReferenceMetadata,
  });

  final InlineSectionConfig inlineConfig;
  final Map<String, dynamic> rawValues;
  final Map<String, dynamic> sectionContext;
  final String? Function(String fieldId, String value) resolveReferenceLabel;
  final Map<String, dynamic>? Function(String fieldId, String value)
      resolveReferenceMetadata;
}
