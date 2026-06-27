import 'package:app_pos/models/article.dart';
import 'package:app_pos/models/tax.dart';
import 'package:app_pos/providers/article_provider.dart';
import 'package:app_pos/providers/tax_provider.dart';
import 'package:app_pos/utils/app_number_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditArticleScreen extends ConsumerStatefulWidget {
  final Article article;

  /// Si es `false`, el formulario se muestra en modo solo lectura.
  final bool canEdit;

  const EditArticleScreen({
    super.key,
    required this.article,
    this.canEdit = true,
  });

  @override
  ConsumerState<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends ConsumerState<EditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _posDescriptionController;
  late final TextEditingController _codeController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _salePriceController;
  bool _isSaving = false;
  bool _taxesRequested = false;
  String? _selectedTaxId;

  @override
  void initState() {
    super.initState();
    final article = widget.article;
    _descriptionController =
        TextEditingController(text: article.description);
    _posDescriptionController =
        TextEditingController(text: article.posDescription);
    _codeController = TextEditingController(text: article.code ?? '');
    _barcodeController = TextEditingController(text: article.barcode ?? '');
    _salePriceController = TextEditingController(
      text: AppNumberFormat.decimal(article.salePrice),
    );
    // Impuesto aplicado actualmente (tomamos el primero del array).
    if (article.taxes.isNotEmpty) {
      _selectedTaxId = article.taxes.first.taxId;
    }
  }

  double _round2(double value) => (value * 100).round() / 100;

  /// Mantiene el precio de venta fijo y calcula neto e IVA hacia atrás.
  List<ArticleTax> _buildTaxes(double salePrice, List<Tax> taxes) {
    if (_selectedTaxId == null || _selectedTaxId!.isEmpty) {
      return const [];
    }
    Tax? selected;
    for (final t in taxes) {
      if (t.id == _selectedTaxId) {
        selected = t;
        break;
      }
    }
    if (selected == null) {
      // No se encontró en el catálogo: conservamos el impuesto original.
      return widget.article.taxes;
    }

    final percentage = selected.percentage;
    if (percentage <= 0) {
      return [
        ArticleTax(
          taxId: selected.id,
          taxName: selected.name,
          percentage: percentage,
          taxBase: _round2(salePrice),
          taxAmount: 0,
        ),
      ];
    }

    final net = _round2(salePrice / (1 + percentage / 100));
    final amount = _round2(salePrice - net);
    return [
      ArticleTax(
        taxId: selected.id,
        taxName: selected.name,
        percentage: percentage,
        taxBase: net,
        taxAmount: amount,
      ),
    ];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _posDescriptionController.dispose();
    _codeController.dispose();
    _barcodeController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final salePrice = AppNumberFormat.parse(_salePriceController.text);
    if (salePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá un precio de venta válido')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final taxes = _buildTaxes(salePrice, ref.read(taxProvider));
      final updated = widget.article.copyWith(
        description: _descriptionController.text.trim(),
        posDescription: _posDescriptionController.text.trim(),
        code: _codeController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        salePrice: salePrice,
        taxes: taxes,
      );

      await ref.read(articlesProvider.notifier).updateArticle(updated);

      if (!mounted) return;
      Navigator.pop(context, updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.canEdit;

    if (!_taxesRequested) {
      _taxesRequested = true;
      Future.microtask(() {
        if (ref.read(taxProvider).isEmpty) {
          ref.read(taxProvider.notifier).loadTaxes();
        }
      });
    }

    final taxes = ref.watch(taxProvider);
    // El impuesto del artículo puede no estar en el catálogo filtrado; lo
    // agregamos como opción para no perder la selección actual.
    final taxIdsInCatalog = taxes.map((t) => t.id).toSet();
    final hasOrphanTax = _selectedTaxId != null &&
        _selectedTaxId!.isNotEmpty &&
        !taxIdsInCatalog.contains(_selectedTaxId);

    return Scaffold(
      appBar: AppBar(
        title: Text(canEdit ? 'Editar producto' : 'Producto'),
        actions: [
          if (canEdit)
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.check),
                tooltip: 'Guardar',
                onPressed: _save,
              ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!canEdit)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'No tenés permiso para editar productos.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            TextFormField(
              controller: _descriptionController,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _posDescriptionController,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'Descripción para POS',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeController,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'Código',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El código es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _barcodeController,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'Código de barras',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _salePriceController,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'Precio de venta',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El precio de venta es obligatorio';
                }
                if (AppNumberFormat.parse(value) == null) {
                  return 'Ingresá un precio válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _selectedTaxId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Impuesto (IVA)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sin impuesto'),
                ),
                if (hasOrphanTax)
                  DropdownMenuItem<String?>(
                    value: _selectedTaxId,
                    child: Text(
                      widget.article.taxes.isNotEmpty &&
                              widget.article.taxes.first.taxName.isNotEmpty
                          ? widget.article.taxes.first.taxName
                          : 'Impuesto actual',
                    ),
                  ),
                ...taxes.map(
                  (tax) => DropdownMenuItem<String?>(
                    value: tax.id,
                    child: Text(_taxLabel(tax)),
                  ),
                ),
              ],
              onChanged: canEdit
                  ? (value) => setState(() => _selectedTaxId = value)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              'El precio de venta no cambia: el neto y el IVA se recalculan a partir de él.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  String _taxLabel(Tax tax) {
    final pct = tax.percentage;
    final pctText =
        pct == pct.roundToDouble() ? pct.toStringAsFixed(0) : pct.toString();
    return tax.name.isNotEmpty ? '${tax.name} ($pctText%)' : '$pctText%';
  }
}
