// lib/services/devocional_service.dart

import '../models/bible_model.dart';

class DevocionalService {

  /// 🔥 Gera um devocional baseado no dia atual
  Map<String, dynamic> getDevocional(Bible bible) {

    final now = DateTime.now();

    // 🔥 calcula o dia do ano (0 - 364)
    final dayOfYear =
        now.difference(DateTime(now.year, 1, 1)).inDays;

    // 🔥 proteção contra lista vazia
    if (bible.books.isEmpty) {
      throw Exception("Bíblia sem livros");
    }

    // 🔥 seleciona livro baseado no dia
    final bookIndex = dayOfYear % bible.books.length;
    final book = bible.books[bookIndex];

    // 🔥 proteção
    if (book.chapters.isEmpty) {
      throw Exception("Livro sem capítulos");
    }

    // 🔥 seleciona capítulo
    final chapterIndex =
        dayOfYear % book.chapters.length;

    final chapter = book.chapters[chapterIndex];

    // 🔥 proteção
    if (chapter.isEmpty) {
      throw Exception("Capítulo vazio");
    }

    // 🔥 seleciona versículo
    final verseIndex =
        dayOfYear % chapter.length;

    final verse = chapter[verseIndex];

    // 🔥 retorna devocional
    return {
      "livro": book.name,
      "capitulo": chapterIndex + 1,
      "versiculo": verseIndex + 1,
      "texto": verse
    };
  }
}