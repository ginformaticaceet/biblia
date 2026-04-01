// lib/services/favoritos_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorito_model.dart';

class FavoritosService {

  // 🔥 chave usada no armazenamento
  static const String key = "favoritos";

  /// 🔥 Retorna lista de favoritos
  Future<List<Favorito>> getFavoritos() async {

    final prefs = await SharedPreferences.getInstance();

    final List<String>? lista = prefs.getStringList(key);

    // 🔥 se não houver dados, retorna lista vazia
    if (lista == null) return [];

    return lista.map((e) {
      try {
        return Favorito.fromJson(json.decode(e));
      } catch (_) {
        return null;
      }
    }).whereType<Favorito>().toList(); // remove inválidos
  }

  /// 🔥 Adiciona favorito (sem duplicar)
  Future<void> adicionarFavorito(Favorito favorito) async {

    final prefs = await SharedPreferences.getInstance();

    final lista = prefs.getStringList(key) ?? [];

    // 🔥 verifica se já existe
    final existe = lista.any((item) {
      final f = Favorito.fromJson(json.decode(item));
      return f.livro == favorito.livro &&
          f.capitulo == favorito.capitulo &&
          f.versiculo == favorito.versiculo;
    });

    // 🔥 só adiciona se não existir
    if (!existe) {
      lista.add(json.encode(favorito.toJson()));
      await prefs.setStringList(key, lista);
    }
  }

  /// 🔥 Remove favorito
  Future<void> removerFavorito(Favorito favorito) async {

    final prefs = await SharedPreferences.getInstance();

    final lista = prefs.getStringList(key) ?? [];

    lista.removeWhere((item) {

      final f = Favorito.fromJson(json.decode(item));

      return f.livro == favorito.livro &&
          f.capitulo == favorito.capitulo &&
          f.versiculo == favorito.versiculo;
    });

    await prefs.setStringList(key, lista);
  }
}