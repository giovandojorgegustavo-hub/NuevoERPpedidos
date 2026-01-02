import 'package:erp_app/src/shell/controllers/reference_options_controller.dart';

class InlineClientContextResult {
  const InlineClientContextResult({
    required this.canProceed,
    this.clientContext,
    this.errorMessage,
    this.clientId,
  });

  final bool canProceed;
  final Map<String, dynamic>? clientContext;
  final String? errorMessage;
  final String? clientId;
}

/// Resuelve información de cliente asociada a secciones padres e inline.
class ClientContextService {
  ClientContextService({
    required ReferenceOptionsController referenceOptionsController,
    required Map<String, String>? Function(String sectionId) draftResolver,
  })  : _referenceOptionsController = referenceOptionsController,
        _draftResolver = draftResolver;

  final ReferenceOptionsController _referenceOptionsController;
  final Map<String, String>? Function(String sectionId) _draftResolver;

  InlineClientContextResult prepareInlineContext({
    required String parentSectionId,
    required Map<String, dynamic> parentRow,
    required String targetSectionId,
  }) {
    if (targetSectionId != 'pedidos_movimientos') {
      return const InlineClientContextResult(canProceed: true);
    }
    final clientId = resolveClientId(parentSectionId, parentRow);
    if (clientId == null || clientId.isEmpty) {
      return const InlineClientContextResult(
        canProceed: false,
        errorMessage: 'Selecciona un cliente antes de agregar un movimiento.',
      );
    }
    final clientName = resolveClientName(parentSectionId, parentRow, clientId);
    final clientNumber =
        resolveClientNumber(parentSectionId, parentRow, clientId);
    final context = <String, dynamic>{
      'idcliente': clientId,
      'cliente_nombre': clientName ?? '',
      'cliente_numero': clientNumber ?? '',
      'idpedido': parentRow['id']?.toString() ?? '',
    };
    return InlineClientContextResult(
      canProceed: true,
      clientContext: context,
      clientId: clientId,
    );
  }

  String? resolveClientId(
    String parentSectionId,
    Map<String, dynamic> parentRow,
  ) {
    final draft = _draftResolver(parentSectionId);
    final draftValue = draft?['idcliente'];
    if (draftValue != null && draftValue.isNotEmpty) {
      return draftValue;
    }
    final fromRow = parentRow['idcliente']?.toString();
    if (fromRow != null && fromRow.isNotEmpty) {
      return fromRow;
    }
    return null;
  }

  String? resolveClientName(
    String parentSectionId,
    Map<String, dynamic> parentRow,
    String clientId,
  ) {
    final fromRow = parentRow['cliente_nombre']?.toString();
    if (fromRow != null && fromRow.isNotEmpty) return fromRow;
    final options = _referenceOptionsController.optionsForField(
      parentSectionId,
      'idcliente',
    );
    for (final option in options) {
      if (option.value == clientId) return option.label;
    }
    return null;
  }

  String? resolveClientNumber(
    String parentSectionId,
    Map<String, dynamic> parentRow,
    String clientId,
  ) {
    final fromRow = parentRow['cliente_numero']?.toString();
    if (fromRow != null && fromRow.isNotEmpty) return fromRow;
    final options = _referenceOptionsController.optionsForField(
      parentSectionId,
      'idcliente',
    );
    for (final option in options) {
      if (option.value == clientId) {
        final metadataNumero = option.metadata['numero']?.toString();
        if (metadataNumero != null && metadataNumero.isNotEmpty) {
          return metadataNumero;
        }
        return option.label;
      }
    }
    return null;
  }
}
