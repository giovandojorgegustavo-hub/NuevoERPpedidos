import 'package:erp_app/src/shell/models.dart';

const List<SectionField> fabricacionesInternasFormFields = [
  SectionField(
    sectionId: 'fabricaciones_internas',
    id: 'idbase',
    label: 'Base',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'bases',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'bases_form',
    order: 1,
  ),
  SectionField(
    sectionId: 'fabricaciones_internas',
    id: 'idreceta',
    label: 'Receta',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_recetas_vistageneral',
    referenceLabelColumn: 'nombre',
    order: 2,
  ),
  SectionField(
    sectionId: 'fabricaciones_internas',
    id: 'observacion',
    label: 'Observación',
    order: 3,
  ),
];

const List<SectionField> fabricacionesInternasConsumosFormFields = [
  SectionField(
    sectionId: 'fabricaciones_internas_consumos',
    id: 'idfabricacion',
    label: 'Fabricación',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'fabricaciones_internas_consumos',
    id: 'idproducto',
    label: 'Producto',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_recetas_insumos_stock',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'productos_form',
  ),
  SectionField(
    sectionId: 'fabricaciones_internas_consumos',
    id: 'cantidad',
    label: 'Cantidad',
    required: true,
    widgetType: 'number',
  ),
];

const List<SectionField> fabricacionesInternasResultadosFormFields = [
  SectionField(
    sectionId: 'fabricaciones_internas_resultados',
    id: 'idfabricacion',
    label: 'Fabricación',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'fabricaciones_internas_resultados',
    id: 'idproducto',
    label: 'Producto',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_recetas_resultados_catalogo',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'productos_form',
  ),
  SectionField(
    sectionId: 'fabricaciones_internas_resultados',
    id: 'cantidad',
    label: 'Cantidad',
    required: true,
    widgetType: 'number',
  ),
  SectionField(
    sectionId: 'fabricaciones_internas_resultados',
    id: 'costo_unitario',
    label: 'Costo unitario',
    widgetType: 'number',
    readOnly: true,
  ),
  SectionField(
    sectionId: 'fabricaciones_internas_resultados',
    id: 'costo_total',
    label: 'Costo total',
    widgetType: 'number',
    readOnly: true,
  ),
];
