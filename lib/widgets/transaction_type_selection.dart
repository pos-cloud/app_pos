import 'package:flutter/material.dart';

class TransactionTypeSelectionWidget extends StatelessWidget {
  const TransactionTypeSelectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png', // Asegúrate de poner la ruta correcta de tu logo
            width: 250, // Tamaño ajustable del logo
            height: 250, // Tamaño ajustable del logo
          ),
        ],
      ),
    );
  }
}
