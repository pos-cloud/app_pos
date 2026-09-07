import 'package:app_pos/utils/app_number_format.dart';
import 'package:app_pos/models/movement_of_article.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal siempre editable en cantidad y observaciones.
/// El precio unitario solo se edita si `collections.movementsOfArticles.edit` es true.
class EditMovementOfArticleDialog extends ConsumerStatefulWidget {
  final MovementOfArticle movement;
  final int index;
  final bool canEditPrice;

  const EditMovementOfArticleDialog({
    super.key,
    required this.movement,
    required this.index,
    required this.canEditPrice,
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
    _amountController = TextEditingController(text: amount.asQuantity);
    _unitPriceController =
        TextEditingController(text: AppNumberFormat.decimal(unit));
    _notesController = TextEditingController(text: m.notes ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _unitPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseAmount() => AppNumberFormat.parse(_amountController.text);

  double? _parsePrice() => AppNumberFormat.parse(_unitPriceController.text);

  void _save() {
    final amount = _parseAmount();
    final parsedPrice = _parsePrice();
    if (amount == null || (widget.canEditPrice && parsedPrice == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.canEditPrice
                ? 'Revisá cantidad y precio unitario.'
                : 'Revisá la cantidad.',
          ),
        ),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad debe ser mayor a cero.')),
      );
      return;
    }

    final unitPrice = widget.canEditPrice
        ? parsedPrice!
        : widget.movement.effectiveUnitPrice;
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
    final canEditPrice = widget.canEditPrice;

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
            if (canEditPrice)
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
              )
            else
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Precio unitario',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                child: Text(
                  '\$ ${AppNumberFormat.decimal(widget.movement.effectiveUnitPrice)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            if ((widget.movement.transactionDiscountAmount ?? 0) > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Con descuento cliente: ${widget.movement.discountedUnitPrice.asMoney}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ],
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
