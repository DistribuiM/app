import 'package:flutter/material.dart';
import '../../core/widgets/elevated_button.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomElevatedButton(
              onPressed: () async {
                try {
                  await AuthService().signInWithGoogle();
                } catch (erro) {
                  // Se der erro (Email não registrado)
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Este email não está registrado.",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Color.fromARGB(255, 255, 113, 103), // Fundo vermelho para indicar erro
                        duration: Duration(seconds: 4), // Fica na tela por 4 segundos
                      ),
                    );
                  }
                }
              }),
          ],
        ),
      ),
    );
  }
}
