import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_pos/providers/auth_provider.dart';
import 'package:app_pos/screens/main_screen.dart';
import 'package:app_pos/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String path = '/login_screen';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isVisiblePassword = true;
  final TextEditingController negocioController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadSavedBusiness();
  }

  Future<void> _loadSavedBusiness() async {
    final savedBusiness = await _authService.getBusiness();
    if (savedBusiness != null && savedBusiness.isNotEmpty && mounted) {
      setState(() {
        negocioController.text = savedBusiness;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 130,
              ),
              const SizedBox(height: 50),
              TextField(
                controller: negocioController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Negocio",
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usuarioController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Usuario",
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
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
                        : const Icon(Icons.visibility),
                  ),
                  border: const OutlineInputBorder(),
                  labelText: "Password",
                ),
              ),
              const SizedBox(height: 30),
              // Botón para iniciar sesión
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        const MaterialStatePropertyAll<Color>(Colors.blue),
                    shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final result = await ref.read(authProvider.notifier).login(
                          negocioController.text,
                          usuarioController.text,
                          passwordController.text,
                        );

                    if (result.success) {
                      await _authService.saveBusiness(negocioController.text);
                      await ref
                          .read(authUserProvider.notifier)
                          .loadFromStorage();

                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, MainScreen.path);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                result.errorMessage ?? 'Error al iniciar sesión')),
                      );
                    }
                  },
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
