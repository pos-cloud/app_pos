import 'package:flutter/material.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            // height: double.infinity - 100,
            child: ListView(
              children: [
                ContainerItem(nombre: 'Producto 1', cantidad: 2, total: 20.0),
                ContainerItem(nombre: 'Producto 1', cantidad: 2, total: 20.0),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: () {},
              child: Center(
                child: Text('Pagar'),
              ))
        ],
      ),
    );
  }
}

class ContainerItem extends StatelessWidget {
  final String nombre;
  final int cantidad;
  final double total;

  const ContainerItem({
    required this.nombre,
    required this.cantidad,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      // decoration: BoxDecoration(
      //   border: Border(bottom: BorderSide(color: Colors.grey)),
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Laptop',
                style: TextStyle(fontSize: 16),
              ),
              Text(' x 120')
            ],
          ),
          Text(
            '\$323',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
