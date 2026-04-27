// lib/models/anotacao_model.dart

class Anotacao {
  final String livro;
  final int capitulo;
  final int versiculo;
  final String texto;
  final String anotacao;

  Anotacao({
    required this.livro,
    required this.capitulo,
    required this.versiculo,
    required this.texto,
    required this.anotacao,
  });

  /// 🔥 converte objeto para JSON
  Map<String, dynamic> toJson() {
    return {
      "livro": livro,
      "capitulo": capitulo,
      "versiculo": versiculo,
      "texto": texto,
      "anotacao": anotacao,
    };
  }

  /// 🔥 converte JSON para objeto
  factory Anotacao.fromJson(Map<String, dynamic> json) {
    return Anotacao(
      livro: json["livro"]?.toString() ?? "",
      capitulo: json["capitulo"] is int
          ? json["capitulo"]
          : int.tryParse(json["capitulo"].toString()) ?? 0,
      versiculo: json["versiculo"] is int
          ? json["versiculo"]
          : int.tryParse(json["versiculo"].toString()) ?? 0,
      texto: json["texto"]?.toString() ?? "",
      anotacao: json["anotacao"]?.toString() ?? "",
    );
  }
}