import 'package:erp_app/src/shell/models.dart';

const List<SectionField> direccionProvinciaVistaFormFields = [
  SectionField(
    sectionId: 'direccion_provincia_form',
    id: 'idcliente',
    label: 'Cliente',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'clientes',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'clientes_form',
    order: 1,
    readOnly: true,
  ),
  SectionField(
    sectionId: 'direccion_provincia_form',
    id: 'lugar_llegada',
    label: 'Lugar de llegada',
    required: true,
    order: 2,
  ),
  SectionField(
    sectionId: 'direccion_provincia_form',
    id: 'nombre_completo',
    label: 'Nombre completo',
    required: true,
    order: 3,
  ),
  SectionField(
    sectionId: 'direccion_provincia_form',
    id: 'dni',
    label: 'DNI',
    required: true,
    order: 4,
  ),
];
