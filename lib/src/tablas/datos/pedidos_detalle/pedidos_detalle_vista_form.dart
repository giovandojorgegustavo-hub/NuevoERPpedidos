import 'package:erp_app/src/shell/models.dart';

/// Campos que conforman el formulario para líneas de pedido.
const List<SectionField> detallePedidosInlineFields = [
  SectionField(
    sectionId: 'pedidos_detalle',
    id: 'idpedido',
    label: 'Pedido',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'pedidos_detalle',
    id: 'idproducto',
    label: 'Producto',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_productos_para_venta',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'productos_form',
  ),
  SectionField(
    sectionId: 'pedidos_detalle',
    id: 'cantidad',
    label: 'Cantidad',
    required: true,
  ),
  SectionField(
    sectionId: 'pedidos_detalle',
    id: 'precioventa',
    label: 'Precio total',
    required: true,
  ),
];
