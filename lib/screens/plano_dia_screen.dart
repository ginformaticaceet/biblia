// lib/screens/plano_dia_screen.dart

import 'package:flutter/material.dart';
import '../models/plano_leitura_model.dart';
import '../widgets/botao_versao.dart';
import 'versiculos_screen.dart';

/// Tela que mostra as leituras de um dia específico do plano.
class PlanoDiaScreen extends StatefulWidget {
  final PlanoDia planoDia;
  final bool jaLido;

  const PlanoDiaScreen({
    super.key,
    required this.planoDia,
    required this.jaLido,
  });

  @override
  State<PlanoDiaScreen> createState() => _PlanoDiaScreenState();
}

class _PlanoDiaScreenState extends State<PlanoDiaScreen> {
  late bool lido;

  @override
  void initState() {
    super.initState();
    lido = widget.jaLido;
  }

  /// 🔥 alterna o estado de leitura do dia
  void toggleLido() {
    setState(() {
      lido = !lido;
    });

    // 🔥 retorna o novo estado para a tela anterior salvar o progresso
    Navigator.pop(context, lido);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dia ${widget.planoDia.dia}"),

        // 🔥 botão de versão no topo
        actions: [
          BotaoVersao(
            onTap: () {
              Navigator.pushNamed(context, "/versao");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: widget.planoDia.leituras.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final leitura = widget.planoDia.leituras[index];

                  return Material(
                    color: Colors.grey.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VersiculosScreen(
                              chapter: leitura["versiculos"],
                              chapterNumber: leitura["capitulo"],
                              bookName: leitura["livro"],
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
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.menu_book,
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
                                    "${leitura["livro"]} ${leitura["capitulo"]}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Toque para abrir a leitura",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: Icon(
                  lido ? Icons.undo : Icons.check,
                ),
                label: Text(
                  lido ? "Desmarcar leitura" : "Marcar como lido",
                ),
                onPressed: toggleLido,
              ),
            ),
          ],
        ),
      ),
    );
  }
}