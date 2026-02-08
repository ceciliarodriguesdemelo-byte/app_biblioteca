import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  void login() async {
  try {
    //autentica no Firebase
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: senhaController.text.trim(),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );

  } catch (e) {
  debugPrint("ERRO COMPLETO: $e");
  if (mounted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erro Técnico"),
        content: Text(e.toString()), //mostra código do erro 
      ),
    );
  }
  }
}
  void cadastrar() async {
  final email = emailController.text.trim();
  final senha = senhaController.text.trim();

  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    // Verificação de segurança
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usuário cadastrado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    String mensagem = 'Erro ao cadastrar';
    if (e.code == 'weak-password') {
      mensagem = 'A senha é muito fraca.';
    } else if (e.code == 'email-already-in-use') {
      mensagem = 'Este e-mail já está em uso.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: senhaController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text('Entrar'),
            ),
            TextButton(
              onPressed: cadastrar,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
