// lib/screens/devocional_screen.dart

import 'package:flutter/material.dart';
import '../services/devocional_service.dart';
import '../services/bible_service.dart';
import '../controllers/bible_controller.dart';
import '../widgets/botao_versao.dart';

class DevocionalScreen extends StatefulWidget {
  const DevocionalScreen({super.key});

  @override
  State<DevocionalScreen> createState() => _DevocionalScreenState();
}

class _DevocionalScreenState extends State<DevocionalScreen> {

  final BibleService bibleService = BibleService();
  final DevocionalService devocionalService = DevocionalService();

  Map<String, dynamic>? devocional;

  @override
  void initState() {
    super.initState();

    carregarDevocional();

    /// 🔥 atualiza ao trocar versão
    BibleController.versao.addListener(carregarDevocional);
  }

  @override
  void dispose() {
    BibleController.versao.removeListener(carregarDevocional);
    super.dispose();
  }

  /// 🔥 carrega devocional do dia
  void carregarDevocional() async {

    final bible = await bibleService.loadBible();

    final d = devocionalService.getDevocional(bible);

    if (!mounted) return;

    setState(() {
      devocional = d;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (devocional == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Devocional do Dia"),

        /// 🔥 padrão do app
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

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// 🔥 CARD PADRÃO (igual resto do app)
            Material(

              color: Colors.deepPurple.withOpacity(0.08),

              borderRadius: BorderRadius.circular(8),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Devocional do Dia",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 📖 referência
                    Text(
                      "${devocional!["livro"]} ${devocional!["capitulo"]}:${devocional!["versiculo"]}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 📜 texto
                    Text(
                      devocional!["texto"],
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),

                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}