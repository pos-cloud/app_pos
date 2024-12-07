import 'package:app_pos/providers/article_provider.dart';
import 'package:app_pos/providers/category_provider.dart';
import 'package:app_pos/providers/payment_method_provider.dart';
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

    // Cargar los datos iniciales.
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

  void _clearTicket() {
    ref.read(globalTransactionProvider.notifier).resetTransaction();

    setState(() {
      selectedTransactionType = null;
    });
  }

  void _refresh() {
    ref.read(articlesProvider.notifier).loadArticles();
    ref.read(categoryProvider.notifier).loadCategories();
    ref.read(paymentMethodProvider.notifier).loadMethodPayment();
  }

  @override
  Widget build(BuildContext context) {
    final transactionTypes = ref.watch(transactionTypeProvider);
    final filteredTransactionTypes = _filterTransactionTypes(transactionTypes);

    return Scaffold(
      key: _scaffoldKey,
      drawer: NavigationDrawerCustom(
        onItemSelected: (TransactionMovement movement) {
          setState(() {
            selectedMovement = movement;
            selectedTransactionType = null;
          });
          Navigator.of(context).pop();
        },
      ),
      appBar: AppBar(
        title: TransactionTypeSelector(
          selectedTransactionType: selectedTransactionType,
          transactionTypes: filteredTransactionTypes,
          onChanged: (TransactionType? newValue) {
            setState(() {
              selectedTransactionType = newValue;
            });
            ref
                .read(globalTransactionProvider.notifier)
                .updateTransactionType(newValue);
          },
        ),
        actions: [
          // Menú de tres puntos (overflow menu)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Actualizar') {
                _refresh();
              } else {
                _clearTicket();
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
                const PopupMenuItem<String>(
                  value: 'Eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 10),
                      Text('Limpiar Ticket'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: selectedTransactionType == null
          ? const TransactionTypeSelectionWidget()
          : const Column(
              children: [
                SelectPaymentMethodButton(),
                Expanded(
                  child: SelectArticleWidget(),
                ),
              ],
            ),
    );
  }
}
