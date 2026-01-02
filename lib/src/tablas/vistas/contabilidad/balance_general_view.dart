import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const List<String> _kSpanishMonthNames = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String _formatCurrencyLabel(double value) {
  final isNegative = value.isNegative;
  final absolute = value.abs();
  final parts = absolute.toStringAsFixed(2).split('.');
  final integerPart = parts[0];
  final decimals = parts[1];
  final grouped = _groupThousands(integerPart);
  final prefix = isNegative ? '-S/ ' : 'S/ ';
  return '$prefix$grouped,$decimals';
}

String _groupThousands(String digits) {
  if (digits.length <= 3) return digits;
  final parts = <String>[];
  var index = digits.length;
  while (index > 0) {
    final start = math.max(0, index - 3);
    parts.add(digits.substring(start, index));
    index = start;
  }
  return parts.reversed.join('.');
}

String _formatMonthYear(DateTime date) {
  final monthIndex = date.month - 1;
  if (monthIndex < 0 || monthIndex >= _kSpanishMonthNames.length) {
    return '${date.month}/${date.year}';
  }
  final monthName = _kSpanishMonthNames[monthIndex];
  return '${monthName[0].toUpperCase()}${monthName.substring(1)} ${date.year}';
}

class BalanceGeneralBoard extends StatefulWidget {
  const BalanceGeneralBoard({super.key, required this.config});

  final TableViewConfig config;

  @override
  State<BalanceGeneralBoard> createState() => _BalanceGeneralBoardState();
}

class _BalancePeriodData {
  _BalancePeriodData({required this.key, required this.date});

  final String key;
  final DateTime? date;
  final Map<String, double> totals = {};
  final Map<String, List<_BalanceAccount>> accountsByType = {};
}

class _BalanceAccount {
  const _BalanceAccount({
    required this.code,
    required this.name,
    required this.amount,
  });

  final String code;
  final String name;
  final double amount;
}

class _BalanceGeneralBoardState extends State<BalanceGeneralBoard> {
  static const double _kDifferenceTolerance = 0.005;

  Map<String, _BalancePeriodData> _periods = {};
  String? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _periods = _groupByPeriod(widget.config.rows);
    if (_periods.isNotEmpty) {
      _selectedPeriod = _resolveLatestPeriod(_periods);
    }
  }

  @override
  void didUpdateWidget(covariant BalanceGeneralBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.config.rows, widget.config.rows)) {
      final grouped = _groupByPeriod(widget.config.rows);
      setState(() {
        _periods = grouped;
        if (_periods.isEmpty) {
          _selectedPeriod = null;
        } else if (_selectedPeriod == null ||
            !_periods.containsKey(_selectedPeriod)) {
          _selectedPeriod = _resolveLatestPeriod(_periods);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_periods.isEmpty) {
      return _EmptyBalancePlaceholder(title: widget.config.title);
    }

    final effectivePeriod =
        _selectedPeriod ?? _resolveLatestPeriod(_periods) ?? _periods.keys.first;
    final selectedData = _periods[effectivePeriod];

    if (selectedData == null) {
      return _EmptyBalancePlaceholder(title: widget.config.title);
    }

    final activos = selectedData.totals['activo'] ?? 0;
    final pasivos = selectedData.totals['pasivo'] ?? 0;
    final patrimonio = selectedData.totals['patrimonio'] ?? 0;
    final diferencia = activos - (pasivos + patrimonio);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, effectivePeriod),
          const SizedBox(height: 16),
          _buildSummaryCards(
            activos: activos,
            pasivos: pasivos,
            patrimonio: patrimonio,
            diferencia: diferencia,
          ),
          const SizedBox(height: 24),
          _buildBreakdownCard(selectedData),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String selectedKey) {
    final sorted = _sortedPeriods();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.config.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (widget.config.description != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.config.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ],
          ],
        ),
        DropdownButton<String>(
          value: sorted.any((period) => period.key == selectedKey)
              ? selectedKey
              : sorted.first.key,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedPeriod = value);
          },
          items: [
            for (final period in sorted)
              DropdownMenuItem(
                value: period.key,
                child: Text(_formatPeriodLabel(period)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards({
    required double activos,
    required double pasivos,
    required double patrimonio,
    required double diferencia,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final cards = <_BalanceSummaryCard>[
          _BalanceSummaryCard(
            title: 'Activos',
            amount: activos,
            background: Colors.indigo.shade50,
            accent: Colors.indigo,
            subtitle: 'Recursos controlados',
          ),
          _BalanceSummaryCard(
            title: 'Pasivos',
            amount: pasivos,
            background: Colors.orange.shade50,
            accent: Colors.orange,
            subtitle: 'Obligaciones pendientes',
          ),
          _BalanceSummaryCard(
            title: 'Patrimonio',
            amount: patrimonio,
            background: Colors.teal.shade50,
            accent: Colors.teal,
            subtitle: 'Capital propio',
          ),
        ];
        if (_hasSignificantDifference(diferencia)) {
          cards.add(
            _BalanceSummaryCard(
              title: 'Diferencia',
              amount: diferencia,
              background: Colors.pink.shade50,
              accent: Colors.pink,
              subtitle: 'Activos - (Pasivos + Patrimonio)',
            ),
          );
        }

        if (isNarrow) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cards[0],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: cards[1]),
                const SizedBox(width: 16),
                Expanded(child: cards[2]),
              ],
            ),
            if (cards.length > 3) ...[
              const SizedBox(height: 12),
              cards[3],
            ],
          ],
        );
      },
    );
  }

  Widget _buildBreakdownCard(_BalancePeriodData period) {
    final typeEntries = period.accountsByType.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalle por tipo',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (typeEntries.isEmpty)
              const Text(
                'Sin registros para el periodo seleccionado.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ...List.generate(typeEntries.length, (index) {
                final entry = typeEntries[index];
                final tipo = entry.key;
                final cuentas = entry.value;
                final totalTipo = period.totals[tipo] ?? 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TypeBadge(tipo: tipo),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _capitalize(tipo),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _formatAmount(totalTipo),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...cuentas.map(
                      (account) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 32),
                            Expanded(
                              child: Text(
                                '${account.code} · ${account.name}',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                            Text(
                              _formatAmount(account.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index < typeEntries.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  List<_BalancePeriodData> _sortedPeriods() {
    final values = _periods.values.toList();
    values.sort((a, b) {
      final aDate = a.date;
      final bDate = b.date;
      if (aDate != null && bDate != null) {
        return bDate.compareTo(aDate);
      }
      if (aDate != null) return -1;
      if (bDate != null) return 1;
      return b.key.compareTo(a.key);
    });
    return values;
  }

  Map<String, _BalancePeriodData> _groupByPeriod(List<TableRowData> rows) {
    final grouped = <String, _BalancePeriodData>{};
    for (final row in rows) {
      final key = (row['periodo'] ?? 'Sin periodo').toString();
      final period = grouped.putIfAbsent(
        key,
        () => _BalancePeriodData(
          key: key,
          date: DateTime.tryParse(key),
        ),
      );
      final tipo = (row['tipo'] ?? 'sin_tipo').toString();
      final saldo = _toDouble(row['saldo']);
      final codigo = (row['cuenta_contable_codigo'] ?? '').toString();
      final nombre = (row['cuenta_contable_nombre'] ?? '').toString();
      period.totals[tipo] = (period.totals[tipo] ?? 0) + saldo;
      period.accountsByType.putIfAbsent(tipo, () => []).add(
            _BalanceAccount(code: codigo, name: nombre, amount: saldo),
          );
    }
    _injectSyntheticPatrimonio(grouped);
    return grouped;
  }

  /// Inserta una fila sintética en patrimonio cuando el balance no cuadra.
  void _injectSyntheticPatrimonio(Map<String, _BalancePeriodData> grouped) {
    for (final period in grouped.values) {
      final activos = period.totals['activo'] ?? 0;
      final pasivos = period.totals['pasivo'] ?? 0;
      final patrimonio = period.totals['patrimonio'] ?? 0;
      final diferencia = activos - (pasivos + patrimonio);
      if (!_hasSignificantDifference(diferencia)) continue;
      period.totals['patrimonio'] = patrimonio + diferencia;
      final accounts = period.accountsByType.putIfAbsent(
        'patrimonio',
        () => <_BalanceAccount>[],
      );
      accounts.add(
        _BalanceAccount(
          code: 'AJUSTE',
          name: 'Ajuste por diferencia',
          amount: diferencia,
        ),
      );
    }
  }

  bool _hasSignificantDifference(double value) =>
      value.abs() > _kDifferenceTolerance;

  String _formatAmount(double value) => _formatCurrencyLabel(value);

  String _formatPeriodLabel(_BalancePeriodData period) {
    if (period.date != null) {
      return _formatMonthYear(period.date!);
    }
    return period.key;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String? _resolveLatestPeriod(Map<String, _BalancePeriodData> periods) {
    _BalancePeriodData? latest;
    for (final period in periods.values) {
      if (latest == null) {
        latest = period;
        continue;
      }
      final candidateDate = period.date;
      final latestDate = latest.date;
      if (candidateDate != null && latestDate != null) {
        if (candidateDate.isAfter(latestDate)) {
          latest = period;
        }
      } else if (candidateDate != null && latestDate == null) {
        latest = period;
      } else if (candidateDate == null && latestDate == null) {
        if (period.key.compareTo(latest.key) > 0) {
          latest = period;
        }
      }
    }
    return latest?.key;
  }
}

class _BalanceSummaryCard extends StatelessWidget {
  const _BalanceSummaryCard({
    required this.title,
    required this.amount,
    required this.background,
    required this.accent,
    required this.subtitle,
  });

  final String title;
  final double amount;
  final Color background;
  final Color accent;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withAlpha(
                    math.max(
                      0,
                      math.min(
                        255,
                        (accent.a * 255.0 * 0.12).round(),
                      ),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatCurrencyLabel(amount),
                style: TextStyle(
                  fontSize: 18,
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.tipo});

  final String tipo;

  Color get _color {
    switch (tipo) {
      case 'activo':
        return Colors.indigo;
      case 'pasivo':
        return Colors.orange;
      case 'patrimonio':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: _color.withAlpha(
        math.max(
          0,
          math.min(
            255,
            (_color.a * 255.0 * 0.15).round(),
          ),
        ),
      ),
      child: Icon(
        Icons.summarize,
        color: _color,
        size: 18,
      ),
    );
  }
}

class _EmptyBalancePlaceholder extends StatelessWidget {
  const _EmptyBalancePlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Registra movimientos contables para ver el balance.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
