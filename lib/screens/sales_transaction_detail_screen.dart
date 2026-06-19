import 'package:app_pos/models/transaction_list_item.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/screens/main_screen.dart';
import 'package:app_pos/services/print_service.dart';
import 'package:app_pos/services/transaction_list_service.dart';
import 'package:app_pos/utils/app_number_format.dart';
import 'package:app_pos/models/movement_of_article.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class SalesTransactionDetailScreen extends ConsumerStatefulWidget {
  final TransactionListItem? transaction;
  final String? transactionId;
  final bool returnToMainOnBack;

  const SalesTransactionDetailScreen({
    super.key,
    this.transaction,
    this.transactionId,
    this.returnToMainOnBack = false,
  }) : assert(transaction != null || transactionId != null);

  @override
  ConsumerState<SalesTransactionDetailScreen> createState() =>
      _SalesTransactionDetailScreenState();
}

class _SalesTransactionDetailScreenState
    extends ConsumerState<SalesTransactionDetailScreen> {
  final _service = TransactionListService();
  final _printService = PrintService();
  TransactionListItem? _transaction;
  Map<String, dynamic>? _transactionData;
  List<MovementOfArticle> _movements = [];
  bool _isLoading = true;
  bool _isSharing = false;
  String? _error;

  String get _transactionId =>
      widget.transaction?.id ?? widget.transactionId ?? _transaction?.id ?? '';

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
    Future.microtask(_loadDetail);
  }

  Future<void> _loadDetail() async {
    final transactionId = _transactionId;
    if (transactionId.isEmpty) {
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
      final transactionData = results[0] as Map<String, dynamic>;
      setState(() {
        _transactionData = transactionData;
        _transaction ??= TransactionListItem.fromJson(transactionData);
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

  String _pdfFileName() {
    final transaction = _transaction;
    if (transaction == null) return 'comprobante.pdf';

    final typeName = transaction.typeName?.trim();
    final number = transaction.displayNumber.trim();
    final base = (typeName != null && typeName.isNotEmpty)
        ? (number.isNotEmpty ? '$typeName $number' : typeName)
        : (number.isNotEmpty ? number : 'comprobante');

    return '${_sanitizeFileName(base)}.pdf';
  }

  String _sanitizeFileName(String value) {
    return value.replaceAll(RegExp(r'[\\/:*?"<>|]'), '-').trim();
  }

  Future<void> _sharePdf() async {
    if (_isSharing || _transactionId.isEmpty) return;

    setState(() => _isSharing = true);
    try {
      final fileName = _pdfFileName();
      final bytes = await _printService.downloadTransactionPdf(_transactionId);
      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            mimeType: 'application/pdf',
            name: fileName,
          ),
        ],
        subject: fileName.replaceAll('.pdf', ''),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al compartir: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  String? _readCompanyName() {
    final company = _transactionData?['company'];
    if (company is Map) return company['name']?.toString();
    return _transaction?.companyName;
  }

  void _goBackToMain() {
    ref.read(globalTransactionProvider.notifier).resetTransaction();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transaction = _transaction;
    final title = transaction?.displayTitle ?? 'Comprobante';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.returnToMainOnBack,
        leading: widget.returnToMainOnBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Volver',
                onPressed: _goBackToMain,
              )
            : null,
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _isLoading || _isSharing ? null : _sharePdf,
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            tooltip: 'Compartir',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadDetail,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final transaction = _transaction;
    if (transaction == null) {
      return const Center(child: Text('Transacción no encontrada'));
    }

    return Column(
      children: [
        _SalesTransactionSummary(
          transaction: transaction,
          companyName: _readCompanyName(),
          state: _transactionData?['state']?.toString() ?? transaction.state,
        ),
        Expanded(
          child: _movements.isEmpty
              ? const Center(
                  child: Text('No hay artículos en esta transacción'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _movements.length,
                  itemBuilder: (context, index) {
                    return _MovementTile(movement: _movements[index]);
                  },
                ),
        ),
      ],
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
    // Colores fijos (no dependen del tema) para garantizar contraste tanto en
    // modo claro como oscuro: el problema era que en el celular en modo oscuro
    // el texto se volvía claro sobre un naranja casi blanco y no se leía.
    const Color background = Color(0xFFFFE0B2); // orange.shade100
    const Color borderColor = Color(0xFFFB8C00); // orange.shade600
    const Color headingColor = Color(0xFFBF360C); // deepOrange.shade900
    const Color bodyColor = Color(0xFF3E2723); // brown.shade900

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: background,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 2),
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
              color: headingColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estado: $state',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: headingColor,
            ),
          ),
          if (companyName != null && companyName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(companyName!, style: const TextStyle(color: bodyColor)),
          ],
          if (transaction.employeeClosingName != null &&
              transaction.employeeClosingName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              transaction.employeeClosingName!,
              style: const TextStyle(color: bodyColor),
            ),
          ],
          if (transaction.startDate != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatSummaryDate(transaction.startDate!),
              style: const TextStyle(color: bodyColor),
            ),
          ],
          if (transaction.deliveryAddress != null &&
              transaction.deliveryAddress!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Dirección: ${transaction.deliveryAddress}',
              style: const TextStyle(color: bodyColor),
            ),
          ],
          if (transaction.deliveryCity != null &&
              transaction.deliveryCity!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Ciudad: ${transaction.deliveryCity}',
              style: const TextStyle(color: bodyColor),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Total: ${transaction.totalPrice.asMoney}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: headingColor,
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
            Text('Cantidad: ${amount.asQuantity}'),
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
