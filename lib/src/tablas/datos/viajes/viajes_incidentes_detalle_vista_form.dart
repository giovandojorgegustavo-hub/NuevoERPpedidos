import 'package:erp_app/src/shell/models.dart';

const List<SectionField> viajesIncidentesDetalleVistaFormFields = [
  SectionField(
    sectionId: 'viajes_incidentes_detalle',
    id: 'idincidente',
    label: 'Incidente',
    readOnly: true,
    visible: false,
    persist: false,
  ),
  SectionField(
    sectionId: 'viajes_incidentes_detalle',
    id: 'iddetalle_movimiento',
    label: 'Detalle movimiento',
    readOnly: true,
    visible: false,
    persist: false,
  ),
  SectionField(
    sectionId: 'viajes_incidentes_detalle',
    id: 'producto_nombre',
    label: 'Producto',
    readOnly: true,
    persist: false,
  ),
  SectionField(
    sectionId: 'viajes_incidentes_detalle',
    id: 'cantidad_movimiento',
    label: 'Cantidad enviada',
    readOnly: true,
    widgetType: 'number',
    persist: false,
  ),
  SectionField(
    sectionId: 'viajes_incidentes_detalle',
    id: 'cantidad',
    label: 'Cantidad incidente',
    required: true,
    widgetType: 'number',
  ),
];
