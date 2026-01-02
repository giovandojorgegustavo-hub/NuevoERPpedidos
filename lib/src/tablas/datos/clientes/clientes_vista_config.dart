import 'package:erp_app/src/shell/models.dart';

const SectionDataSource clientesDataSource = SectionDataSource(
  sectionId: 'clientes_form',
  listSchema: 'public',
  listRelation: 'clientes',
  listIsView: false,
  formSchema: 'public',
  formRelation: 'clientes',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);
