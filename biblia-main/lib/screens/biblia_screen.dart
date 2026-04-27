// lib/screens/biblia_screen.dart

import 'package:flutter/material.dart';
import '../widgets/botao_versao.dart';
import 'livros_screen.dart';

/// Tela simples de entrada para a leitura da Bíblia.
class BibliaScreen extends StatelessWidget {
  const BibliaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bíblia"),

        // 🔥 botão de versão no topo para manter padrão visual
        actions: [
          BotaoVersao(
            onTap: () {
              Navigator.pushNamed(context, "/versao");
            },
          ),
        ],
      ),
      body: Center(
        child: Material(
          // 🔥 fundo leve, limpo e consistente
          color: Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LivrosScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // 🔥 ícone dentro de caixa
                  Icon(Icons.menu_book),
                  SizedBox(width: 10),
                  Text(
                    "Abrir Livros da Bíblia",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}