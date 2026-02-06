import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/global_transaction_provider.dart';
import 'package:app_pos/screens/movement_of_articles_screen.dart';

class AnimatedArticleCounter extends ConsumerStatefulWidget {
  const AnimatedArticleCounter({Key? key}) : super(key: key);

  @override
  ConsumerState<AnimatedArticleCounter> createState() =>
      _AnimatedArticleCounterState();
}

class _AnimatedArticleCounterState extends ConsumerState<AnimatedArticleCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateIfChanged(int newCount) {
    if (newCount > _previousCount) {
      _controller.forward(from: 0.0);
    }
    _previousCount = newCount;
  }

  @override
  Widget build(BuildContext context) {
    final movementsOfArticles =
        ref.watch(globalTransactionProvider).movementsOfArticles;

    // Animar cuando cambia el contador
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateIfChanged(movementsOfArticles.length);
    });

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MovementOfArticlesScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.black, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long, size: 14, color: Colors.black),
                  const SizedBox(width: 3),
                  Text(
                    movementsOfArticles.length.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
