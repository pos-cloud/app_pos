import 'package:app_pos/providers/article_provider.dart';
import 'package:app_pos/providers/category_provider.dart';
import 'package:app_pos/providers/company_provider.dart';
import 'package:app_pos/providers/payment_method_provider.dart';
import 'package:app_pos/providers/price_list_provider.dart';
import 'package:app_pos/screens/company_screen.dart';
import 'package:app_pos/screens/price_list_screen.dart';
import 'package:app_pos/screens/finish_transaction_screen.dart';
import 'package:app_pos/screens/movement_of_articles_screen.dart';
import 'package:app_pos/widgets/animated_article_counter.dart';
import 'package:app_pos/widgets/delete_transaction_dialog.dart';
import 'package:app_pos/widgets/finish_transaction_button.dart';
import 'package:app_pos/widgets/select_article.dart';
import 'package:app_pos/widgets/select_payment_method_button.dart';
import 'package:app_pos/widgets/transaction_type_selection.dart';
import 'package:app_pos/widgets/transaction_type_selector.dart';
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

  TransactionMovement? selectedMovement;
  TransactionType? selectedTransactionType;
  bool _isLoading = true;

  Future<void> _loadInitialData() async {
    await Future.wait([
      ref.read(transactionTypeProvider.notifier).loadTransactionTypes(),
      ref.read(articlesProvider.notifier).loadArticles(),
      ref.read(categoryProvider.notifier).loadCategories(),
      ref.read(paymentMethodProvider.notifier).loadMethodPayment(),
      ref.read(companyProvider.notifier).loadCompanies(),
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
    if (selectedMovement == null) {
      return transactionTypes;
    }
    return transactionTypes
        .where((transaction) =>
            transaction.transactionMovement == selectedMovement!.name)
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
                setState(() {
                  selectedMovement = movement;
                  selectedTransactionType = null;
                });
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
            : TransactionTypeSelector(
                selectedTransactionType: null,
                transactionTypes: _filterTransactionTypes(transactionTypes),
                onChanged: (TransactionType? newValue) {
                  ref
                      .read(globalTransactionProvider.notifier)
                      .updateTransactionType(newValue);
                },
              ),
        actions: [
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
          if (isTransactionActive &&
              currentTransaction.type.allowPriceList == true)
            IconButton(
              icon: Icon(
                Icons.list_alt,
                color: currentTransaction.priceList != null
                    ? Colors.amber
                    : null,
              ),
              tooltip: currentTransaction.priceList != null
                  ? 'Lista: ${currentTransaction.priceList!.name}'
                  : 'Lista de precios',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PriceListScreen(),
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'Actualizar') {
                await _refresh();
              } else {
                showDialog(
                  context: context,
                  builder: (context) => const DeleteTransactionDialog(),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              final iconColor = Theme.of(context).colorScheme.onSurface;
              return [
                PopupMenuItem<String>(
                  value: 'Actualizar',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: iconColor),
                      const SizedBox(width: 10),
                      const Text('Actualizar'),
                    ],
                  ),
                ),
                if (isTransactionActive)
                  PopupMenuItem<String>(
                    value: 'Eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red.shade700),
                        const SizedBox(width: 10),
                        Text('Eliminar', style: TextStyle(color: Colors.red.shade700)),
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
            const TransactionTypeSelectionWidget()
          else
            _TransactionBody(transactionType: currentTransaction.type),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: isTransactionActive &&
              currentTransaction.type.requestPaymentMethods
          ? const FinishTransactionButton()
          : null,
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
        else
          _FinalizeButton(transactionType: transactionType),
        Expanded(
          child: showArticles
              ? const SelectArticleWidget()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Botón "Finalizar" para transacciones que no requieren métodos de pago.
class _FinalizeButton extends ConsumerWidget {
  final TransactionType transactionType;

  const _FinalizeButton({required this.transactionType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalTransaction = ref.watch(globalTransactionProvider);
    final hasArticles = globalTransaction.movementsOfArticles.isNotEmpty;
    final canFinalize =
        !transactionType.requestArticles || hasArticles;

    if (!canFinalize) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      width: double.infinity,
      child: SizedBox(
        height: 70,
        child: ElevatedButton(
          onPressed: () => _finalizeTransaction(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
          ),
          child: const Text(
            "Finalizar",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finalizeTransaction(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(globalTransactionProvider.notifier);
      final transactionId = await notifier.syncTransaction();

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => FinalTransactionScreen(transactionId: transactionId),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al finalizar: $e')),
      );
    }
  }
}
