import 'package:erp_app/src/shell/models.dart';

const List<SectionField> comprasVistaFormFields = [
  SectionField(
    sectionId: 'compras',
    id: 'registrado_at',
    label: 'Fecha de registro',
    readOnly: true,
    order: 1,
    defaultValue: 'now',
  ),
  SectionField(
    sectionId: 'compras',
    id: 'idproveedor',
    label: 'Proveedor',
    required: true,
    order: 2,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'proveedores',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'proveedores_form',
  ),
  SectionField(
    sectionId: 'compras',
    id: 'observacion',
    label: 'Observación',
    order: 3,
  ),
  SectionField(
    sectionId: 'compras',
    id: 'registrado_por',
    label: 'Registrado por',
    visible: false,
  ),
  SectionField(
    sectionId: 'compras',
    id: 'editado_por',
    label: 'Editado por',
    visible: false,
  ),
  SectionField(
    sectionId: 'compras',
    id: 'editado_at',
    label: 'Editado el',
    visible: false,
  ),
];
