import 'package:app_pos/pages/navigation_drawer.dart';
import 'package:app_pos/widgets/card_order.dart';
import 'package:flutter/material.dart';

class ReceiptsScreen extends StatelessWidget {
  static String path = '/receipts_screen';
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> salesData = [
      {
        'date': 'Sunday, February 25, 2024',
        'products': ['Producto 1', 'Producto 2', 'Producto 3', 'Producto 4']
      },
      {
        'date': 'Thursday, February 15, 2024',
        'products': [
          'Producto 1',
          'Producto 2',
          'Producto 2',
          'Producto 2',
          'Producto 2',
          'Producto 2',
          'Producto 2',
          'Producto 2',
          'Producto 2',
          'Producto 2',
          'Producto 2'
        ]
      },
    ];
    return Scaffold(
      appBar: AppBar(),
      drawer: const NavigationDrawerCustom(
        selectedKey: DrawerSelectedItem.receipts,
      ),
      body: ListView.builder(
          itemCount: salesData.length * 2,
          itemBuilder: (BuildContext context, index) {
            if (index.isOdd) {
              return const Divider();
            }

            int salesIndex = index ~/ 2;
            print(salesIndex);
            String date = salesData[salesIndex]['date'];
            List<String> products = salesData[salesIndex]['products'];
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  for (String product in products) CardOrder(),
                ],
              ),
            );
          }),
    );
  }
}
