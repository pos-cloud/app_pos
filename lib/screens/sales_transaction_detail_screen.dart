import 'package:app_pos/utils/app_number_format.dart';
import 'package:app_pos/models/movement_of_article.dart';
import 'package:app_pos/models/transaction_list_item.dart';
import 'package:app_pos/services/transaction_list_service.dart';
import 'package:flutter/material.dart';

class SalesTransactionDetailScreen extends StatefulWidget {
  final TransactionListItem transaction;

  const SalesTransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<SalesTransactionDetailScreen> createState() =>
      _SalesTransactionDetailScreenState();
}

class _SalesTransactionDetailScreenState
    extends State<SalesTransactionDetailScreen> {
  final _service = TransactionListService();
  Map<String, dynamic>? _transactionData;
  List<MovementOfArticle> _movements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDetail);
  }

  Future<void> _loadDetail() async {
    final transactionId = widget.transaction.id;
    if (transactionId == null || transactionId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'La transacción no tiene identificador';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.getTransactionById(transactionId),
        _service.getMovementsOfArticlesByTransaction(transactionId),
      ]);

      if (!mounted) return;
      setState(() {
        _transactionData = results[0] as Map<String, dynamic>;
        _movements = results[1] as List<MovementOfArticle>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String? _readCompanyName() {
    final company = _transactionData?['company'];
    if (company is Map) return company['name']?.toString();
    return widget.transaction.companyName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction.displayTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : Column(
                  children: [
                    _SalesTransactionSummary(
                      transaction: widget.transaction,
                      companyName: _readCompanyName(),
                      state: _transactionData?['state']?.toString() ?? '',
                    ),
                    Expanded(
                      child: _movements.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay artículos en esta transacción',
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _movements.length,
                              itemBuilder: (context, index) {
                                final movement = _movements[index];
                                return _MovementTile(movement: movement);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _SalesTransactionSummary extends StatelessWidget {
  final TransactionListItem transaction;
  final String? companyName;
  final String state;

  const _SalesTransactionSummary({
    required this.transaction,
    required this.companyName,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.displayTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estado: $state',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (companyName != null && companyName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(companyName!),
          ],
          if (transaction.employeeClosingName != null &&
              transaction.employeeClosingName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(transaction.employeeClosingName!),
          ],
          if (transaction.startDate != null) ...[
            const SizedBox(height: 4),
            Text(_formatSummaryDate(transaction.startDate!)),
          ],
          if (transaction.deliveryAddress != null &&
              transaction.deliveryAddress!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Dirección: ${transaction.deliveryAddress}'),
          ],
          if (transaction.deliveryCity != null &&
              transaction.deliveryCity!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Ciudad: ${transaction.deliveryCity}'),
          ],
          const SizedBox(height: 8),
          Text(
            'Total: ${transaction.totalPrice.asMoney}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final MovementOfArticle movement;

  const _MovementTile({required this.movement});

  @override
  Widget build(BuildContext context) {
    final unitPrice = movement.effectiveUnitPrice;
    final amount = movement.effectiveAmount;
    final lineTotal = movement.lineTotal;
    final description = movement.article.description.isNotEmpty
        ? movement.article.description
        : (movement.description ?? 'Artículo');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cantidad: ${amount.asQuantity}',
            ),
            Text(
              'Precio unitario: ${unitPrice.asMoney}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            Text(
              'Total: ${lineTotal.asMoney}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatSummaryDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} $hour:$minute';
}
