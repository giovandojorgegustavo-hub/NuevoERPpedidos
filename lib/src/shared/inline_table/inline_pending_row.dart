class InlinePendingRow {
  InlinePendingRow({
    required this.rawValues,
    required this.displayValues,
    required this.tableValues,
    required this.pendingId,
    Map<String, List<InlinePendingRow>>? nestedInlineRows,
  }) : nestedInlineRows =
            nestedInlineRows ?? <String, List<InlinePendingRow>>{};

  final Map<String, dynamic> rawValues;
  final Map<String, String> displayValues;
  final Map<String, String> tableValues;
  final String pendingId;
  final Map<String, List<InlinePendingRow>> nestedInlineRows;
}
