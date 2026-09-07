import 'package:app_pos/providers/article_provider.dart';
import 'package:app_pos/providers/auth_provider.dart';
import 'package:app_pos/providers/category_provider.dart';
import 'package:app_pos/providers/company_provider.dart';
import 'package:app_pos/providers/identification_type_provider.dart';
import 'package:app_pos/providers/vat_condition_provider.dart';
import 'package:app_pos/providers/payment_method_provider.dart';
import 'package:app_pos/providers/price_list_provider.dart';
import 'package:app_pos/screens/company_screen.dart';
import 'package:app_pos/screens/movement_of_articles_screen.dart';
import 'package:app_pos/utils/app_number_format.dart';
import 'package:app_pos/widgets/animated_article_counter.dart';
import 'package:app_pos/widgets/transaction_m3_badge.dart';
import 'package:app_pos/widgets/delete_transaction_dialog.dart';
import 'package:app_pos/widgets/finish_transaction_button.dart';
import 'package:app_pos/widgets/select_article.dart';
import 'package:app_pos/widgets/select_payment_method_button.dart';
import 'package:app_pos/widgets/transaction_type_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/widgets/navigation_drawer.dart';
import 'package:app_pos/models/transaction.dart';
import 'package:app_pos/models/transaction_type.dart';
import 'package:app_pos/models/transaction_movement.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/providers/transaction_type_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  static String path = '/main_screen';
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  /// Movimiento elegido en el menú (Venta, Compra, …); filtra los tipos de transacción.
  TransactionMovement selectedMovement = TransactionMovement.sale;
  bool _isLoading = true;

  Future<void> _loadInitialData() async {
    final user = ref.read(authUserProvider);
    final makeIds = (user?.makes ?? [])
        .map((m) => m.id)
        .where((id) => id.isNotEmpty)
        .toList();
    final makeIdsForQuery = makeIds.isNotEmpty ? makeIds : null;

    final transactionTypeIds = user?.permission?.transactionTypeIds
            .where((id) => id.isNotEmpty)
            .toList() ??
        [];
    final transactionTypeIdsForQuery =
        transactionTypeIds.isNotEmpty ? transactionTypeIds : null;

    String? companyEmployeeId;
    final perm = user?.permission;
    final emp = user?.employee;
    if (perm != null && perm.filterCompany && emp != null && emp.id.isNotEmpty) {
      companyEmployeeId = emp.id;
    }

    await Future.wait([
      ref.read(transactionTypeProvider.notifier).loadTransactionTypes(
            transactionTypeIds: transactionTypeIdsForQuery,
          ),
      ref.read(articlesProvider.notifier).loadArticles(makeIds: makeIdsForQuery),
      ref.read(categoryProvider.notifier).loadCategories(),
      ref.read(paymentMethodProvider.notifier).loadMethodPayment(),
      ref.read(companyProvider.notifier).loadCompanies(
            employeeId: companyEmployeeId,
          ),
      ref.read(priceListProvider.notifier).loadPriceLists(),
      ref
          .read(identificationTypeProvider.notifier)
          .loadIdentificationTypes(),
      ref.read(vatConditionProvider.notifier).loadVatConditions(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(_loadInitialData);
  }

  List<TransactionType> _filterTransactionTypes(
      List<TransactionType> transactionTypes) {
    return transactionTypes
        .where((transaction) =>
            transaction.transactionMovement == selectedMovement.name)
        .toList();
  }

  bool _isCompanyMissing(Transaction transaction) {
    return transaction.type.requiresCompanySelection &&
        !transaction.hasAssignedCompany;
  }

  Future<void> _openCompanyScreen() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompanyScreen(),
      ),
    );
  }

  Future<void> _onSelectTransactionType(TransactionType type) async {
    ref.read(globalTransactionProvider.notifier).updateTransactionType(type);

    if (!type.requiresCompanySelection) return;

    await _openCompanyScreen();
    if (!mounted) return;

    final current = ref.read(globalTransactionProvider).transaction;
    if (current != null && _isCompanyMissing(current)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccioná un cliente para continuar'),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await _loadInitialData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados')),
      );
    }
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos...'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionTypes = ref.watch(transactionTypeProvider);
    final currentTransaction = ref.watch(globalTransactionProvider).transaction;
    final isTransactionActive = currentTransaction != null;

    return Scaffold(
      drawer: isTransactionActive
          ? null
          : NavigationDrawerCustom(
              onItemSelected: (TransactionMovement movement) {
                setState(() => selectedMovement = movement);
                Navigator.of(context).pop();
              },
            ),
      appBar: AppBar(
        title: isTransactionActive
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MovementOfArticlesScreen(),
                        ),
                      );
                    },
                    child: Text(
                      currentTransaction.type.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const AnimatedArticleCounter(),
                  const SizedBox(width: 8),
                  const TransactionM3Badge(),
                ],
              )
            : Text(selectedMovement.name),
        actions: [
          if (!isTransactionActive)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar datos',
              onPressed: () => _refresh(),
            ),
          if (isTransactionActive &&
              currentTransaction.type.requestsCompany)
            IconButton(
              icon: Badge(
                isLabelVisible: currentTransaction.hasCompanyDiscount,
                label: Text(
                  '-${currentTransaction.discountPercent.asPercent}',
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: Colors.green.shade700,
                child: Icon(
                  _isCompanyMissing(currentTransaction)
                      ? Icons.person_add
                      : Icons.person,
                  color: _isCompanyMissing(currentTransaction)
                      ? Colors.red
                      : Colors.amber,
                ),
              ),
              tooltip: currentTransaction.hasAssignedCompany
                  ? (currentTransaction.company!.name.isNotEmpty
                      ? (currentTransaction.hasCompanyDiscount
                          ? 'Cliente: ${currentTransaction.company!.name} · Desc. ${currentTransaction.discountPercent.asPercent}'
                          : 'Cliente: ${currentTransaction.company!.name}')
                      : 'Cliente asignado')
                  : (currentTransaction.type.requiresCompanySelection
                      ? 'Cliente obligatorio'
                      : 'Seleccionar cliente'),
              onPressed: () => _openCompanyScreen(),
            ),
          if (isTransactionActive)
            PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              onSelected: (value) {
                if (value == 'eliminar') {
                  showDialog(
                    context: context,
                    builder: (context) => const DeleteTransactionDialog(),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red.shade700),
                        const SizedBox(width: 10),
                        Text('Eliminar',
                            style: TextStyle(color: Colors.red.shade700)),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          if (!isTransactionActive)
            TransactionTypeSelectionWidget(
              movementLabel: selectedMovement.name,
              transactionTypes: _filterTransactionTypes(transactionTypes),
              onSelect: _onSelectTransactionType,
            )
          else
            _TransactionBody(transactionType: currentTransaction.type),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton:
          isTransactionActive ? const FinishTransactionButton() : null,
    );
  }
}

/// Cuerpo de la transacción que muestra condicionalmente según el tipo.
class _TransactionBody extends StatelessWidget {
  final TransactionType transactionType;

  const _TransactionBody({required this.transactionType});

  @override
  Widget build(BuildContext context) {
    final showArticles = transactionType.requestArticles;
    final showCobrar = transactionType.requestPaymentMethods;

    return Column(
      children: [
        const _CompanyDiscountBanner(),
        if (showCobrar)
          const SelectPaymentMethodButton()
        else if (showArticles)
          const SelectPaymentMethodButton(paymentFlow: false),
        Expanded(
          child: showArticles
              ? const SelectArticleWidget()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _CompanyDiscountBanner extends ConsumerWidget {
  const _CompanyDiscountBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(globalTransactionProvider).transaction;
    if (transaction == null || !transaction.hasCompanyDiscount) {
      return const SizedBox.shrink();
    }

    final companyName = transaction.company?.name;
    final label = (companyName != null && companyName.isNotEmpty)
        ? 'Descuento ${transaction.discountPercent.asPercent} de $companyName'
        : 'Descuento cliente ${transaction.discountPercent.asPercent}';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? Colors.green.shade900.withValues(alpha: 0.45) : Colors.green.shade50;
    final foreground =
        isDark ? Colors.green.shade100 : Colors.green.shade900;

    return Material(
      color: background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.local_offer, size: 18, color: foreground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (transaction.discountAmount > 0)
              Text(
                '-${transaction.discountAmount.asMoney}',
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
