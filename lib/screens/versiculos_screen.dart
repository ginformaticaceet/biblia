// lib/screens/versiculos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/bible_controller.dart';
import '../controllers/controle_fonte_biblia.dart';
import '../models/anotacao_model.dart';
import '../models/favorito_model.dart';
import '../services/anotacao_service.dart';
import '../services/bible_service.dart';
import '../services/favoritos_service.dart';

class VersiculosScreen extends StatefulWidget {
  final List<String> chapter;
  final int chapterNumber;
  final String bookName;
  final int? highlightVerse;

  const VersiculosScreen({
    super.key,
    required this.chapter,
    required this.chapterNumber,
    required this.bookName,
    this.highlightVerse,
  });

  @override
  State<VersiculosScreen> createState() => _VersiculosScreenState();
}

class _VersiculosScreenState extends State<VersiculosScreen> {
  final FavoritosService favoritosService = FavoritosService();
  final AnotacaoService anotacaoService = AnotacaoService();

  // 🔥 controlador de rolagem da tela
  final ScrollController _scrollController = ScrollController();

  // 🔥 chave de cada versículo para permitir ir direto até ele
  final Map<int, GlobalKey> verseKeys = {};

  List<Favorito> favoritos = [];
  List<Anotacao> anotacoes = [];

  Set<int> selectedVerses = {};
  List<String> chapterAtual = [];

  int? highlightedVerse;

  @override
  void initState() {
    super.initState();

    // 🔥 carrega o capítulo recebido inicialmente
    chapterAtual = List.from(widget.chapter);

    // 🔥 guarda o versículo destacado vindo da pesquisa
    highlightedVerse = widget.highlightVerse;

    // 🔥 carrega favoritos e anotações
    carregarDados();

    // 🔥 atualiza o capítulo quando a versão mudar
    BibleController.versao.addListener(reloadCapitulo);

    // 🔥 tenta ir direto para o versículo destacado depois da primeira renderização
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToVerse();
    });

    // 🔥 remove o destaque depois de alguns segundos
    if (widget.highlightVerse != null) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            highlightedVerse = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    // 🔥 remove o listener ao sair da tela
    BibleController.versao.removeListener(reloadCapitulo);

    // 🔥 libera o controlador de rolagem
    _scrollController.dispose();

    super.dispose();
  }

  /// 🔥 carrega favoritos e anotações do dispositivo
  Future<void> carregarDados() async {
    final fav = await favoritosService.getFavoritos();
    final anot = await anotacaoService.getAnotacoes();

    if (!mounted) return;

    setState(() {
      favoritos = fav;
      anotacoes = anot;
    });
  }

  /// 🔥 recarrega o capítulo conforme a versão atual
  Future<void> reloadCapitulo() async {
    final bible = await BibleService().loadBible();

    final book = bible.books.firstWhere(
      (b) => b.name == widget.bookName,
      orElse: () => bible.books.first,
    );

    if (!mounted) return;

    setState(() {
      chapterAtual = List.from(book.chapters[widget.chapterNumber - 1]);
    });

    // 🔥 recarrega favoritos e anotações para manter o estado visual correto
    await carregarDados();

    // 🔥 tenta posicionar de novo se veio da pesquisa
    if (widget.highlightVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse();
      });
    }
  }

  /// 🔥 verifica se o versículo está favoritado
  bool isFavorito(int v) {
    return favoritos.any((f) =>
        f.livro == widget.bookName &&
        f.capitulo == widget.chapterNumber &&
        f.versiculo == v);
  }

  /// 🔥 verifica se o versículo possui anotação
  bool temAnotacao(int v) {
    return anotacoes.any((a) =>
        a.livro == widget.bookName &&
        a.capitulo == widget.chapterNumber &&
        a.versiculo == v);
  }

  /// 🔥 pega a anotação do versículo
  Anotacao? getAnotacao(int v) {
    try {
      return anotacoes.firstWhere((a) =>
          a.livro == widget.bookName &&
          a.capitulo == widget.chapterNumber &&
          a.versiculo == v);
    } catch (_) {
      return null;
    }
  }

  /// 🔥 salva ou edita anotação em um ou vários versículos
  Future<void> anotarVersiculosSelecionados() async {
    if (selectedVerses.isEmpty) return;

    final listaSelecionados = _selecionadosOrdenados();
    final primeiro = listaSelecionados.first;
    final existente = getAnotacao(primeiro);

    // 🔥 se houver apenas 1 versículo, abre com o texto já preenchido
    // 🔥 se houver vários, abre em branco para aplicar a todos
    final controller = TextEditingController(
      text: listaSelecionados.length == 1 ? existente?.anotacao ?? "" : "",
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            listaSelecionados.length == 1
                ? (existente == null ? "Nova anotação" : "Editar anotação")
                : "Anotação para ${listaSelecionados.length} versículos",
          ),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Digite sua anotação...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final texto = controller.text.trim();

                if (texto.isEmpty) return;

                // 🔥 aplica a mesma anotação para todos os versículos selecionados
                for (final v in listaSelecionados) {
                  final anotacao = Anotacao(
                    livro: widget.bookName,
                    capitulo: widget.chapterNumber,
                    versiculo: v,
                    texto: chapterAtual[v - 1],
                    anotacao: texto,
                  );

                  await anotacaoService.salvarAnotacao(anotacao);
                }

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await carregarDados();

                setState(() {
                  selectedVerses.clear();
                });
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  /// 🔥 remove anotação de um único versículo
  Future<void> removerAnotacaoVersiculo(int versiculo) async {
    final anot = getAnotacao(versiculo);
    if (anot == null) return;

    await anotacaoService.removerAnotacao(anot);
    await carregarDados();
  }

  /// 🔥 remove anotação de um ou vários versículos selecionados
  Future<void> removerAnotacoesSelecionadas() async {
    if (selectedVerses.isEmpty) return;

    final listaSelecionados = _selecionadosOrdenados();

    for (final v in listaSelecionados) {
      final anot = getAnotacao(v);
      if (anot != null) {
        await anotacaoService.removerAnotacao(anot);
      }
    }

    await carregarDados();

    if (!mounted) return;

    setState(() {
      selectedVerses.clear();
    });
  }

  /// 🔥 mostra a anotação do versículo
  void verAnotacao(int v) {
    final anot = getAnotacao(v);
    if (anot == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("${anot.livro} ${anot.capitulo}:${anot.versiculo}"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Versículo",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ValueListenableBuilder<double>(
                  valueListenable: ControleFonteBiblia.tamanhoFonte,
                  builder: (context, fonte, _) {
                    return Text(
                      anot.texto,
                      style: TextStyle(
                        fontSize: fonte,
                        height: 1.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Anotação",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  anot.anotacao,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Fechar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // 🔥 remove a anotação daquele versículo específico
                await removerAnotacaoVersiculo(v);
              },
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  /// 🔥 seleciona ou desseleciona um versículo
  void toggleSelectVerse(int v) {
    setState(() {
      if (selectedVerses.contains(v)) {
        selectedVerses.remove(v);
      } else {
        selectedVerses.add(v);
      }
    });
  }

  /// 🔥 primeiro versículo selecionado
  int? _primeiroSelecionado() {
    if (selectedVerses.isEmpty) return null;

    final lista = selectedVerses.toList()..sort();
    return lista.first;
  }

  /// 🔥 lista dos selecionados em ordem
  List<int> _selecionadosOrdenados() {
    final lista = selectedVerses.toList()..sort();
    return lista;
  }

  /// 🔥 copia os versículos selecionados
  Future<void> copiarVersiculos() async {
    if (selectedVerses.isEmpty) return;

    final lista = _selecionadosOrdenados();

    final texto = lista
        .map(
          (v) =>
              "${widget.bookName} ${widget.chapterNumber}:$v ${chapterAtual[v - 1]}",
        )
        .join("\n\n");

    await Clipboard.setData(ClipboardData(text: texto));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Versículos copiados")),
    );
  }

  /// 🔥 compartilha os versículos selecionados
  void compartilharVersiculos() {
    if (selectedVerses.isEmpty) return;

    final lista = _selecionadosOrdenados();

    final texto = lista
        .map(
          (v) =>
              "${widget.bookName} ${widget.chapterNumber}:$v ${chapterAtual[v - 1]}",
        )
        .join("\n\n");

    Share.share(texto);
  }

  /// 🔥 favoritar um ou vários versículos selecionados
  Future<void> favoritarSelecionados() async {
    if (selectedVerses.isEmpty) return;

    final listaSelecionados = _selecionadosOrdenados();

    for (final v in listaSelecionados) {
      final favorito = Favorito(
        livro: widget.bookName,
        capitulo: widget.chapterNumber,
        versiculo: v,
        texto: chapterAtual[v - 1],
      );

      if (!isFavorito(v)) {
        await favoritosService.adicionarFavorito(favorito);
      }
    }

    await carregarDados();

    if (!mounted) return;

    setState(() {
      selectedVerses.clear();
    });
  }

  /// 🔥 remover favoritos de um ou vários versículos selecionados
  Future<void> removerFavoritosSelecionados() async {
    if (selectedVerses.isEmpty) return;

    final listaSelecionados = _selecionadosOrdenados();

    for (final v in listaSelecionados) {
      final favorito = Favorito(
        livro: widget.bookName,
        capitulo: widget.chapterNumber,
        versiculo: v,
        texto: chapterAtual[v - 1],
      );

      if (isFavorito(v)) {
        await favoritosService.removerFavorito(favorito);
      }
    }

    await carregarDados();

    if (!mounted) return;

    setState(() {
      selectedVerses.clear();
    });
  }

  /// 🔥 abre o menu de ações da seleção
  void abrirMenuSelecao() {
    if (selectedVerses.isEmpty) return;

    final versiculo = _primeiroSelecionado();
    if (versiculo == null) return;

    final multiSelecao = selectedVerses.length > 1;
    final anotado = temAnotacao(versiculo);
    final favorito = isFavorito(versiculo);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(anotado ? Icons.edit : Icons.note_add),
                title: Text(multiSelecao ? "Anotar versículos" : "Anotar"),
                onTap: () {
                  Navigator.pop(sheetContext);
                  anotarVersiculosSelecionados();
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: Text(
                  multiSelecao
                      ? "Favoritar selecionados"
                      : (favorito ? "Favoritado" : "Favoritar"),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  favoritarSelecionados();
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: Text(
                  multiSelecao ? "Remover favoritos" : "Remover favorito",
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  removerFavoritosSelecionados();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(
                  multiSelecao ? "Excluir anotações" : "Excluir anotação",
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  removerAnotacoesSelecionadas();
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text("Copiar"),
                onTap: () {
                  Navigator.pop(sheetContext);
                  copiarVersiculos();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("Compartilhar"),
                onTap: () {
                  Navigator.pop(sheetContext);
                  compartilharVersiculos();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔥 abre o menu do topo com versão e fonte
  void abrirMenuTopo() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ValueListenableBuilder<double>(
            valueListenable: ControleFonteBiblia.tamanhoFonte,
            builder: (context, fonte, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text("Trocar versão"),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, "/versao");
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.text_increase),
                    title: Text(
                      "Aumentar letra (${fonte.toStringAsFixed(0)})",
                    ),
                    onTap: () async {
                      await ControleFonteBiblia.aumentar();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.text_decrease),
                    title: Text(
                      "Diminuir letra (${fonte.toStringAsFixed(0)})",
                    ),
                    onTap: () async {
                      await ControleFonteBiblia.diminuir();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.restart_alt),
                    title: const Text("Tamanho normal"),
                    onTap: () async {
                      await ControleFonteBiblia.normal();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text("Fechar"),
                    onTap: () {
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// 🔥 vai direto ao versículo destacado, sem rolagem animada
  void _scrollToVerse() {
    if (widget.highlightVerse == null) return;

    final int verse = widget.highlightVerse!;
    final key = verseKeys.putIfAbsent(verse, () => GlobalKey());

    final contextTarget = key.currentContext;

    // 🔥 se ainda não estiver pronto, tenta novamente no próximo frame
    if (contextTarget == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse();
      });
      return;
    }

    // 🔥 salto imediato para o versículo escolhido
    Scrollable.ensureVisible(
      contextTarget,
      duration: Duration.zero,
      curve: Curves.linear,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.bookName} ${widget.chapterNumber}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: abrirMenuTopo,
          ),
        ],
      ),
      body: ValueListenableBuilder<double>(
        valueListenable: ControleFonteBiblia.tamanhoFonte,
        builder: (context, fonte, _) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List.generate(chapterAtual.length, (index) {
                final verseNumber = index + 1;
                final anotado = temAnotacao(verseNumber);
                final selecionado = selectedVerses.contains(verseNumber);
                final favorite = isFavorito(verseNumber);
                final highlighted = highlightedVerse == verseNumber;

                // 🔥 cria ou recupera a chave do versículo
                final verseKey =
                    verseKeys.putIfAbsent(verseNumber, () => GlobalKey());

                return GestureDetector(
                  // 🔥 primeiro toque longo só seleciona, sem abrir menu automaticamente
                  onLongPress: () {
                    setState(() {
                      if (!selectedVerses.contains(verseNumber)) {
                        selectedVerses.add(verseNumber);
                      }
                    });
                  },
                  onTap: () {
                    // 🔥 quando houver seleção ativa, o toque simples alterna seleção
                    if (selectedVerses.isNotEmpty) {
                      toggleSelectVerse(verseNumber);
                    } else if (anotado) {
                      // 🔥 se não houver seleção e o versículo tiver anotação, mostra a anotação
                      verAnotacao(verseNumber);
                    }
                  },
                  child: Container(
                    key: verseKey,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: highlighted
                          ? Colors.amber.withOpacity(0.25)
                          : selecionado
                              ? Colors.blue.withOpacity(0.18)
                              : anotado
                                  ? Colors.orange.withOpacity(0.08)
                                  : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selecionado ? Colors.blue : Colors.brown,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "$verseNumber",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            chapterAtual[index],
                            style: TextStyle(
                              height: 1.5,
                              fontSize: fonte,
                            ),
                          ),
                        ),
                        if (anotado || favorite) ...[
                          const SizedBox(width: 8),
                          if (anotado)
                            const Icon(
                              Icons.edit_note,
                              size: 18,
                              color: Colors.orange,
                            ),
                          if (favorite)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.favorite,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
      floatingActionButton: selectedVerses.isNotEmpty
          ? FloatingActionButton(
              onPressed: abrirMenuSelecao,
              child: const Icon(Icons.more_horiz),
            )
          : null,
    );
  }
}