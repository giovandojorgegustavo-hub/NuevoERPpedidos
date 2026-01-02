import 'package:flutter/material.dart';

IconData resolveIcon(String? name, {IconData fallback = Icons.circle}) {
  if (name == null || name.isEmpty) return fallback;
  switch (name) {
    case 'inventory_2_outlined':
      return Icons.inventory_2_outlined;
    case 'table_chart_outlined':
      return Icons.table_chart_outlined;
    case 'swap_horiz':
      return Icons.swap_horiz;
    case 'local_shipping_outlined':
      return Icons.local_shipping_outlined;
    case 'list_alt':
      return Icons.list_alt;
    case 'attach_money':
      return Icons.attach_money;
    case 'settings_suggest_outlined':
      return Icons.settings_suggest_outlined;
    case 'accounts':
      return Icons.group_outlined;
    default:
      return fallback;
  }
}
