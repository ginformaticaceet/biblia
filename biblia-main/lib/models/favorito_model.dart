// lib/models/favorito_model.dart

class Favorito {

  final String livro;
  final int capitulo;
  final int versiculo;
  final String texto;

  Favorito({
    required this.livro,
    required this.capitulo,
    required this.versiculo,
    required this.texto,
  });

  /// 🔥 Converte objeto → JSON
  Map<String, dynamic> toJson() {
    return {
      "livro": livro,
      "capitulo": capitulo,
      "versiculo": versiculo,
      "texto": texto,
    };
  }

  /// 🔥 Converte JSON → objeto
  factory Favorito.fromJson(Map<String, dynamic> json) {

    return Favorito(
      livro: json["livro"]?.toString() ?? "",
      capitulo: json["capitulo"] is int
          ? json["capitulo"]
          : int.tryParse(json["capitulo"].toString()) ?? 0,
      versiculo: json["versiculo"] is int
          ? json["versiculo"]
          : int.tryParse(json["versiculo"].toString()) ?? 0,
      texto: json["texto"]?.toString() ?? "",
    );
  }
}