import 'package:erp_app/src/shell/models.dart';

const List<SectionField> viajesDevueltosDetalleVistaFormFields = [
  SectionField(
    sectionId: 'viajes_devueltos_detalle',
    id: 'iddevuelto',
    label: 'Devolución',
    readOnly: true,
    visible: false,
    persist: false,
  ),
  SectionField(
    sectionId: 'viajes_devueltos_detalle',
    id: 'iddetalle_movimiento',
    label: 'Detalle movimiento',
    readOnly: true,
    visible: false,
    persist: false,
  ),
  SectionField(
    sectionId: 'viajes_devueltos_detalle',
    id: 'producto_nombre',
    label: 'Producto',
    readOnly: true,
    persist: false,
  ),
  SectionField(
    sectionId: 'viajes_devueltos_detalle',
    id: 'cantidad_movimiento',
    label: 'Cantidad enviada',
    readOnly: true,
    widgetType: 'number',
    persist: false,
  ),
  SectionField(
    sectionId: 'viajes_devueltos_detalle',
    id: 'cantidad',
    label: 'Cantidad devuelta',
    required: true,
    widgetType: 'number',
  ),
];
