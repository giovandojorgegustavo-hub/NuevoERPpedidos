import 'package:erp_app/src/shell/models.dart';

const List<SectionField> fabricacionesMaquilaFormFields = [
  SectionField(
    sectionId: 'fabricaciones_maquila',
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
    sectionId: 'fabricaciones_maquila',
    id: 'idproveedor',
    label: 'Proveedor externo',
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'proveedores',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'proveedores_form',
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila',
    id: 'observacion',
    label: 'Observación',
  ),
];

const List<SectionField> fabricacionesMaquilaConsumosFormFields = [
  SectionField(
    sectionId: 'fabricaciones_maquila_consumos',
    id: 'idfabricacion',
    label: 'Fabricación',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_consumos',
    id: 'idproducto',
    label: 'Producto',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_stock_disponible_por_base',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'productos_form',
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_consumos',
    id: 'cantidad',
    label: 'Cantidad',
    required: true,
    widgetType: 'number',
  ),
];

const List<SectionField> fabricacionesMaquilaResultadosFormFields = [
  SectionField(
    sectionId: 'fabricaciones_maquila_resultados',
    id: 'idfabricacion',
    label: 'Fabricación',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_resultados',
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
    sectionId: 'fabricaciones_maquila_resultados',
    id: 'tipo_resultado',
    label: 'Tipo de resultado',
    required: true,
    staticOptions: [
      'principal',
      'secundario',
      'subproducto',
      'merma',
      'producto',
    ],
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_resultados',
    id: 'cantidad',
    label: 'Cantidad',
    required: true,
    widgetType: 'number',
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_resultados',
    id: 'costo_unitario',
    label: 'Costo unitario',
    widgetType: 'number',
    readOnly: true,
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_resultados',
    id: 'costo_total',
    label: 'Costo total',
    widgetType: 'number',
    readOnly: true,
  ),
];

const List<SectionField> fabricacionesMaquilaCostosFormFields = [
  SectionField(
    sectionId: 'fabricaciones_maquila_costos',
    id: 'idfabricacion',
    label: 'Fabricación',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_costos',
    id: 'concepto',
    label: 'Concepto',
    required: true,
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_costos',
    id: 'monto',
    label: 'Monto',
    required: true,
    widgetType: 'number',
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_costos',
    id: 'idcuenta',
    label: 'Cuenta bancaria',
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_cuentas_bancarias_visibles',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'cuentas_bancarias_form',
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_costos',
    id: 'idcuenta_contable',
    label: 'Cuenta contable',
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'cuentas_contables',
    referenceLabelColumn: 'nombre',
  ),
  SectionField(
    sectionId: 'fabricaciones_maquila_costos',
    id: 'observacion',
    label: 'Observación',
  ),
];
