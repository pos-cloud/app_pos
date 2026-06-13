import 'dart:async';
import 'package:app_pos/utils/app_number_format.dart';
import 'package:app_pos/models/sales_transaction_states.dart';
import 'package:app_pos/models/transaction_list_item.dart';
import 'package:app_pos/providers/auth_provider.dart';
import 'package:app_pos/providers/sales_transactions_provider.dart';
import 'package:app_pos/screens/sales_transaction_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalesTransactionsScreen extends ConsumerStatefulWidget {
  final String transactionState;

  const SalesTransactionsScreen({
    super.key,
    required this.transactionState,
  });

  static String titleFor(String transactionState) {
    switch (transactionState) {
      case SalesTransactionStates.open:
        return 'Abiertas';
      case SalesTransactionStates.closed:
        return 'Cerradas';
      default:
        return transactionState;
    }
  }

  static String emptyMessageFor(String transactionState) {
    switch (transactionState) {
      case SalesTransactionStates.open:
        return 'No hay ventas abiertas';
      case SalesTransactionStates.closed:
        return 'No hay ventas cerradas';
      default:
        return 'No hay ventas';
    }
  }

  @override
  ConsumerState<SalesTransactionsScreen> createState() =>
      _SalesTransactionsScreenState();
}

class _SalesTransactionsScreenState
    extends ConsumerState<SalesTransactionsScreen> {
  late final _Debouncer _debouncer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _debouncer = _Debouncer(milliseconds: 500);
    Future.microtask(_loadTransactions);
  }

  Future<void> _loadTransactions() async {
    final user = ref.read(authUserProvider);
    final employeeId = user?.employee?.id ?? '';

    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (employeeId.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'El usuario no tiene un empleado asociado';
        });
      }
      ref.read(salesTransactionsProvider.notifier).clearTransactions();
      return;
    }

    try {
      await ref.read(salesTransactionsProvider.notifier).loadTransactions(
            employeeId: employeeId,
            transactionState: widget.transactionState,
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _debouncer._timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(salesTransactionsProvider);
    final title = SalesTransactionsScreen.titleFor(widget.transactionState);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas · $title'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _isLoading ? null : _loadTransactions,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                onChanged: (text) {
                  _debouncer.run(() {
                    ref
                        .read(salesTransactionsProvider.notifier)
                        .searchTransactions(text);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar venta...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : transactions.isEmpty
                          ? Center(
                              child: Text(
                                SalesTransactionsScreen.emptyMessageFor(
                                  widget.transactionState,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadTransactions,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = transactions[index];
                                  return _SalesTransactionTile(
                                    transaction: transaction,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              SalesTransactionDetailScreen(
                                            transaction: transaction,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesTransactionTile extends StatelessWidget {
  final TransactionListItem transaction;
  final VoidCallback onTap;

  const _SalesTransactionTile({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(
            Icons.receipt_long_outlined,
            color: Colors.orange.shade800,
          ),
        ),
        title: Text(
          transaction.displayTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.companyName != null &&
                transaction.companyName!.isNotEmpty)
              Text(
                transaction.companyName!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            if (transaction.employeeClosingName != null &&
                transaction.employeeClosingName!.isNotEmpty)
              Text(
                transaction.employeeClosingName!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            if (transaction.startDate != null)
              Text(
                _formatDate(transaction.startDate!),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              transaction.totalPrice.asMoney,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} $hour:$minute';
}

class _Debouncer {
  _Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
