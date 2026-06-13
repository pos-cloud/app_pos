import 'package:app_pos/models/company.dart';
import 'package:app_pos/models/identification_type.dart';
import 'package:app_pos/models/vat_condition.dart';
import 'package:app_pos/providers/company_provider.dart';
import 'package:app_pos/providers/identification_type_provider.dart';
import 'package:app_pos/providers/vat_condition_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditClientScreen extends ConsumerStatefulWidget {
  final Company company;

  const EditClientScreen({
    super.key,
    required this.company,
  });

  @override
  ConsumerState<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends ConsumerState<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _fantasyNameController;
  late final TextEditingController _identificationValueController;
  late final TextEditingController _phonesController;
  late final TextEditingController _emailsController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  IdentificationType? _selectedIdentificationType;
  String? _selectedVatConditionId;
  bool _isSaving = false;
  bool _catalogsRequested = false;

  @override
  void initState() {
    super.initState();
    final company = widget.company;
    _nameController = TextEditingController(text: company.name);
    _fantasyNameController =
        TextEditingController(text: company.fantasyName ?? '');
    _identificationValueController =
        TextEditingController(text: company.identificationValue ?? '');
    _phonesController = TextEditingController(text: company.phones ?? '');
    _emailsController = TextEditingController(text: company.emails ?? '');
    _addressController = TextEditingController(text: company.address ?? '');
    _cityController = TextEditingController(text: company.city ?? '');
    _selectedIdentificationType = company.identificationType;
    _selectedVatConditionId = company.vatCondition;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fantasyNameController.dispose();
    _identificationValueController.dispose();
    _phonesController.dispose();
    _emailsController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  IdentificationType? _resolveIdentificationType(
    List<IdentificationType> types,
  ) {
    final current = _selectedIdentificationType;
    if (current == null) return null;

    if (current.id != null && current.id!.isNotEmpty) {
      for (final type in types) {
        if (type.id == current.id) return type;
      }
    }

    if (current.name.isNotEmpty) {
      for (final type in types) {
        if (type.name == current.name) return type;
      }
    }

    return current.id != null ? current : null;
  }

  String? _resolveVatConditionId(List<VatCondition> conditions) {
    final currentId = _selectedVatConditionId;
    if (currentId == null || currentId.isEmpty) return null;

    for (final condition in conditions) {
      if (condition.id == currentId) return condition.id;
    }

    return currentId;
  }

  Future<void> _ensureCatalogsLoaded() async {
    final futures = <Future<void>>[];
    if (ref.read(identificationTypeProvider).isEmpty) {
      futures.add(
        ref.read(identificationTypeProvider.notifier).loadIdentificationTypes(),
      );
    }
    if (ref.read(vatConditionProvider).isEmpty) {
      futures.add(
        ref.read(vatConditionProvider.notifier).loadVatConditions(),
      );
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedIdentificationType?.id == null ||
        _selectedIdentificationType!.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná un tipo de identificación')),
      );
      return;
    }

    if (_selectedVatConditionId == null || _selectedVatConditionId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná una condición de IVA')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = widget.company.copyWith(
        name: _nameController.text.trim(),
        type: Company.clientType,
        fantasyName: _fantasyNameController.text.trim().isEmpty
            ? null
            : _fantasyNameController.text.trim(),
        identificationType: _selectedIdentificationType,
        identificationValue: _identificationValueController.text.trim().isEmpty
            ? null
            : _identificationValueController.text.trim(),
        vatCondition: _selectedVatConditionId,
        phones: _phonesController.text.trim().isEmpty
            ? null
            : _phonesController.text.trim(),
        emails: _emailsController.text.trim().isEmpty
            ? null
            : _emailsController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
      );

      await ref.read(companyProvider.notifier).updateCompany(updated);

      if (!mounted) return;
      Navigator.pop(context, updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente actualizado')),
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
    if (!_catalogsRequested) {
      _catalogsRequested = true;
      Future.microtask(_ensureCatalogsLoaded);
    }

    final identificationTypes = ref.watch(identificationTypeProvider);
    final vatConditions = ref.watch(vatConditionProvider);
    final catalogsLoading =
        identificationTypes.isEmpty || vatConditions.isEmpty;

    final resolvedIdentificationType =
        _resolveIdentificationType(identificationTypes);
    final resolvedVatConditionId = _resolveVatConditionId(vatConditions);

    if (_selectedIdentificationType?.id == null &&
        resolvedIdentificationType?.id != null) {
      _selectedIdentificationType = resolvedIdentificationType;
    }

    if ((_selectedVatConditionId == null || _selectedVatConditionId!.isEmpty) &&
        resolvedVatConditionId != null) {
      _selectedVatConditionId = resolvedVatConditionId;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar cliente'),
        actions: [
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
              onPressed: catalogsLoading ? null : _save,
            ),
        ],
      ),
      body: catalogsLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fantasyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre fantasía',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: vatConditions.any(
                      (condition) => condition.id == _selectedVatConditionId,
                    )
                        ? _selectedVatConditionId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Condición de IVA',
                      border: OutlineInputBorder(),
                    ),
                    items: vatConditions
                        .where((condition) =>
                            condition.id != null && condition.id!.isNotEmpty)
                        .map(
                          (condition) => DropdownMenuItem<String>(
                            value: condition.id,
                            child: Text(condition.description),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedVatConditionId = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleccioná una condición de IVA';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: identificationTypes.any(
                      (type) => type.id == _selectedIdentificationType?.id,
                    )
                        ? _selectedIdentificationType?.id
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de identificación',
                      border: OutlineInputBorder(),
                    ),
                    items: identificationTypes
                        .where((type) => type.id != null && type.id!.isNotEmpty)
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type.id,
                            child: Text(type.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIdentificationType = identificationTypes
                            .firstWhere((type) => type.id == value);
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleccioná un tipo de identificación';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _identificationValueController,
                    decoration: const InputDecoration(
                      labelText: 'Número de identificación',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phonesController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailsController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
    );
  }
}
