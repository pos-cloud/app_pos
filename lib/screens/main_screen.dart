import 'package:app_pos/providers/article_provider.dart';
import 'package:app_pos/providers/auth_provider.dart';
import 'package:app_pos/providers/category_provider.dart';
import 'package:app_pos/providers/company_provider.dart';
import 'package:app_pos/providers/payment_method_provider.dart';
import 'package:app_pos/providers/price_list_provider.dart';
import 'package:app_pos/screens/company_screen.dart';
import 'package:app_pos/screens/price_list_screen.dart';
import 'package:app_pos/screens/movement_of_articles_screen.dart';
import 'package:app_pos/widgets/animated_article_counter.dart';
import 'package:app_pos/widgets/delete_transaction_dialog.dart';
import 'package:app_pos/widgets/finish_transaction_button.dart';
import 'package:app_pos/widgets/select_article.dart';
import 'package:app_pos/widgets/select_payment_method_button.dart';
import 'package:app_pos/widgets/transaction_type_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/widgets/navigation_drawer.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _loadInitialData();
      if (mounted) {
        _scaffoldKey.currentState?.openDrawer();
      }
    });
  }

  List<TransactionType> _filterTransactionTypes(
      List<TransactionType> transactionTypes) {
    return transactionTypes
        .where((transaction) =>
            transaction.transactionMovement == selectedMovement.name)
        .toList();
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
      key: _scaffoldKey,
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
              currentTransaction.type.requestCompany != null)
            IconButton(
              icon: Icon(
                currentTransaction.company == null
                    ? Icons.person_add
                    : Icons.person,
                color: currentTransaction.company != null
                    ? Colors.amber
                    : null,
              ),
              tooltip: currentTransaction.company != null
                  ? 'Cliente: ${currentTransaction.company!.name}'
                  : 'Seleccionar cliente',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompanyScreen(),
                  ),
                );
              },
            ),
          if (isTransactionActive)
            PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              onSelected: (value) {
                if (value == 'lista_precios') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PriceListScreen(),
                    ),
                  );
                } else if (value == 'eliminar') {
                  showDialog(
                    context: context,
                    builder: (context) => const DeleteTransactionDialog(),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                final iconColor = Theme.of(context).colorScheme.onSurface;
                final listaLabel = currentTransaction.priceList != null
                    ? 'Lista: ${currentTransaction.priceList!.name}'
                    : 'Lista de precios';
                return [
                  if (currentTransaction.type.allowPriceList == true)
                    PopupMenuItem<String>(
                      value: 'lista_precios',
                      child: Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: currentTransaction.priceList != null
                                ? Colors.amber.shade700
                                : iconColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              listaLabel,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
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
              onSelect: (TransactionType type) {
                ref
                    .read(globalTransactionProvider.notifier)
                    .updateTransactionType(type);
              },
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
class _TransactionBody extends ConsumerWidget {
  final TransactionType transactionType;

  const _TransactionBody({required this.transactionType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showArticles = transactionType.requestArticles;
    final showCobrar = transactionType.requestPaymentMethods;

    return Column(
      children: [
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
