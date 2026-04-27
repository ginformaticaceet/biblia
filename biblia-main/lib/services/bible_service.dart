// lib/services/bible_service.dart

import 'dart:convert'; // converte JSON
import 'package:flutter/services.dart'; // acesso aos assets
import 'package:shared_preferences/shared_preferences.dart'; // armazenamento local

import '../models/bible_model.dart'; // modelo da Bíblia
import '../controllers/bible_controller.dart'; // controle de versão

class BibleService {

  // 🔥 Cache em memória para evitar recarregar o JSON toda hora
  static Bible? _cacheBible;
  static String? _versaoCache;

  /// 🔥 Pega a versão salva no celular
  Future<String> getVersaoSelecionada() async {
    final prefs = await SharedPreferences.getInstance();

    // retorna versão salva ou "nvi" como padrão
    return prefs.getString("versao_biblia") ?? "nvi";
  }

  /// 🔥 Salva a versão escolhida
  Future<void> salvarVersao(String versao) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("versao_biblia", versao);

    // 🔥 limpa cache ao trocar versão (IMPORTANTE)
    _cacheBible = null;
    _versaoCache = null;
  }

  /// 🔥 Carrega a Bíblia baseada na versão atual
  Future<Bible> loadBible() async {

    final versao = BibleController.versao.value;

    // 🔥 se já tiver carregado essa versão, reutiliza
    if (_cacheBible != null && _versaoCache == versao) {
      return _cacheBible!;
    }

    try {
      // 🔥 carrega JSON do asset
      final String jsonString =
          await rootBundle.loadString('assets/bible/$versao.json');

      // 🔥 converte JSON
      final dynamic data = json.decode(jsonString);

      Bible bible;

      // 🔥 verifica formato (evita erro List vs Map)
      if (data is List) {
        bible = Bible.fromJson(data);
      } else if (data is Map<String, dynamic>) {
        bible = Bible.fromJson(data['books'] ?? [data]);
      } else {
        throw Exception("Formato inválido da Bíblia");
      }

      // 🔥 salva no cache
      _cacheBible = bible;
      _versaoCache = versao;

      return bible;

    } catch (e) {
      // 🔥 erro mais claro
      throw Exception("Erro ao carregar Bíblia ($versao): $e");
    }
  }
}