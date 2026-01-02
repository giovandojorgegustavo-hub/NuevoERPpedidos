import 'package:erp_app/src/shell/models.dart';

const List<SectionField> comprasPagosFormFields = [
  SectionField(
    sectionId: 'compras_pagos',
    id: 'idcompra',
    label: 'Compra',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'compras_pagos',
    id: 'idcuenta',
    label: 'Cuenta bancaria',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_cuentas_bancarias_visibles',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'cuentas_bancarias_form',
  ),
  SectionField(
    sectionId: 'compras_pagos',
    id: 'monto',
    label: 'Monto',
    required: true,
  ),
  SectionField(
    sectionId: 'compras_pagos',
    id: 'registrado_at',
    label: 'Fecha de pago',
    required: true,
    widgetType: 'datetime',
    defaultValue: 'now',
  ),
];
