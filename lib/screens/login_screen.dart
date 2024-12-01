import 'package:app_pos/constant.dart';
import 'package:app_pos/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  static String path = '/login_screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isVisiblePassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 500,
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 130,
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 45,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Negocio",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 45,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Usuario o Email",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 45,
                child: TextField(
                  obscureText: isVisiblePassword,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisiblePassword = !isVisiblePassword;
                          });
                        },
                        icon: isVisiblePassword
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility)),
                    border: const OutlineInputBorder(),
                    labelText: "Password",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        const MaterialStatePropertyAll<Color>(colorPrincipal),
                    shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      GoRouter.of(context).go(MainScreen.path);
                    });
                  },
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
