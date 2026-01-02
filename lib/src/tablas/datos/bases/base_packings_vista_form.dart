import 'package:erp_app/src/shell/models.dart';

const List<SectionField> basePackingsVistaFormFields = [
  SectionField(
    sectionId: 'base_packings_form',
    id: 'idbase',
    label: 'Base',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'base_packings_form',
    id: 'nombre',
    label: 'Nombre de marca',
    required: true,
  ),
  SectionField(
    sectionId: 'base_packings_form',
    id: 'tipo',
    label: 'Tipo de packing',
    required: true,
  ),
  SectionField(
    sectionId: 'base_packings_form',
    id: 'observacion',
    label: 'Observaciones',
  ),
  SectionField(
    sectionId: 'base_packings_form',
    id: 'activo',
    label: 'Activo',
    staticOptions: ['true', 'false'],
    defaultValue: 'true',
  ),
];
