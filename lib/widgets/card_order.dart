import 'package:flutter/material.dart';

class CardOrder extends StatelessWidget {
  const CardOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.money),
              SizedBox(
                width: 20,
              ),
              Column(
                children: [
                  Text("\$32323"),
                  Text(
                    '9:39 AM',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ],
          ),
          Divider(),
          Text("#1-23232")
        ],
      ),
    );
  }
}
