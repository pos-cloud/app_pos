import 'package:app_pos/screens/tickets_screen.dart';
import 'package:flutter/material.dart';

class DisplayItems extends StatelessWidget {
  const DisplayItems({super.key, required this.numItems});
  final int numItems;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TicketScreen()));
      },
      child: SizedBox(
        height: 37,
        width: 40,
        child: Stack(
          children: [
            const Positioned(top: 14, child: Icon(Icons.point_of_sale_sharp)),
            Positioned(
              right: 5,
              child: Center(
                child: Text(
                  numItems.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
