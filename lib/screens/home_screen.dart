import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/livro.dart';
import '../services/database_service.dart';

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
            return const Center(child: Text('Erro ao carregar dados.'));
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

// --- TELA DE FORMULÁRIO (CADASTRO E EDIÇÃO) ---
class LivroFormScreen extends StatefulWidget {
  final Livro? livro; 
  const LivroFormScreen({super.key, this.livro});

  @override
  State<LivroFormScreen> createState() => _LivroFormScreenState();
}

class _LivroFormScreenState extends State<LivroFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _anoController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.livro != null) {
      _tituloController.text = widget.livro!.titulo;
      _autorController.text = widget.livro!.autor;
      _anoController.text = widget.livro!.ano.toString();
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final livroData = Livro(
        id: widget.livro?.id ?? '', 
        titulo: _tituloController.text,
        autor: _autorController.text,
        ano: int.tryParse(_anoController.text) ?? 2024,
      );

      if (widget.livro == null) {
        await _dbService.addLivro(livroData);
      } else {
        await _dbService.updateLivro(livroData);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.livro == null ? 'Novo Livro' : 'Editar Livro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _anoController,
                decoration: const InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}