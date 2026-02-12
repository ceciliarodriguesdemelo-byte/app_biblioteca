import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/livro.dart';
import '../services/database_service.dart';
import '../screens/livro_form_screen.dart';

// --- TELA PRINCIPAL ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Livro>>(
        stream: dbService.getLivros(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum livro cadastrado.'));
          }

          final livros = snapshot.data!;

          return ListView.builder(
            itemCount: livros.length,
            itemBuilder: (context, index) {
              final livro = livros[index];
              return ListTile(
                leading: const Icon(Icons.book, color: Colors.blue),
                title: Text(livro.titulo),
                subtitle: Text('${livro.autor} (${livro.ano})'),
                onTap: () {
                  // Abre a tela de edição ao clicar no livro
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LivroFormScreen(livro: livro),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => dbService.deleteLivro(livro.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Abre a tela de cadastro (sem passar livro)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LivroFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
