import 'package:app_pos/utils/app_number_format.dart';
import 'package:flutter/material.dart';

/// Chip compacto para el % de descuento del cliente.
class CompanyDiscountChip extends StatelessWidget {
  final double percent;
  final bool compact;

  const CompanyDiscountChip({
    super.key,
    required this.percent,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (percent <= 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '-${percent.asPercent}',
        style: TextStyle(
          color: Colors.green.shade800,
          fontWeight: FontWeight.bold,
          fontSize: compact ? 11 : 12,
        ),
      ),
    );
  }
}
