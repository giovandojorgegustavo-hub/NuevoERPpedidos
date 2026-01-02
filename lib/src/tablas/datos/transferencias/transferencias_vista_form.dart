import 'package:erp_app/src/shell/models.dart';

const List<SectionField> transferenciasFormFields = [
  SectionField(
    sectionId: 'transferencias',
    id: 'idbase_origen',
    label: 'Base origen',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'bases',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'bases_form',
    order: 1,
  ),
  SectionField(
    sectionId: 'transferencias',
    id: 'idbase_destino',
    label: 'Base destino',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'bases',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'bases_form',
    order: 2,
  ),
  SectionField(
    sectionId: 'transferencias',
    id: 'observacion',
    label: 'Observación',
    order: 3,
  ),
];

const List<SectionField> transferenciasDetalleFormFields = [
  SectionField(
    sectionId: 'transferencias_detalle',
    id: 'idtransferencia',
    label: 'Transferencia',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'transferencias_detalle',
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
    sectionId: 'transferencias_detalle',
    id: 'cantidad',
    label: 'Cantidad',
    required: true,
    widgetType: 'number',
    order: 2,
  ),
];
