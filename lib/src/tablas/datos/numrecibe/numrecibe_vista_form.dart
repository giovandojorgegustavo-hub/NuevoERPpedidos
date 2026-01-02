import 'package:erp_app/src/shell/models.dart';

const List<SectionField> numrecibeVistaFormFields = [
  SectionField(
    sectionId: 'numrecibe_form',
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
    sectionId: 'numrecibe_form',
    id: 'numero',
    label: 'Número que recibe',
    required: true,
    order: 2,
  ),
  SectionField(
    sectionId: 'numrecibe_form',
    id: 'nombre_contacto',
    label: 'Nombre del contacto',
    order: 3,
  ),
];
