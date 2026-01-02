import 'package:erp_app/src/shell/models.dart';

const List<SectionField> recetasFormFields = [
  SectionField(
    sectionId: 'recetas',
    id: 'nombre',
    label: 'Nombre',
    required: true,
    order: 1,
  ),
  SectionField(
    sectionId: 'recetas',
    id: 'notas',
    label: 'Notas',
    widgetType: 'text',
    order: 2,
  ),
  SectionField(
    sectionId: 'recetas',
    id: 'activo',
    label: 'Activo',
    staticOptions: ['true', 'false'],
    defaultValue: 'true',
    order: 3,
  ),
];

const List<SectionField> recetasInsumosFormFields = [
  SectionField(
    sectionId: 'recetas_insumos',
    id: 'idreceta',
    label: 'Receta',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'recetas_insumos',
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
    sectionId: 'recetas_insumos',
    id: 'cantidad',
    label: 'Cantidad',
    required: true,
    widgetType: 'number',
  ),
];

const List<SectionField> recetasResultadosFormFields = [
  SectionField(
    sectionId: 'recetas_resultados',
    id: 'idreceta',
    label: 'Receta',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'recetas_resultados',
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
    sectionId: 'recetas_resultados',
    id: 'cantidad',
    label: 'Cantidad',
    required: true,
    widgetType: 'number',
  ),
];
