import 'package:erp_app/src/shell/models.dart';

const List<SectionField> movimientosDetalleVistaFormFields = [
  SectionField(
    sectionId: 'movimientos_detalle',
    id: 'idmovimiento',
    label: 'Movimiento',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'movimientos_detalle',
    id: 'idproducto',
    label: 'Producto',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'productos',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'productos_form',
  ),
  SectionField(
    sectionId: 'movimientos_detalle',
    id: 'cantidad',
    label: 'Cantidad',
    required: true,
  ),
];
