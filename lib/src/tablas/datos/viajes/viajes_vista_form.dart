import 'package:erp_app/src/shell/models.dart';

const List<SectionField> viajesVistaFormFields = [
  SectionField(
    sectionId: 'viajes',
    id: 'nombre_motorizado',
    label: 'Nombre del motorizado',
    required: true,
  ),
  SectionField(
    sectionId: 'viajes',
    id: 'idbase',
    label: 'Base',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'bases',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'bases_form',
  ),
  SectionField(
    sectionId: 'viajes',
    id: 'num_llamadas',
    label: 'Número de llamadas',
  ),
  SectionField(sectionId: 'viajes', id: 'num_pago', label: 'Número de pago'),
  SectionField(sectionId: 'viajes', id: 'num_wsp', label: 'Número WhatsApp'),
  SectionField(
    sectionId: 'viajes',
    id: 'monto',
    label: 'Monto',
    widgetType: 'number',
  ),
  SectionField(sectionId: 'viajes', id: 'link', label: 'Link'),
];

const List<SectionField> viajesBasesVistaFormFields = [
  SectionField(
    sectionId: 'viajes_bases',
    id: 'nombre_motorizado',
    label: 'Nombre del motorizado',
    required: true,
  ),
  SectionField(
    sectionId: 'viajes_bases',
    id: 'idbase',
    label: 'Base',
    required: true,
    readOnly: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'bases',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'bases_form',
  ),
  SectionField(
    sectionId: 'viajes_bases',
    id: 'num_llamadas',
    label: 'Número de llamadas',
  ),
  SectionField(
    sectionId: 'viajes_bases',
    id: 'num_pago',
    label: 'Número de pago',
  ),
  SectionField(
    sectionId: 'viajes_bases',
    id: 'num_wsp',
    label: 'Número WhatsApp',
  ),
  SectionField(
    sectionId: 'viajes_bases',
    id: 'monto',
    label: 'Monto',
    widgetType: 'number',
  ),
  SectionField(sectionId: 'viajes_bases', id: 'link', label: 'Link'),
];
