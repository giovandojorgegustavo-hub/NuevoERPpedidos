import 'package:erp_app/src/shell/models.dart';

const List<SectionField> viajesDetalleVistaFormFields = [
  SectionField(
    sectionId: 'viajes_detalle',
    id: 'idmovimiento',
    label: 'Movimiento',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_movimientos_disponibles_viaje',
    referenceLabelColumn: 'picker_label',
    referenceSectionId: 'movimientos',
  ),
  SectionField(
    sectionId: 'viajes_detalle',
    id: 'idpacking',
    label: 'Packing',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_base_packings_vistageneral',
    referenceLabelColumn: 'picker_label',
    referenceSectionId: 'base_packings_form',
  ),
];
