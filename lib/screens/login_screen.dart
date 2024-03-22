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
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              Container(
                child: Image.network(
                  'https://media.licdn.com/dms/image/C4E0BAQFD462Hv9r2vg/company-logo_200_200/0/1630575315482?e=1717027200&v=beta&t=kGp1P603iskkGc_4a4UrDwKfV-jI2AG3Wh8kjIlgaVc',
                  height: 130,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 45,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Negocio",
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 45,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Usuario o Email",
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 45,
                child: TextField(
                  obscureText: isVisiblePassword,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisiblePassword = !this.isVisiblePassword;
                          });
                        },
                        icon: isVisiblePassword
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility)),
                    border: OutlineInputBorder(),
                    labelText: "Password",
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(colorPrincipal),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      GoRouter.of(context).go(MainScreen.path);
                    });
                  },
                  child: Text(
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
