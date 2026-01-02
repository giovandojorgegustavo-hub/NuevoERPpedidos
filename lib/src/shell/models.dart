import 'package:flutter/material.dart';

enum SectionContentMode { table, detail, form }

enum SectionFormMode { create, edit }

class ModuleSection {
  const ModuleSection({
    required this.id,
    required this.label,
    required this.icon,
    this.description = '',
  });

  final String id;
  final String label;
  final IconData icon;
  final String description;
}

class ModuleConfig {
  const ModuleConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.sections,
  });

  final String id;
  final String name;
  final IconData icon;
  final String description;
  final List<ModuleSection> sections;
}

class GlobalNavAction {
  const GlobalNavAction({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

class SectionDataSource {
  const SectionDataSource({
    required this.sectionId,
    required this.listSchema,
    required this.listRelation,
    required this.listIsView,
    required this.formSchema,
    required this.formRelation,
    required this.formIsView,
    this.detailSchema,
    this.detailRelation,
    this.detailIsView,
    this.listOrderBy,
    this.listOrderAscending = true,
    this.listLimit,
  });

  final String sectionId;
  final String listSchema;
  final String listRelation;
  final bool listIsView;
  final String formSchema;
  final String formRelation;
  final bool formIsView;
  final String? detailSchema;
  final String? detailRelation;
  final bool? detailIsView;
  final String? listOrderBy;
  final bool listOrderAscending;
  final int? listLimit;
}

class ModuleMetadata {
  const ModuleMetadata({
    required this.modules,
    required this.sectionDataSources,
    required this.sectionFields,
  });

  final List<ModuleConfig> modules;
  final Map<String, SectionDataSource> sectionDataSources;
  final Map<String, List<SectionField>> sectionFields;
}

class SectionField {
  const SectionField({
    required this.sectionId,
    required this.id,
    required this.label,
    this.required = false,
    this.readOnly = false,
    this.visible = true,
    this.persist = true,
    this.order = 0,
    this.dataType,
    this.widgetType,
    this.referenceSchema,
    this.referenceRelation,
    this.referenceLabelColumn,
    this.defaultValue,
    this.referenceSectionId,
    this.visibleWhenField,
    this.visibleWhenEquals,
    this.staticOptions = const [],
  });

  final String sectionId;
  final String id;
  final String label;
  final bool required;
  final bool readOnly;
  final bool visible;
  final bool persist;
  final int order;
  final String? dataType;
  final String? widgetType;
  final String? referenceSchema;
  final String? referenceRelation;
  final String? referenceLabelColumn;
  final String? defaultValue;
  final String? referenceSectionId;
  final String? visibleWhenField;
  final String? visibleWhenEquals;
  final List<String> staticOptions;
}

class ReferenceOption {
  const ReferenceOption({
    required this.value,
    required this.label,
    this.metadata = const {},
  });

  final String value;
  final String label;
  final Map<String, dynamic> metadata;
}

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.name,
    required this.role,
    this.baseId,
  });

  final String userId;
  final String? name;
  final String role;
  final String? baseId;

  bool get isBaseUser => role.toLowerCase() == 'bases';
  bool get hasAssignedBase => baseId != null && baseId!.trim().isNotEmpty;
}

class InlineSectionDataSource {
  const InlineSectionDataSource({
    required this.schema,
    required this.relation,
    this.orderBy,
    this.orderAscending = true,
  });

  final String schema;
  final String relation;
  final String? orderBy;
  final bool orderAscending;
}

class InlineSectionColumn {
  const InlineSectionColumn({required this.key, required this.label});

  final String key;
  final String label;
}

class InlineSectionConfig {
  const InlineSectionConfig({
    required this.id,
    required this.title,
    required this.dataSource,
    required this.foreignKeyColumn,
    required this.columns,
    this.foreignKeyParentField,
    this.collapsedByDefault = false,
    this.emptyPlaceholder = 'Sin registros disponibles.',
    this.showInDetail = true,
    this.showInForm = false,
    this.enableCreate = false,
    this.enableView = true,
    this.formSectionId,
    this.formForeignKeyField,
    this.pendingFieldMapping = const {},
    this.rowTapSectionId,
    this.formTitle,
    this.requiresPersistedParent = false,
  });

  final String id;
  final String title;
  final InlineSectionDataSource dataSource;
  final String foreignKeyColumn;
  final String? foreignKeyParentField;
  final List<InlineSectionColumn> columns;
  final bool collapsedByDefault;
  final String emptyPlaceholder;
  final bool showInDetail;
  final bool showInForm;
  final bool enableCreate;
  final bool enableView;
  final String? formSectionId;
  final String? formForeignKeyField;
  final Map<String, String> pendingFieldMapping;
  final String? rowTapSectionId;
  final String? formTitle;
  final bool requiresPersistedParent;
}
