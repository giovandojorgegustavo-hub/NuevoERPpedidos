import 'package:erp_app/src/shell/models.dart';

const List<SectionField> clientesVistaFormFields = [
  SectionField(
    sectionId: 'clientes_form',
    id: 'nombre',
    label: 'Nombre',
    required: true,
    order: 1,
  ),
  SectionField(
    sectionId: 'clientes_form',
    id: 'numero',
    label: 'Número',
    required: true,
    order: 2,
  ),
  SectionField(
    sectionId: 'clientes_form',
    id: 'canal',
    label: 'Canal',
    required: true,
    order: 3,
    staticOptions: ['telegram', 'referido', 'ads', 'qr'],
  ),
  SectionField(
    sectionId: 'clientes_form',
    id: 'referido_por',
    label: 'Referido por',
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'clientes',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'clientes_form',
    order: 4,
    visibleWhenField: 'canal',
    visibleWhenEquals: 'referido',
  ),
];
