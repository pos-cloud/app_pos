import 'package:app_pos/widgets/article.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: double.infinity,
            height: 100,
            color: Colors.blue[500],
            child: const Center(
              child: Text(
                '\$5439059430',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              label: const Text(
                'Search',
              ),
              suffixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) => GestureDetector(
                child: const Article(),
                onTap: () {
                  context.go('/keyboard_screen');
                }),
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemCount: [1, 2, 3, 4, 5, 6, 7, 8].length,
          ),
        ),
      ]),
    );
  }
}
