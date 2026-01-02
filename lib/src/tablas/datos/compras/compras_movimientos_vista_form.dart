import 'package:erp_app/src/shell/models.dart';

const List<SectionField> comprasMovimientosFormFields = [
  SectionField(
    sectionId: 'compras_movimientos',
    id: 'idcompra',
    label: 'Compra',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'compras_movimientos',
    id: 'idbase',
    label: 'Base receptora',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'bases',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'bases_form',
  ),
  SectionField(
    sectionId: 'compras_movimientos',
    id: 'observacion',
    label: 'Observación',
  ),
];
