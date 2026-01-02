import 'package:erp_app/src/shell/models.dart';

List<SectionField> _buildCuentasBancariasFields(String sectionId) => [
      SectionField(
        sectionId: sectionId,
        id: 'nombre',
        label: 'Nombre',
        required: true,
        order: 1,
      ),
      SectionField(
        sectionId: sectionId,
        id: 'banco',
        label: 'Banco',
        required: true,
        order: 2,
      ),
      SectionField(
        sectionId: sectionId,
        id: 'idcuenta_contable',
        label: 'Cuenta contable',
        required: true,
        widgetType: 'reference',
        referenceSchema: 'public',
        referenceRelation: 'cuentas_contables',
        referenceLabelColumn: 'nombre',
        order: 3,
      ),
      SectionField(
        sectionId: sectionId,
        id: 'activa',
        label: 'Activa',
        staticOptions: ['true', 'false'],
        defaultValue: 'true',
        order: 4,
      ),
    ];

final List<SectionField> cuentasBancariasVistaFormFields =
    _buildCuentasBancariasFields('cuentas_bancarias_form');

final List<SectionField> finanzasCuentasFormFields =
    _buildCuentasBancariasFields('finanzas_cuentas');
