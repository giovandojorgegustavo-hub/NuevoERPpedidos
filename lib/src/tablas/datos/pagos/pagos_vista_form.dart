import 'package:erp_app/src/shell/models.dart';

const List<SectionField> pagosVistaFormFields = [
  SectionField(
    sectionId: 'pedidos_pagos',
    id: 'idpedido',
    label: 'Pedido',
    readOnly: true,
    visible: false,
  ),
  SectionField(
    sectionId: 'pedidos_pagos',
    id: 'codigo',
    label: 'Código',
    readOnly: true,
  ),
  SectionField(
    sectionId: 'pedidos_pagos',
    id: 'monto',
    label: 'Monto',
    required: true,
  ),
  SectionField(
    sectionId: 'pedidos_pagos',
    id: 'fechapago',
    label: 'Fecha de pago',
    required: true,
    widgetType: 'datetime',
    defaultValue: 'now',
  ),
  SectionField(
    sectionId: 'pedidos_pagos',
    id: 'idcuenta',
    label: 'Cuenta bancaria',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_cuentas_bancarias_visibles',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'cuentas_bancarias_form',
  ),
];
