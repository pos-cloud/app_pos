import 'package:app_pos/models/article.dart';
import 'package:app_pos/models/category.dart';
import 'package:app_pos/models/make.dart';
import 'package:app_pos/models/tax.dart';
import 'package:app_pos/providers/article_provider.dart';
import 'package:app_pos/providers/category_provider.dart';
import 'package:app_pos/providers/make_provider.dart';
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
  late final TextEditingController _basePriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _markupPercentageController;
  late final TextEditingController _markupPriceController;
  late final TextEditingController _salePriceController;

  bool _isSaving = false;
  bool _catalogsRequested = false;
  String? _selectedCategoryId;
  String? _selectedMakeId;
  String? _taxToAddId;
  late List<ArticleTax> _taxes;

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
    _basePriceController = TextEditingController(
      text: AppNumberFormat.decimal(article.basePrice),
    );
    _costPriceController = TextEditingController(
      text: AppNumberFormat.decimal(article.costPrice),
    );
    _markupPercentageController = TextEditingController(
      text: AppNumberFormat.decimal(article.markupPercentage),
    );
    _markupPriceController = TextEditingController(
      text: AppNumberFormat.decimal(article.markupPrice),
    );
    _salePriceController = TextEditingController(
      text: AppNumberFormat.decimal(article.salePrice),
    );
    _selectedCategoryId = article.category?.id;
    _selectedMakeId = article.make?.id;
    _taxes = List<ArticleTax>.from(article.taxes);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _posDescriptionController.dispose();
    _codeController.dispose();
    _barcodeController.dispose();
    _basePriceController.dispose();
    _costPriceController.dispose();
    _markupPercentageController.dispose();
    _markupPriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  double _round2(double value) => (value * 100).round() / 100;

  double _read(TextEditingController c) =>
      AppNumberFormat.parse(c.text) ?? 0;

  void _setDecimal(TextEditingController c, double value) {
    c.text = AppNumberFormat.decimal(_round2(value));
  }

  /// Misma cadena que app-web: base → impuestos → costo → markup → venta.
  void _updatePrices(String op) {
    var basePrice = _read(_basePriceController);
    var costPrice = _read(_costPriceController);
    var markupPercentage = _read(_markupPercentageController);
    var markupPrice = _read(_markupPriceController);
    var salePrice = _read(_salePriceController);

    switch (op) {
      case 'basePrice':
      case 'taxes':
        final recalculated = <ArticleTax>[];
        var totalTaxes = 0.0;
        for (final tax in _taxes) {
          if (tax.percentage != 0) {
            final taxBase = _round2(basePrice);
            final taxAmount = _round2((taxBase * tax.percentage) / 100);
            totalTaxes += taxAmount;
            recalculated.add(tax.copyWith(
              taxBase: taxBase,
              taxAmount: taxAmount,
            ));
          } else {
            recalculated.add(tax.copyWith(taxBase: basePrice, taxAmount: 0));
          }
        }
        _taxes = recalculated;
        costPrice = _round2(basePrice + totalTaxes);
        if (!(basePrice == 0 && salePrice != 0)) {
          markupPrice = _round2((costPrice * markupPercentage) / 100);
          salePrice = _round2(costPrice + markupPrice);
        }
        break;
      case 'markupPercentage':
        if (!(basePrice == 0 && salePrice != 0)) {
          markupPrice = _round2((costPrice * markupPercentage) / 100);
          salePrice = _round2(costPrice + markupPrice);
        }
        break;
      case 'markupPrice':
        if (!(basePrice == 0 && salePrice != 0)) {
          if (costPrice != 0) {
            markupPercentage = _round2((markupPrice / costPrice) * 100);
          }
          salePrice = _round2(costPrice + markupPrice);
        }
        break;
      case 'salePrice':
        if (basePrice == 0) {
          costPrice = 0;
          markupPercentage = 100;
          markupPrice = salePrice;
        } else {
          markupPrice = _round2(salePrice - costPrice);
          if (costPrice != 0) {
            markupPercentage = _round2((markupPrice / costPrice) * 100);
          }
        }
        break;
    }

    setState(() {
      _setDecimal(_basePriceController, basePrice);
      _setDecimal(_costPriceController, costPrice);
      _setDecimal(_markupPercentageController, markupPercentage);
      _setDecimal(_markupPriceController, markupPrice);
      _setDecimal(_salePriceController, salePrice);
    });
  }

  void _addTax(List<Tax> catalog) {
    if (_taxToAddId == null || _taxToAddId!.isEmpty) return;
    if (_taxes.any((t) => t.taxId == _taxToAddId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ese impuesto ya está agregado')),
      );
      return;
    }
    Tax? selected;
    for (final t in catalog) {
      if (t.id == _taxToAddId) {
        selected = t;
        break;
      }
    }
    if (selected == null) return;

    final basePrice = _read(_basePriceController);
    final taxBase = _round2(basePrice);
    final taxAmount = selected.percentage == 0
        ? 0.0
        : _round2((taxBase * selected.percentage) / 100);

    setState(() {
      _taxes = [
        ..._taxes,
        ArticleTax(
          taxId: selected!.id,
          taxName: selected.name,
          percentage: selected.percentage,
          taxBase: taxBase,
          taxAmount: taxAmount,
        ),
      ];
      _taxToAddId = null;
    });
    _updatePrices('taxes');
  }

  void _removeTax(int index) {
    setState(() {
      _taxes = List<ArticleTax>.from(_taxes)..removeAt(index);
    });
    _updatePrices('taxes');
  }

  Future<void> _ensureCatalogsLoaded() async {
    final futures = <Future<void>>[
      if (ref.read(categoryProvider).isEmpty)
        ref.read(categoryProvider.notifier).loadCategories(),
      if (ref.read(makeProvider).isEmpty)
        ref.read(makeProvider.notifier).loadMakes(),
      // Siempre recargamos impuestos: el catálogo es chico y antes podía
      // quedar vacío por un 404 silencioso a /v2/taxes.
      ref.read(taxProvider.notifier).loadTaxes(),
    ];
    await Future.wait(futures);
  }

  Tax? _findTaxInCatalog(String? taxId, List<Tax> catalog) {
    if (taxId == null || taxId.isEmpty) return null;
    for (final t in catalog) {
      if (t.id == taxId) return t;
    }
    return null;
  }

  String _articleTaxLabel(ArticleTax tax, List<Tax> catalog) {
    final fromCatalog = _findTaxInCatalog(tax.taxId, catalog);
    if (fromCatalog != null) {
      final pct = fromCatalog.percentage;
      final pctText = pct == pct.roundToDouble()
          ? pct.toStringAsFixed(0)
          : pct.toString();
      final name = fromCatalog.name.isNotEmpty
          ? fromCatalog.name
          : (tax.taxName.isNotEmpty ? tax.taxName : 'Impuesto');
      return '$name ($pctText%)';
    }
    if (tax.taxName.isNotEmpty) {
      final pct = tax.percentage;
      final pctText =
          pct == pct.roundToDouble() ? pct.toStringAsFixed(0) : pct.toString();
      return '${tax.taxName} ($pctText%)';
    }
    return 'Impuesto';
  }

  void _enrichTaxNames(List<Tax> catalog) {
    if (catalog.isEmpty || _taxes.isEmpty) return;
    var changed = false;
    final enriched = <ArticleTax>[];
    for (final tax in _taxes) {
      final match = _findTaxInCatalog(tax.taxId, catalog);
      if (match != null &&
          (tax.taxName != match.name || tax.percentage != match.percentage)) {
        changed = true;
        enriched.add(tax.copyWith(
          taxName: match.name,
          percentage: match.percentage,
        ));
      } else {
        enriched.add(tax);
      }
    }
    if (changed) {
      setState(() => _taxes = enriched);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La categoría es obligatoria')),
      );
      return;
    }

    final basePrice = AppNumberFormat.parse(_basePriceController.text);
    final costPrice = AppNumberFormat.parse(_costPriceController.text);
    final markupPercentage =
        AppNumberFormat.parse(_markupPercentageController.text);
    final markupPrice = AppNumberFormat.parse(_markupPriceController.text);
    final salePrice = AppNumberFormat.parse(_salePriceController.text);

    if (basePrice == null ||
        costPrice == null ||
        markupPercentage == null ||
        markupPrice == null ||
        salePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisá los importes ingresados')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final categories = ref.read(categoryProvider);
      final makes = ref.read(makeProvider);

      Category? category;
      for (final c in categories) {
        if (c.id == _selectedCategoryId) {
          category = c;
          break;
        }
      }
      category ??= Category(id: _selectedCategoryId, description: '');

      Make? make;
      if (_selectedMakeId != null && _selectedMakeId!.isNotEmpty) {
        for (final m in makes) {
          if (m.id == _selectedMakeId) {
            make = m;
            break;
          }
        }
        make ??= Make(
          id: _selectedMakeId!,
          description: '',
          visibleSale: false,
          picture: '',
        );
      }

      var posDescription = _posDescriptionController.text.trim();
      if (posDescription.isEmpty) {
        final desc = _descriptionController.text.trim();
        posDescription =
            desc.length > 20 ? desc.substring(0, 20) : desc;
      }

      final updated = widget.article.copyWith(
        description: _descriptionController.text.trim(),
        posDescription: posDescription,
        code: _codeController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        basePrice: basePrice,
        costPrice: costPrice,
        markupPercentage: markupPercentage,
        markupPrice: markupPrice,
        salePrice: salePrice,
        taxes: _taxes,
        category: category,
        make: make,
        clearMake: make == null,
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

    if (!_catalogsRequested) {
      _catalogsRequested = true;
      Future.microtask(() async {
        await _ensureCatalogsLoaded();
        if (!mounted) return;
        _enrichTaxNames(ref.read(taxProvider));
      });
    }

    final categories = ref.watch(categoryProvider);
    final makes = ref.watch(makeProvider);
    final taxCatalog = ref.watch(taxProvider);

    final categoryIds = categories.map((c) => c.id).whereType<String>().toSet();
    final hasOrphanCategory = _selectedCategoryId != null &&
        _selectedCategoryId!.isNotEmpty &&
        !categoryIds.contains(_selectedCategoryId);

    final makeIds = makes.map((m) => m.id).toSet();
    final hasOrphanMake = _selectedMakeId != null &&
        _selectedMakeId!.isNotEmpty &&
        !makeIds.contains(_selectedMakeId);

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
              controller: _codeController,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'Código *',
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
              controller: _descriptionController,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                if (_posDescriptionController.text.trim().isEmpty) {
                  final trimmed = value.trim();
                  _posDescriptionController.text = trimmed.length > 20
                      ? trimmed.substring(0, 20)
                      : trimmed;
                }
              },
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
              maxLength: 20,
              decoration: const InputDecoration(
                labelText: 'Descripción para POS *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción POS es obligatoria';
                }
                if (value.trim().length > 20) {
                  return 'Máximo 20 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey('category-${categories.length}-$_selectedCategoryId'),
              initialValue: categoryIds.contains(_selectedCategoryId) ||
                      hasOrphanCategory
                  ? _selectedCategoryId
                  : null,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Categoría *',
                border: OutlineInputBorder(),
              ),
              items: [
                if (hasOrphanCategory)
                  DropdownMenuItem<String?>(
                    value: _selectedCategoryId,
                    child: Text(
                      widget.article.category?.description?.isNotEmpty == true
                          ? widget.article.category!.description!
                          : 'Categoría actual',
                    ),
                  ),
                ...categories
                    .where((c) => c.id != null && c.id!.isNotEmpty)
                    .map(
                      (c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text(c.description ?? c.id!),
                      ),
                    ),
              ],
              onChanged: canEdit
                  ? (value) => setState(() => _selectedCategoryId = value)
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La categoría es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey('make-${makes.length}-$_selectedMakeId'),
              initialValue:
                  makeIds.contains(_selectedMakeId) || hasOrphanMake
                      ? _selectedMakeId
                      : null,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Marca',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sin marca'),
                ),
                if (hasOrphanMake)
                  DropdownMenuItem<String?>(
                    value: _selectedMakeId,
                    child: Text(
                      widget.article.make?.description.isNotEmpty == true
                          ? widget.article.make!.description
                          : 'Marca actual',
                    ),
                  ),
                ...makes.map(
                  (m) => DropdownMenuItem<String?>(
                    value: m.id,
                    child: Text(
                      m.description.isNotEmpty ? m.description : m.id,
                    ),
                  ),
                ),
              ],
              onChanged: canEdit
                  ? (value) => setState(() => _selectedMakeId = value)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              'Precios e impuestos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'El precio de venta se calcula: base + impuestos + utilidad (como en la web).',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            _moneyField(
              controller: _basePriceController,
              label: 'Precio base *',
              enabled: canEdit,
              onChangedOp: 'basePrice',
            ),
            const SizedBox(height: 12),
            Text(
              'Impuestos',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (canEdit)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      key: ValueKey('tax-add-$_taxToAddId'),
                      initialValue: _taxToAddId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Agregar impuesto',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Seleccionar…'),
                        ),
                        ...taxCatalog.map(
                          (tax) => DropdownMenuItem<String?>(
                            value: tax.id,
                            child: Text(_taxLabel(tax)),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _taxToAddId = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: IconButton.filled(
                      onPressed: () => _addTax(taxCatalog),
                      icon: const Icon(Icons.add),
                      tooltip: 'Agregar impuesto',
                    ),
                  ),
                ],
              ),
            if (_taxes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Sin impuestos aplicados',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              ...List.generate(_taxes.length, (index) {
                final tax = _taxes[index];
                return Card(
                  margin: const EdgeInsets.only(top: 8),
                  child: ListTile(
                    dense: true,
                    title: Text(_articleTaxLabel(tax, taxCatalog)),
                    subtitle: Text(
                      'Base ${AppNumberFormat.money(tax.taxBase)} · '
                      '${AppNumberFormat.money(tax.taxAmount)}',
                    ),
                    trailing: canEdit
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeTax(index),
                          )
                        : null,
                  ),
                );
              }),
            const SizedBox(height: 12),
            _moneyField(
              controller: _costPriceController,
              label: 'Precio de costo',
              enabled: false,
            ),
            const SizedBox(height: 12),
            _moneyField(
              controller: _markupPercentageController,
              label: '% Utilidad *',
              enabled: canEdit,
              prefixText: null,
              suffixText: '%',
              onChangedOp: 'markupPercentage',
            ),
            const SizedBox(height: 12),
            _moneyField(
              controller: _markupPriceController,
              label: '\$ Utilidad *',
              enabled: canEdit,
              onChangedOp: 'markupPrice',
            ),
            const SizedBox(height: 12),
            _moneyField(
              controller: _salePriceController,
              label: 'Precio de venta *',
              enabled: canEdit,
              onChangedOp: 'salePrice',
            ),
          ],
        ),
      ),
    );
  }

  Widget _moneyField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    String? prefixText = '\$ ',
    String? suffixText,
    String? onChangedOp,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus && enabled && onChangedOp != null) {
          _updatePrices(onChangedOp);
        }
      },
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          suffixText: suffixText,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onFieldSubmitted: enabled && onChangedOp != null
            ? (_) => _updatePrices(onChangedOp)
            : null,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo obligatorio';
          }
          if (AppNumberFormat.parse(value) == null) {
            return 'Ingresá un importe válido';
          }
          return null;
        },
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
