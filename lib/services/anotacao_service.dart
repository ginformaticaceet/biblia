// lib/services/anotacao_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anotacao_model.dart';

class AnotacaoService {
  // 🔥 chave usada no SharedPreferences
  static const String key = "anotacoes";

  /// 🔥 carrega todas as anotações salvas
  Future<List<Anotacao>> getAnotacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? lista = prefs.getStringList(key);

    if (lista == null) return [];

    return lista.map((e) {
      try {
        return Anotacao.fromJson(json.decode(e));
      } catch (_) {
        return Anotacao(
          livro: "",
          capitulo: 0,
          versiculo: 0,
          texto: "",
          anotacao: "",
        );
      }
    }).where((a) => a.livro.isNotEmpty).toList();
  }

  /// 🔥 salva ou atualiza anotação
  Future<void> salvarAnotacao(Anotacao anotacao) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(key) ?? [];

    // 🔥 remove anotação antiga do mesmo versículo, se existir
    lista.removeWhere((item) {
      final a = Anotacao.fromJson(json.decode(item));
      return a.livro == anotacao.livro &&
          a.capitulo == anotacao.capitulo &&
          a.versiculo == anotacao.versiculo;
    });

    // 🔥 adiciona a nova anotação
    lista.add(json.encode(anotacao.toJson()));

    await prefs.setStringList(key, lista);
  }

  /// 🔥 remove anotação
  Future<void> removerAnotacao(Anotacao anotacao) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(key) ?? [];

    lista.removeWhere((item) {
      final a = Anotacao.fromJson(json.decode(item));
      return a.livro == anotacao.livro &&
          a.capitulo == anotacao.capitulo &&
          a.versiculo == anotacao.versiculo;
    });

    await prefs.setStringList(key, lista);
  }
}