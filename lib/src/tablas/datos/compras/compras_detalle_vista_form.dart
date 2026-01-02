import 'package:erp_app/src/shell/models.dart';

const List<SectionField> comprasDetalleFormFields = [
  SectionField(
    sectionId: 'compras_detalle',
    id: 'idcompra',
    label: 'Compra',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'compras_detalle',
    id: 'idproducto',
    label: 'Producto',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_productos_para_compra',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'productos_form',
  ),
  SectionField(
    sectionId: 'compras_detalle',
    id: 'cantidad',
    label: 'Cantidad',
    required: true,
  ),
  SectionField(
    sectionId: 'compras_detalle',
    id: 'costo_total',
    label: 'Costo total',
    required: true,
  ),
];
