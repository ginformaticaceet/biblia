// lib/screens/anotacoes_screen.dart

import 'package:flutter/material.dart';

import '../controllers/controle_fonte_biblia.dart';
import '../models/anotacao_model.dart';
import '../services/anotacao_service.dart';

class AnotacoesScreen extends StatefulWidget {
  const AnotacoesScreen({super.key});

  @override
  State<AnotacoesScreen> createState() => _AnotacoesScreenState();
}

class _AnotacoesScreenState extends State<AnotacoesScreen> {
  final AnotacaoService service = AnotacaoService();

  List<Anotacao> anotacoes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarAnotacoes();
  }

  /// 🔥 carrega anotações salvas
  Future<void> carregarAnotacoes() async {
    setState(() {
      carregando = true;
    });

    final lista = await service.getAnotacoes();

    if (!mounted) return;

    setState(() {
      anotacoes = lista.reversed.toList(); // 🔥 mais recentes primeiro
      carregando = false;
    });
  }

  /// 🔥 remove anotação
  Future<void> removerAnotacao(Anotacao anotacao) async {
    await service.removerAnotacao(anotacao);
    await carregarAnotacoes();
  }

  /// 🔥 mostra detalhe da anotação
  void abrirDetalhe(Anotacao anotacao) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("${anotacao.livro} ${anotacao.capitulo}:${anotacao.versiculo}"),
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

                /// 🔥 texto bíblico com fonte global
                ValueListenableBuilder<double>(
                  valueListenable: ControleFonteBiblia.tamanhoFonte,
                  builder: (context, fonte, _) {
                    return Text(
                      anotacao.texto,
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
                  anotacao.anotacao,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Fechar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await removerAnotacao(anotacao);
              },
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anotações"),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : anotacoes.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhuma anotação ainda",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: anotacoes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final anotacao = anotacoes[index];

                    return Material(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          abrirDetalhe(anotacao);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.edit_note,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${anotacao.livro} ${anotacao.capitulo}:${anotacao.versiculo}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      anotacao.anotacao,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await removerAnotacao(anotacao);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}