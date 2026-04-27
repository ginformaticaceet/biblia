// lib/screens/pesquisa_screen.dart

import 'package:flutter/material.dart';
import '../controllers/bible_controller.dart';
import '../models/bible_model.dart';
import '../services/bible_service.dart';
import '../widgets/botao_versao.dart';
import 'capitulos_screen.dart';

/// Tela de pesquisa por livro ou por conteúdo dos versículos.
class PesquisaScreen extends StatefulWidget {
  const PesquisaScreen({super.key});

  @override
  State<PesquisaScreen> createState() => _PesquisaScreenState();
}

class _PesquisaScreenState extends State<PesquisaScreen> {
  final BibleService bibleService = BibleService();
  final TextEditingController controller = TextEditingController();

  Bible? bible;
  List<Map<String, dynamic>> resultados = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();

    // 🔥 carrega a Bíblia ao abrir a tela
    carregarBiblia();

    // 🔥 atualiza a busca quando trocar a versão
    BibleController.versao.addListener(_onVersaoAlterada);
  }

  @override
  void dispose() {
    // 🔥 remove o listener para evitar vazamento
    BibleController.versao.removeListener(_onVersaoAlterada);
    controller.dispose();
    super.dispose();
  }

  /// 🔥 quando a versão muda, recarrega tudo
  void _onVersaoAlterada() {
    if (!mounted) return;
    carregarBiblia();
  }

  /// 🔥 carrega a Bíblia atual
  Future<void> carregarBiblia() async {
    setState(() {
      carregando = true;
    });

    final b = await bibleService.loadBible();

    if (!mounted) return;

    setState(() {
      bible = b;
      resultados = [];
      carregando = false;
    });
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

  /// 🔎 pesquisa livros e versículos em tempo real
  void pesquisar(String palavra) {
    if (bible == null) return;

    final termo = _normalizarTexto(palavra);

    // 🔥 se o campo estiver vazio, limpa os resultados
    if (termo.isEmpty) {
      setState(() {
        resultados = [];
      });
      return;
    }

    final List<Map<String, dynamic>> encontrados = [];

    // 🔎 pesquisa por nome do livro
    for (final book in bible!.books) {
      if (_normalizarTexto(book.name).contains(termo)) {
        encontrados.add({
          "tipo": "livro",
          "book": book,
          "livro": book.name,
        });
      }
    }

    // 🔎 pesquisa por conteúdo dos versículos
    for (final book in bible!.books) {
      for (int c = 0; c < book.chapters.length; c++) {
        for (int v = 0; v < book.chapters[c].length; v++) {
          final versiculo = book.chapters[c][v];

          if (_normalizarTexto(versiculo).contains(termo)) {
            encontrados.add({
              "tipo": "versiculo",
              "book": book,
              "livro": book.name,
              "capitulo": c + 1,
              "versiculo": v + 1,
              "texto": versiculo,
            });
          }
        }
      }
    }

    setState(() {
      resultados = encontrados;
    });
  }

  /// 🔥 identifica se o livro pertence ao Antigo Testamento
  bool _ehAntigoTestamento(String livro) {
    const antigos = [
      "Gênesis",
      "Êxodo",
      "Levítico",
      "Números",
      "Deuteronômio",
      "Josué",
      "Juízes",
      "Rute",
      "1 Samuel",
      "2 Samuel",
      "1 Reis",
      "2 Reis",
      "1 Crônicas",
      "2 Crônicas",
      "Esdras",
      "Neemias",
      "Ester",
      "Jó",
      "Salmos",
      "Provérbios",
      "Eclesiastes",
      "Cânticos",
      "Isaías",
      "Jeremias",
      "Lamentações",
      "Ezequiel",
      "Daniel",
      "Oséias",
      "Joel",
      "Amós",
      "Obadias",
      "Jonas",
      "Miquéias",
      "Naum",
      "Habacuque",
      "Sofonias",
      "Ageu",
      "Zacarias",
      "Malaquias",
    ];

    return antigos.contains(livro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.search),
            SizedBox(width: 8),
            Text("Pesquisar Bíblia"),
          ],
        ),

        // 🔥 botão de versão para manter o padrão do app
        actions: [
          BotaoVersao(
            onTap: () {
              Navigator.pushNamed(context, "/versao");
            },
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Digite palavra ou livro...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          pesquisar(controller.text);
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    // 🔥 pesquisa enquanto digita
                    onChanged: pesquisar,
                    onSubmitted: pesquisar,
                  ),
                ),
                Expanded(
                  child: resultados.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhum resultado",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: resultados.length,
                          itemBuilder: (context, index) {
                            final r = resultados[index];
                            final String livro = r["livro"];
                            final bool antigoTestamento =
                                _ehAntigoTestamento(livro);

                            // 📚 resultado é LIVRO
                            if (r["tipo"] == "livro") {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Material(
                                  color: (antigoTestamento
                                          ? Colors.brown
                                          : Colors.blue)
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CapitulosScreen(
                                            book: r["book"],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: antigoTestamento
                                                  ? Colors.brown
                                                  : Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.menu_book,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              r["livro"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            // 📖 resultado é VERSÍCULO
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Material(
                                color: (antigoTestamento
                                        ? Colors.brown
                                        : Colors.blue)
                                    .withOpacity(0.06),
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CapitulosScreen(
                                          book: r["book"],
                                          initialChapter: r["capitulo"],
                                          highlightVerse: r["versiculo"],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${r["livro"]} ${r["capitulo"]}:${r["versiculo"]}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          r["texto"],
                                          style: const TextStyle(
                                            height: 1.5,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}