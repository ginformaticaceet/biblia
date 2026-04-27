// lib/screens/plano_leitura_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/bible_controller.dart';
import '../models/bible_model.dart';
import '../models/plano_leitura_model.dart';
import '../services/bible_service.dart';
import '../services/plano_leitura_service.dart';
import '../widgets/botao_versao.dart';
import 'plano_dia_screen.dart';

/// Tela principal do plano de leitura anual.
class PlanoLeituraScreen extends StatefulWidget {
  const PlanoLeituraScreen({super.key});

  @override
  State<PlanoLeituraScreen> createState() => _PlanoLeituraScreenState();
}

class _PlanoLeituraScreenState extends State<PlanoLeituraScreen> {
  final BibleService bibleService = BibleService();
  final PlanoLeituraService planoService = PlanoLeituraService();

  Bible? bible;
  List<PlanoDia> plano = [];
  Set<int> diasLidos = {};

  bool carregando = true;

  @override
  void initState() {
    super.initState();

    // 🔥 carrega plano e progresso
    carregarTudo();

    // 🔥 recarrega ao trocar versão
    BibleController.versao.addListener(_onVersaoAlterada);
  }

  @override
  void dispose() {
    BibleController.versao.removeListener(_onVersaoAlterada);
    super.dispose();
  }

  /// 🔥 quando a versão muda, recarrega tudo
  void _onVersaoAlterada() {
    if (!mounted) return;
    carregarTudo();
  }

  /// 🔑 chave do plano por versão
  String _chavePlano() => "plano_leitura_${BibleController.versao.value}";

  /// 🔑 chave do progresso por versão
  String _chaveProgresso() => "dias_lidos_${BibleController.versao.value}";

  /// 🔥 carrega Bíblia, plano e progresso
  Future<void> carregarTudo() async {
    setState(() {
      carregando = true;
    });

    final b = await bibleService.loadBible();
    final planoCarregado = await _carregarPlanoOuGerar(b);
    final progressoCarregado = await _carregarProgresso();

    if (!mounted) return;

    setState(() {
      bible = b;
      plano = planoCarregado;
      diasLidos = progressoCarregado;
      carregando = false;
    });
  }

  /// 🔥 carrega plano salvo ou gera um novo
  Future<List<PlanoDia>> _carregarPlanoOuGerar(Bible b) async {
    final prefs = await SharedPreferences.getInstance();
    final chave = _chavePlano();
    final salvo = prefs.getString(chave);

    // 🔥 se já existir plano salvo, usa ele
    if (salvo != null && salvo.isNotEmpty) {
      final List<dynamic> lista = jsonDecode(salvo);

      return lista
          .map((item) => PlanoDia.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // 🔥 se não existir, gera um novo plano
    final novoPlano = planoService.gerarPlano(b);

    // 🔥 salva o plano gerado para manter estável
    await prefs.setString(
      chave,
      jsonEncode(novoPlano.map((e) => e.toJson()).toList()),
    );

    return novoPlano;
  }

  /// 🔥 carrega progresso salvo
  Future<Set<int>> _carregarProgresso() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_chaveProgresso()) ?? [];

    return lista.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
  }

  /// 🔥 salva progresso
  Future<void> _salvarProgresso() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = diasLidos.map((e) => e.toString()).toList();
    await prefs.setStringList(_chaveProgresso(), lista);
  }

  /// 🔥 abre um dia específico
  Future<void> abrirDia(PlanoDia diaPlano) async {
    final bool jaLido = diasLidos.contains(diaPlano.dia);

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlanoDiaScreen(
          planoDia: diaPlano,
          jaLido: jaLido,
        ),
      ),
    );

    // 🔥 se o usuário marcou/desmarcou, salva o progresso
    if (resultado != null) {
      setState(() {
        if (resultado == true) {
          diasLidos.add(diaPlano.dia);
        } else {
          diasLidos.remove(diaPlano.dia);
        }
      });

      await _salvarProgresso();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final int totalDias = plano.length;
    final int concluidos = diasLidos.length;
    final double progresso = totalDias == 0 ? 0 : concluidos / totalDias;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plano de Leitura"),

        // 🔥 botão de versão no topo
        actions: [
          BotaoVersao(
            onTap: () {
              Navigator.pushNamed(context, "/versao");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.green.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$concluidos / $totalDias dias concluídos",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: plano.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final diaPlano = plano[index];
                final bool lido = diasLidos.contains(diaPlano.dia);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Material(
                    color: lido
                        ? Colors.green.withOpacity(0.08)
                        : Colors.grey.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        abrirDia(diaPlano);
                      },
                      child: ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: lido ? Colors.green : Colors.brown,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            lido ? Icons.check : Icons.menu_book,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          "Dia ${diaPlano.dia}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          lido ? "Leitura concluída" : "Leitura do dia",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
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