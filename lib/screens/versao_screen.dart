// lib/screens/versao_screen.dart

import 'package:flutter/material.dart';
import '../controllers/bible_controller.dart';

/// Tela para escolher a versão da Bíblia.
class VersaoScreen extends StatefulWidget {
  const VersaoScreen({super.key});

  @override
  State<VersaoScreen> createState() => _VersaoScreenState();
}

class _VersaoScreenState extends State<VersaoScreen> {
  String versaoAtual = BibleController.versao.value;

  // 🔥 lista de versões e nomes completos
  final Map<String, String> versoes = {
    "ara": "Almeida Revista e Atualizada",
    "arc": "Almeida Revista e Corrigida",
    "jfaa": "João Ferreira de Almeida",
    "naa": "Nova Almeida Atualizada",
    "nvi": "Nova Versão Internacional",
    "nvt": "Nova Versão Transformadora",
  };

  @override
  void initState() {
    super.initState();

    // 🔥 garante que a tela abre já com a versão atual
    versaoAtual = BibleController.versao.value;
  }

  /// 🔥 seleciona a nova versão
  Future<void> selecionar(String chave) async {
    if (chave == versaoAtual) {
      Navigator.pop(context);
      return;
    }

    // 🔥 troca pela fonte única do app
    await BibleController.trocarVersao(chave);

    if (!mounted) return;

    setState(() {
      versaoAtual = chave;
    });

    // 🔥 volta para a tela anterior já com a versão trocada
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Versão da Bíblia"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: versoes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final entry = versoes.entries.elementAt(index);
          final bool selecionado = entry.key == versaoAtual;

          return Material(
            color: selecionado
                ? Colors.purple.withOpacity(0.10)
                : Colors.grey.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                selecionar(entry.key);
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
                        color: selecionado ? Colors.purple : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.key.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selecionado)
                      const Icon(Icons.check, color: Colors.green)
                    else
                      const Icon(Icons.arrow_forward_ios),
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