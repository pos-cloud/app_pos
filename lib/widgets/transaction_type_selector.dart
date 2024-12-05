import 'package:app_pos/models/transaction_type.dart';
import 'package:flutter/material.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType? selectedTransactionType;
  final List<TransactionType> transactionTypes;
  final ValueChanged<TransactionType?> onChanged;

  const TransactionTypeSelector({
    Key? key,
    required this.selectedTransactionType,
    required this.transactionTypes,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TransactionType>(
      hint: const Text("Seleccione una transacción"),
      value: selectedTransactionType,
      onChanged: onChanged,
      items: transactionTypes.map<DropdownMenuItem<TransactionType>>(
        (TransactionType transactionType) {
          return DropdownMenuItem<TransactionType>(
            value: transactionType,
            child: Text(transactionType.name),
          );
        },
      ).toList(),
    );
  }
}
