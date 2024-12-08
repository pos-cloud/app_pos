import 'package:app_pos/providers/article_provider.dart';
import 'package:app_pos/providers/category_provider.dart';
import 'package:app_pos/providers/payment_method_provider.dart';
import 'package:app_pos/screens/movement_of_articles_screen.dart';
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(transactionTypeProvider.notifier).loadTransactionTypes();
      ref.read(articlesProvider.notifier).loadArticles();
      ref.read(categoryProvider.notifier).loadCategories();
      ref.read(paymentMethodProvider.notifier).loadMethodPayment();
    });

    // Abrir el drawer automáticamente tras la construcción inicial.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState?.openDrawer();
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

  void _refresh() {
    ref.read(articlesProvider.notifier).loadArticles();
    ref.read(categoryProvider.notifier).loadCategories();
    ref.read(paymentMethodProvider.notifier).loadMethodPayment();
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
                  Consumer(
                    builder: (context, ref, _) {
                      final movementsOfArticles = ref
                          .watch(globalTransactionProvider)
                          .movementsOfArticles;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.receipt_long,
                                size: 16, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              movementsOfArticles.length.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Actualizar') {
                _refresh();
              } else {
                showDialog(
                  context: context,
                  builder: (context) => const DeleteTransactionDialog(),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Actualizar',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 10),
                      Text('Actualizar'),
                    ],
                  ),
                ),
                if (isTransactionActive)
                  const PopupMenuItem<String>(
                    value: 'Eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 10),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
              ];
            },
          ),
        ],
      ),
      body: !isTransactionActive
          ? const TransactionTypeSelectionWidget()
          : const Column(
              children: [
                SelectPaymentMethodButton(),
                Expanded(
                  child: SelectArticleWidget(),
                ),
              ],
            ),
      floatingActionButton:
          isTransactionActive ? const FinishTransactionButton() : null,
    );
  }
}
