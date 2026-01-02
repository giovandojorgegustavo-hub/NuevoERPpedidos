import 'package:erp_app/src/shell/models.dart';

const List<SectionField> ajustesFormFields = [
  SectionField(
    sectionId: 'ajustes',
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
    sectionId: 'ajustes',
    id: 'observacion',
    label: 'Observación',
    order: 2,
  ),
];

const List<SectionField> ajustesDetalleFormFields = [
  SectionField(
    sectionId: 'ajustes_detalle',
    id: 'idajuste',
    label: 'Ajuste',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'ajustes_detalle',
    id: 'idproducto',
    label: 'Producto',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_stock_disponible_por_base',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'productos_form',
    order: 1,
  ),
  SectionField(
    sectionId: 'ajustes_detalle',
    id: 'cantidad_sistema',
    label: 'Inventario sistema',
    widgetType: 'number',
    readOnly: true,
    order: 2,
  ),
  SectionField(
    sectionId: 'ajustes_detalle',
    id: 'cantidad_real',
    label: 'Inventario real',
    widgetType: 'number',
    order: 3,
  ),
  SectionField(
    sectionId: 'ajustes_detalle',
    id: 'cantidad',
    label: 'Diferencia',
    widgetType: 'number',
    readOnly: true,
    order: 4,
  ),
];
