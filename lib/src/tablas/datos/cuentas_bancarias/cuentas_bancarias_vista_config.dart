import 'package:erp_app/src/shell/models.dart';

const SectionDataSource cuentasBancariasDataSource = SectionDataSource(
  sectionId: 'cuentas_bancarias_form',
  listSchema: 'public',
  listRelation: 'v_cuentas_bancarias_visibles',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'cuentas_bancarias',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_cuentas_bancarias_visibles',
  detailIsView: true,
);
