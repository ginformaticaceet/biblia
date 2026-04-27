// lib/screens/livros_screen.dart

import 'package:flutter/material.dart';
import '../services/bible_service.dart';
import '../models/bible_model.dart';
import '../controllers/bible_controller.dart';
import '../widgets/botao_versao.dart';
import 'capitulos_screen.dart';

class LivrosScreen extends StatefulWidget {
  const LivrosScreen({super.key});

  @override
  State<LivrosScreen> createState() => _LivrosScreenState();
}

class _LivrosScreenState extends State<LivrosScreen> {
  late Future<Bible> bibleFuture;

  String busca = "";

  @override
  void initState() {
    super.initState();
    carregar();

    // 🔥 escuta mudança de versão
    BibleController.versao.addListener(_onVersaoAlterada);
  }

  @override
  void dispose() {
    // 🔥 remove o listener quando sair da tela
    BibleController.versao.removeListener(_onVersaoAlterada);
    super.dispose();
  }

  /// 🔥 quando a versão muda, recarrega os livros
  void _onVersaoAlterada() {
    if (!mounted) return;

    setState(() {
      carregar();
    });
  }

  /// 🔥 carrega a Bíblia atual
  void carregar() {
    bibleFuture = BibleService().loadBible();
  }

  /// 🔥 normaliza texto para pesquisar sem acentos e sem diferença entre maiúsculas/minúsculas
  String _normalizarTexto(String texto) {
    return texto
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Livros da Bíblia"),
        actions: [
          BotaoVersao(
            onTap: () {
              Navigator.pushNamed(context, "/versao");
            },
          ),
        ],
      ),
      body: FutureBuilder<Bible>(
        future: bibleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Nenhum dado encontrado"));
          }

          final books = snapshot.data!.books;

          // 🔥 separa por Antigo e Novo Testamento
          final antigo = books.take(39).toList();
          final novo = books.skip(39).toList();

          // 🔥 normaliza a busca para aceitar sem acento
          final termoBusca = _normalizarTexto(busca);

          final antigoFiltrado = antigo.where((b) {
            return _normalizarTexto(b.name).contains(termoBusca);
          }).toList();

          final novoFiltrado = novo.where((b) {
            return _normalizarTexto(b.name).contains(termoBusca);
          }).toList();

          return Column(
            children: [
              /// 🔍 CAMPO DE BUSCA PADRONIZADO
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Buscar livro...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // ✅ PADRÃO
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    // 🔥 pesquisa em tempo real
                    setState(() => busca = value);
                  },
                ),
              ),

              Expanded(
                child: ListView(
                  children: [
                    /// 📜 ANTIGO TESTAMENTO
                    secaoTitulo("Antigo Testamento", Colors.brown),
                    ...antigoFiltrado.map((b) => livroCard(b, Colors.brown)),

                    /// 📖 NOVO TESTAMENTO
                    secaoTitulo("Novo Testamento", Colors.blue),
                    ...novoFiltrado.map((b) => livroCard(b, Colors.blue)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🔥 título de seção padronizado
  Widget secaoTitulo(String titulo, Color cor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        titulo,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: cor,
          fontSize: 16,
        ),
      ),
    );
  }

  /// 🔥 card padrão da lista de livros
  Widget livroCard(Book book, Color cor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8), // ✅ PADRÃO
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CapitulosScreen(book: book),
              ),
            );
          },
          child: ListTile(
            /// 📘 ícone padrão
            leading: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu_book,
                color: Colors.white,
              ),
            ),

            /// 📖 nome do livro
            title: Text(
              book.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            /// ➡️ seta padrão
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ),
      ),
    );
  }
}