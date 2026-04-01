// lib/screens/inicio_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/controle_fonte_biblia.dart';
import '../main.dart';
import '../models/favorito_model.dart';
import '../services/bible_service.dart';
import '../services/devocional_service.dart';
import '../services/favoritos_service.dart';
import '../models/bible_model.dart';
import 'capitulos_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {

  final BibleService bibleService = BibleService();
  final DevocionalService devocionalService = DevocionalService();
  final FavoritosService favoritosService = FavoritosService();

  Map<String, dynamic>? devocional;
  bool carregando = true;

  List<Favorito> favoritos = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  /// 🔥 carrega devocional + favoritos
  Future<void> carregarDados() async {

    setState(() {
      carregando = true;
    });

    final bible = await bibleService.loadBible();
    final d = devocionalService.getDevocional(bible);
    final fav = await favoritosService.getFavoritos();

    if (!mounted) return;

    setState(() {
      devocional = d;
      favoritos = fav;
      carregando = false;
    });
  }

  /// 🔥 verifica se já está favoritado
  bool isFavorito() {
    return favoritos.any((f) =>
        f.livro == devocional!["livro"] &&
        f.capitulo == devocional!["capitulo"] &&
        f.versiculo == devocional!["versiculo"]);
  }

  /// 🔥 favoritar versículo do dia
  Future<void> favoritarVersiculo() async {

    final favorito = Favorito(
      livro: devocional!["livro"],
      capitulo: devocional!["capitulo"],
      versiculo: devocional!["versiculo"],
      texto: devocional!["texto"],
    );

    if (!isFavorito()) {
      await favoritosService.adicionarFavorito(favorito);
    } else {
      await favoritosService.removerFavorito(favorito);
    }

    await carregarDados();
  }

  /// 🔥 compartilhar versículo
  void compartilharVersiculo() {

    final texto =
        "${devocional!["livro"]} ${devocional!["capitulo"]}:${devocional!["versiculo"]}\n\n${devocional!["texto"]}";

    Share.share(texto);
  }

  /// 🔥 abrir capítulo já no versículo
  Future<void> abrirVersiculo() async {

    final bible = await bibleService.loadBible();

    final Book book = bible.books.firstWhere(
      (b) => b.name == devocional!["livro"],
      orElse: () => bible.books.first,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CapitulosScreen(
          book: book,
          initialChapter: devocional!["capitulo"],
          highlightVerse: devocional!["versiculo"],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(

        centerTitle: true,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.menu_book),
            SizedBox(width: 8),
            Text("Minha Bíblia"),
          ],
        ),

        actions: [

          /// 🌙 botão de tema
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              BibliaApp.of(context)?.alternarTema();
            },
          )

        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// 🔥 DEVOCIONAL INTERATIVO
            Material(
              color: Colors.deepPurple.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),

              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: abrirVersiculo, // 🔥 abre o versículo

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          const Text(
                            "Devocional do Dia",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          Row(
                            children: [

                              /// ❤️ FAVORITAR
                              IconButton(
                                icon: Icon(
                                  isFavorito()
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: favoritarVersiculo,
                              ),

                              /// 📤 COMPARTILHAR
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: compartilharVersiculo,
                              ),
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "${devocional!["livro"]} ${devocional!["capitulo"]}:${devocional!["versiculo"]}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🔥 texto com fonte global
                      ValueListenableBuilder<double>(
                        valueListenable: ControleFonteBiblia.tamanhoFonte,
                        builder: (context, fonte, _) {
                          return Text(
                            devocional!["texto"],
                            style: TextStyle(
                              fontSize: fonte,
                              height: 1.5,
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 🔥 EXPLORAR
            const Text(
              "Explorar",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// 🔥 GRID DE AÇÕES
            GridView.count(

              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              children: [

                _botaoMenu(
                  icon: Icons.menu_book,
                  titulo: "Ler Bíblia",
                  cor: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, "/livros");
                  },
                ),

                _botaoMenu(
                  icon: Icons.favorite,
                  titulo: "Favoritos",
                  cor: Colors.red,
                  onTap: () {
                    Navigator.pushNamed(context, "/favoritos");
                  },
                ),

                _botaoMenu(
                  icon: Icons.calendar_month,
                  titulo: "Plano",
                  cor: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, "/plano");
                  },
                ),

                _botaoMenu(
                  icon: Icons.note_alt,
                  titulo: "Anotações",
                  cor: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, "/anotacoes");
                  },
                ),

                _botaoMenu(
                  icon: Icons.swap_horiz,
                  titulo: "Versão",
                  cor: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, "/versao");
                  },
                ),

                _botaoMenu(
                  icon: Icons.search,
                  titulo: "Pesquisar",
                  cor: const Color.fromARGB(255, 37, 24, 220),
                  onTap: () {
                    Navigator.pushNamed(context, "/pesquisa");
                  },
                ),

              ],
            )

          ],
        ),
      ),
    );
  }

  /// 🔥 botão padrão do menu inicial
  Widget _botaoMenu({
    required IconData icon,
    required String titulo,
    required Color cor,
    required VoidCallback onTap,
  }) {

    return Material(
      color: cor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),

      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white),
              ),

              const SizedBox(height: 10),

              Text(
                titulo,
                style: TextStyle(
                  fontSize: 14,
                  color: cor,
                  fontWeight: FontWeight.w600,
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}