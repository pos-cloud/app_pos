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
      ref.read(globalTransactionProvider.notifier).resetTransaction();
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

  @override
  Widget build(BuildContext context) {
    final transactionTypes = ref.watch(transactionTypeProvider);
    final filteredTransactionTypes = _filterTransactionTypes(transactionTypes);

    return Scaffold(
      key: _scaffoldKey, // Asociar la clave al Scaffold
      drawer: NavigationDrawerCustom(
        onItemSelected: (TransactionMovement movement) {
          setState(() {
            selectedMovement = movement;
            selectedTransactionType =
                null; // Resetear la selección del dropdown
          });
          Navigator.of(context).pop(); // Cierra el Drawer.
        },
      ),
      appBar: AppBar(
        title: DropdownButton<TransactionType>(
          hint: const Text("Seleccione una transacción"),
          value: selectedTransactionType,
          onChanged: (TransactionType? newValue) {
            setState(() {
              selectedTransactionType = newValue;
            });
            ref.read(globalTransactionProvider.notifier).setRandomTotalPrice();
          },
          items:
              filteredTransactionTypes.map<DropdownMenuItem<TransactionType>>(
            (TransactionType transactionType) {
              return DropdownMenuItem<TransactionType>(
                value: transactionType,
                child: Text(transactionType.name),
              );
            },
          ).toList(),
        ),
      ),
      body: selectedTransactionType == null
          ? Stack(
              children: [
                // Fondo blanco
                Container(
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                // Flechas grandes y animadas (colocadas en la parte superior de la pantalla)
                Positioned(
                  top: 30, // Empuja hacia la parte superior
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Leyenda
                      // Text(
                      //   "Seleccione aquí",
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     color: Colors.grey.shade600,
                      //     fontStyle: FontStyle.italic,
                      //   ),
                      // ),
                      const SizedBox(height: 10),
                      // Flecha grande que apunta hacia el dropdown
                      Icon(
                        Icons.arrow_upward,
                        size: 50,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(height: 10),
                      // Flechas laterales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            size: 30,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 20),
                          Icon(
                            Icons.arrow_upward,
                            size: 30,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                "Total: \$${ref.watch(globalTransactionProvider).transaction['totalPrice'].toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}

class CurvedArrowsPainter extends CustomPainter {
  final double dropdownYPosition;

  CurvedArrowsPainter({required this.dropdownYPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final Path path1 = Path();
    path1.moveTo(size.width * 0.25, size.height); // Punto de inicio
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.7, // Punto de control 1
      size.width * 0.5,
      dropdownYPosition, // Punto final
    );

    final Path path2 = Path();
    path2.moveTo(size.width * 0.75, size.height); // Punto de inicio
    path2.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.7, // Punto de control 2
      size.width * 0.5,
      dropdownYPosition, // Punto final
    );

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    // Opcional: agregar flechas al final
    final arrowPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width * 0.5, dropdownYPosition), 8, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
