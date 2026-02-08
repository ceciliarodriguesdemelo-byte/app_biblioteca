import 'package:flutter/material.dart';
import '../models/livro.dart';
import '../services/database_service.dart';

class LivroFormScreen extends StatefulWidget {
  final Livro? livro; // Se for nulo, estamos criando um novo

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
    // Se estiver editando, preenche os campos com os dados atuais
    if (widget.livro != null) {
      _tituloController.text = widget.livro!.titulo;
      _autorController.text = widget.livro!.autor;
      _anoController.text = widget.livro!.ano.toString();
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novoLivro = Livro(
        id: widget.livro?.id ?? '', // Se for novo, ID vazio (Firebase gera)
        titulo: _tituloController.text,
        autor: _autorController.text,
        ano: int.parse(_anoController.text),
      );

      if (widget.livro == null) {
        await _dbService.addLivro(novoLivro);
      } else {
        await _dbService.updateLivro(novoLivro);
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
                validator: (v) => v!.isEmpty ? 'Informe o título' : null,
              ),
              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (v) => v!.isEmpty ? 'Informe o autor' : null,
              ),
              TextFormField(
                controller: _anoController,
                decoration: const InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Informe o ano' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}