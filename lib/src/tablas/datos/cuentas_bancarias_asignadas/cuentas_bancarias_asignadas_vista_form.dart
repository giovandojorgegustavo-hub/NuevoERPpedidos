import 'package:erp_app/src/shell/models.dart';

const List<SectionField> cuentasBancariasAsignadasFormFields = [
  SectionField(
    sectionId: 'cuentas_bancarias_asignadas',
    id: 'idusuario',
    label: 'Gerente',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_perfiles_gerentes',
    referenceLabelColumn: 'nombre',
    order: 1,
  ),
  SectionField(
    sectionId: 'cuentas_bancarias_asignadas',
    id: 'idcuenta',
    label: 'Cuenta bancaria',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_cuentas_bancarias_vistageneral',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'cuentas_bancarias_form',
    order: 2,
  ),
  SectionField(
    sectionId: 'cuentas_bancarias_asignadas',
    id: 'activo',
    label: 'Activo',
    required: true,
    staticOptions: ['true', 'false'],
    defaultValue: 'true',
    order: 3,
  ),
];
