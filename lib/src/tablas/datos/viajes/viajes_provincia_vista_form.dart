import 'package:erp_app/src/shell/models.dart';

const List<SectionField> viajesProvinciaVistaFormFields = [
  SectionField(
    sectionId: 'viajes_provincia',
    id: 'idmovimiento',
    label: 'Movimiento',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_movimientos_disponibles_viaje_provincia',
    referenceLabelColumn: 'picker_label',
    referenceSectionId: 'movimientos',
  ),
];
