class Livro {
  String id;
  String titulo;
  String autor;
  int ano;

  Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.ano,
  });

  // Converte Firestore -> App
  factory Livro.fromMap(Map<String, dynamic> data, String documentId) {
    return Livro(
      id: documentId,
      titulo: data['titulo'] ?? '',
      autor: data['autor'] ?? '',
      ano: data['ano'] ?? 0,
    );
  }

  // Converte App -> Firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'autor': autor,
      'ano': ano,
    };
  }
}