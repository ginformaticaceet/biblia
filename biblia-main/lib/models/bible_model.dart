// lib/models/bible_model.dart

import '../utils/nomes_livros.dart';

class Bible {

  // 🔥 lista de livros da Bíblia
  final List<Book> books;

  Bible({required this.books});

  /// 🔥 Converte JSON (lista) em objeto Bible
  factory Bible.fromJson(List<dynamic> json) {

    // 🔥 proteção contra lista inválida
    if (json.isEmpty) {
      throw Exception("JSON da Bíblia está vazio");
    }

    // 🔥 converte cada item em Book
    List<Book> books = json.map((book) {

      if (book is Map<String, dynamic>) {
        return Book.fromJson(book);
      } else {
        throw Exception("Formato inválido de livro");
      }

    }).toList();

    return Bible(books: books);
  }
}

class Book {

  // 🔥 nome completo do livro (Gênesis, Mateus, etc)
  final String name;

  // 🔥 capítulos → lista de capítulos → lista de versículos
  final List<List<String>> chapters;

  Book({
    required this.name,
    required this.chapters,
  });

  /// 🔥 Converte JSON em Book
  factory Book.fromJson(Map<String, dynamic> json) {

    // 🔥 pega capítulos (suporta múltiplos formatos)
    final List chaptersJson =
        json['chapters'] ?? json['capitulos'] ?? [];


    // 🔥 converte capítulos → versículos
    List<List<String>> chapters = chaptersJson.map<List<String>>((chapter) {

      if (chapter is! List) return [];

      return chapter.map<String>((verse) {

        // 🔥 caso padrão (String)
        if (verse is String) {
          return verse;
        }

        // 🔥 caso venha como objeto {text: "..."}
        else if (verse is Map) {
          return verse['text']?.toString() ?? "";
        }

        // 🔥 fallback
        else {
          return verse.toString();
        }

      }).toList();

    }).toList();

    // 🔥 pega abreviação do livro (vários formatos possíveis)
    final String abbrev = (
          json['abbrev'] ??
          json['name'] ??
          json['book'] ??
          json['title'] ??
          json['titulo'] ??
          'livro'
        )
        .toString()
        .toLowerCase();

    // 🔥 converte para nome completo usando seu map
    final String name = nomesLivros[abbrev] ?? abbrev;

    return Book(
      name: name,
      chapters: chapters,
    );
  }
}