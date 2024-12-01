import 'package:app_pos/constant.dart';
import 'package:flutter/material.dart';

class Article extends StatefulWidget {
  const Article({super.key});

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                height: 85,
                width: 85,
                decoration: BoxDecoration(
                    color: contentColor,
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(10),
                child: Image.network(
                    'https://raw.githubusercontent.com/uranus-code/shop_app/master/assets/shoes.jpg'),
              ),
              const SizedBox(
                width: 10,
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zapatillas addidas xr',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    'zapatillas',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )
            ],
          ),
        ),
        const Positioned(
          top: 50,
          right: 20,
          child: Center(
            child: Text(
              '\$332',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        )
      ],
    );
  }
}
