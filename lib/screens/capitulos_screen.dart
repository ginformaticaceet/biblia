// lib/screens/capitulos_screen.dart

import 'package:flutter/material.dart';
import '../services/bible_service.dart';
import '../models/bible_model.dart';
import '../controllers/bible_controller.dart';
import '../widgets/botao_versao.dart';
import 'versiculos_screen.dart';

class CapitulosScreen extends StatefulWidget {

  final Book book;
  final int? initialChapter;
  final int? highlightVerse;

  const CapitulosScreen({
    super.key,
    required this.book,
    this.initialChapter,
    this.highlightVerse,
  });

  @override
  State<CapitulosScreen> createState() => _CapitulosScreenState();
}

class _CapitulosScreenState extends State<CapitulosScreen> {

  final BibleService service = BibleService();

  Bible? bible;

  bool abriuAutomatico = false;

  @override
  void initState() {
    super.initState();

    carregar();

    // 🔥 escuta troca de versão
    BibleController.versao.addListener(carregar);
  }

  @override
  void dispose() {
    BibleController.versao.removeListener(carregar);
    super.dispose();
  }

  /// 🔥 carrega Bíblia
  void carregar() async {

    final b = await service.loadBible();

    if (!mounted) return;

    setState(() {
      bible = b;
      abriuAutomatico = false;
    });
  }

  /// 🔥 abre capítulo automaticamente (vindo da pesquisa)
  void abrirAutomatico(Book book) {

    if (abriuAutomatico) return;
    if (widget.initialChapter == null) return;

    abriuAutomatico = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VersiculosScreen(
            chapter: book.chapters[widget.initialChapter! - 1],
            chapterNumber: widget.initialChapter!,
            bookName: book.name,
            highlightVerse: widget.highlightVerse,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    if (bible == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final book = bible!.books.firstWhere(
      (b) => b.name == widget.book.name,
      orElse: () => bible!.books[0],
    );

    abrirAutomatico(book);

    return Scaffold(

      appBar: AppBar(
        title: Text(book.name),

        actions: [
          BotaoVersao(
            onTap: () {
              Navigator.pushNamed(context, "/versao");
            },
          ),
        ],
      ),

      body: ListView.builder(

        padding: const EdgeInsets.all(12),

        itemCount: book.chapters.length,

        itemBuilder: (context, index) {

          final capitulo = index + 1;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),

            /// 🔥 CARD PADRÃO
            child: Material(

              color: Colors.brown.withOpacity(0.1),

              borderRadius: BorderRadius.circular(8), // ✅ PADRÃO

              child: InkWell(

                borderRadius: BorderRadius.circular(8),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VersiculosScreen(
                        chapter: book.chapters[index],
                        chapterNumber: capitulo,
                        bookName: book.name,
                      ),
                    ),
                  );
                },

                child: ListTile(

                  /// 🔢 NÚMERO DO CAPÍTULO (PADRÃO)
                  leading: Container(

                    width: 36,
                    height: 36,

                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Text(
                      "$capitulo",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  /// 📖 TÍTULO
                  title: Text(
                    "Capítulo $capitulo",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  /// ➡️ SETA
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}