import 'package:erp_app/src/shell/models.dart';

const List<SectionField> direccionVistaFormFields = [
  SectionField(
    sectionId: 'direccion_form',
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
    sectionId: 'direccion_form',
    id: 'direccion',
    label: 'Dirección',
    required: true,
    order: 2,
  ),
  SectionField(
    sectionId: 'direccion_form',
    id: 'referencia',
    label: 'Referencia',
    order: 3,
  ),
];
