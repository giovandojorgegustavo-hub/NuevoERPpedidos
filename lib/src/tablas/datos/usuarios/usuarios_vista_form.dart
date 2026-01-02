import 'package:erp_app/src/shell/models.dart';

const List<SectionField> usuariosVistaFormFields = [
  SectionField(
    sectionId: 'usuarios',
    id: 'user_id',
    label: 'Usuario',
    readOnly: true,
  ),
  SectionField(
    sectionId: 'usuarios',
    id: 'nombre',
    label: 'Nombre completo',
    readOnly: true,
  ),
  SectionField(
    sectionId: 'usuarios',
    id: 'rol',
    label: 'Rol',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_security_roles',
    referenceLabelColumn: 'descripcion',
  ),
  SectionField(
    sectionId: 'usuarios',
    id: 'idbase',
    label: 'Base asignada',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'bases',
    referenceLabelColumn: 'nombre',
    visibleWhenField: 'rol',
    visibleWhenEquals: 'bases',
  ),
];
