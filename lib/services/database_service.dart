import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/livro.dart';

class DatabaseService {
  final CollectionReference _livrosCollection = 
      FirebaseFirestore.instance.collection('livros');

  // CREATE
  Future<void> addLivro(Livro livro) async {
    try {
      await _livrosCollection.add(livro.toMap());
    } catch (e) {
      // Repassa o erro para a UI tratar
      rethrow; 
    }
  }

  // READ
  Stream<List<Livro>> getLivros() {
    return _livrosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Livro.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // UPDATE
  Future<void> updateLivro(Livro livro) async {
    try {
      await _livrosCollection.doc(livro.id).update(livro.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // DELETE
  Future<void> deleteLivro(String id) async {
    try {
      await _livrosCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}