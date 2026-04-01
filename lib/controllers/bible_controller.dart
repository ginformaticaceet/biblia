// lib/controllers/bible_controller.dart

import 'package:flutter/material.dart';
import '../services/bible_service.dart';

class BibleController {

  // 🔥 controla a versão atual da Bíblia (reativo)
  static ValueNotifier<String> versao = ValueNotifier("nvi");

  // 🔥 serviço para salvar/carregar versão
  static final BibleService _service = BibleService();

  /// 🔥 Inicializa o controller carregando a versão salva
  static Future<void> inicializar() async {

    // 🔥 pega versão salva no celular
    final versaoSalva = await _service.getVersaoSelecionada();

    // 🔥 atualiza o ValueNotifier (isso atualiza toda UI)
    versao.value = versaoSalva;
  }

  /// 🔥 Troca a versão da Bíblia
  static Future<void> trocarVersao(String novaVersao) async {

    // 🔥 evita atualizar se for a mesma versão
    if (versao.value == novaVersao) return;

    // 🔥 atualiza estado (UI reage automaticamente)
    versao.value = novaVersao;

    // 🔥 salva no dispositivo
    await _service.salvarVersao(novaVersao);
  }

  /// 🔥 Retorna nome formatado (para UI)
  static String get nomeVersao {

    switch (versao.value.toLowerCase()) {
      case "ara":
        return "ARA";
      case "arc":
        return "ARC";
      case "nvt":
        return "NVT";
      case "naa":
        return "NAA";
      case "jfaa":
        return "JFAA";
      default:
        return "NVI";
    }
  }
}