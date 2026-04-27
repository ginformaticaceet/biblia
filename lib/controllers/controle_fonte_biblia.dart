// lib/controllers/controle_fonte_biblia.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControleFonteBiblia {
  // 🔥 chave usada para salvar o tamanho da fonte
  static const String _chave = "tamanho_fonte_biblia";

  // 🔥 tamanho padrão
  static const double _padrao = 16.0;

  // 🔥 limites para evitar exagero
  static const double _minimo = 14.0;
  static const double _maximo = 24.0;

  // 🔥 passo de alteração
  static const double _passo = 1.0;

  // 🔥 valor reativo para a UI acompanhar
  static final ValueNotifier<double> tamanhoFonte =
      ValueNotifier<double>(_padrao);

  /// 🔥 carrega o tamanho salvo no aparelho
  static Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    tamanhoFonte.value = prefs.getDouble(_chave) ?? _padrao;
  }

  /// 🔥 salva o tamanho atual
  static Future<void> _salvar(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_chave, valor);
  }

  /// 🔥 aumenta a fonte
  static Future<void> aumentar() async {
    final novoValor = (tamanhoFonte.value + _passo).clamp(_minimo, _maximo);
    tamanhoFonte.value = novoValor;
    await _salvar(novoValor);
  }

  /// 🔥 diminui a fonte
  static Future<void> diminuir() async {
    final novoValor = (tamanhoFonte.value - _passo).clamp(_minimo, _maximo);
    tamanhoFonte.value = novoValor;
    await _salvar(novoValor);
  }

  /// 🔥 volta ao tamanho padrão
  static Future<void> normal() async {
    tamanhoFonte.value = _padrao;
    await _salvar(_padrao);
  }
}