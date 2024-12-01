import 'package:app_pos/widgets/custom_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KeyboardScreen extends StatelessWidget {
  static String path = '/keyboard_screen';
  const KeyboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.pop(1);
        },
      )),
      body: const CustomKeyboard(),
    );
  }
}
