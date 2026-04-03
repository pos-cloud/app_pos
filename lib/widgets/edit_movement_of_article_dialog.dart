import 'package:app_pos/models/movement_of_article.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Edición de cantidad, precio unitario y observaciones; recalcula el total en el provider.
class EditMovementOfArticleDialog extends ConsumerStatefulWidget {
  final MovementOfArticle movement;
  final int index;

  const EditMovementOfArticleDialog({
    super.key,
    required this.movement,
    required this.index,
  });

  @override
  ConsumerState<EditMovementOfArticleDialog> createState() =>
      _EditMovementOfArticleDialogState();
}

class _EditMovementOfArticleDialogState
    extends ConsumerState<EditMovementOfArticleDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final m = widget.movement;
    final amount = m.effectiveAmount;
    final unit = m.effectiveUnitPrice;
    final amountText = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    _amountController = TextEditingController(text: amountText);
    _unitPriceController = TextEditingController(
      text: unit.toStringAsFixed(2),
    );
    _notesController = TextEditingController(text: m.notes ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _unitPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final t = _amountController.text.trim().replaceAll(',', '.');
    return double.tryParse(t);
  }

  double? _parsePrice() {
    final t = _unitPriceController.text.trim().replaceAll(',', '.');
    return double.tryParse(t);
  }

  void _save() {
    final amount = _parseAmount();
    final unitPrice = _parsePrice();
    if (amount == null || unitPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisá cantidad y precio unitario.')),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad debe ser mayor a cero.')),
      );
      return;
    }
    if (unitPrice < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio no puede ser negativo.')),
      );
      return;
    }

    final m = widget.movement;
    final updated = m.copyWith(
      amount: amount,
      unitPrice: unitPrice,
      salePrice: unitPrice * amount,
      basePrice: unitPrice,
      notes: _notesController.text.trim(),
    );

    ref.read(globalTransactionProvider.notifier).updateMovementOfArticle(
          widget.index,
          updated,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.movement.article.description,
        style: const TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _unitPriceController,
              decoration: const InputDecoration(
                labelText: 'Precio unitario',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
