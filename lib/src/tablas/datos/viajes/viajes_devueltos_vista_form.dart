import 'package:erp_app/src/shell/models.dart';

const List<SectionField> viajesDevueltosVistaFormFields = [
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'idviaje_detalle',
    label: 'Detalle del viaje',
    readOnly: true,
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'idmovimiento',
    label: 'Movimiento',
    readOnly: true,
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'idpedido',
    label: 'Pedido',
    readOnly: true,
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'idbase_retorno',
    label: 'Base retorno',
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'bases',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'bases_form',
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'monto_ida',
    label: 'Monto ida',
    widgetType: 'number',
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'monto_vuelta',
    label: 'Monto vuelta',
    widgetType: 'number',
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'penalidad',
    label: 'Penalidad',
    widgetType: 'number',
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'link_evidencia',
    label: 'Link de evidencia',
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'observacion',
    label: 'Observación',
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'estado',
    label: 'Estado',
    readOnly: true,
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'cliente_resuelto_at',
    label: 'Cliente resolvió',
    readOnly: true,
    widgetType: 'datetime',
  ),
  SectionField(
    sectionId: 'viajes_devueltos',
    id: 'devuelto_recibido_at',
    label: 'Devuelto recibido',
    readOnly: true,
    widgetType: 'datetime',
  ),
];
