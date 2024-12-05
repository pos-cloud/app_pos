import 'package:flutter/material.dart';

class TransactionTypeSelectionWidget extends StatelessWidget {
  const TransactionTypeSelectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              const SizedBox(height: 10),
              Icon(
                Icons.arrow_upward,
                size: 50,
                color: Colors.grey.shade800,
              ),
              const SizedBox(height: 10),
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
    );
  }
}
