// lib/models/plano_leitura_model.dart

class PlanoDia {

  // 🔥 número do dia (1 a 365)
  final int dia;

  // 🔥 lista de leituras do dia
  final List<Map<String, dynamic>> leituras;

  // 🔥 indica se o dia já foi lido
  bool lido;

  PlanoDia({
    required this.dia,
    required this.leituras,
    this.lido = false,
  });

  /// 🔥 (extra) converter para JSON futuramente
  Map<String, dynamic> toJson() {
    return {
      "dia": dia,
      "leituras": leituras,
      "lido": lido,
    };
  }

  /// 🔥 (extra) carregar do JSON
  factory PlanoDia.fromJson(Map<String, dynamic> json) {
    return PlanoDia(
      dia: json["dia"],
      leituras: List<Map<String, dynamic>>.from(json["leituras"]),
      lido: json["lido"] ?? false,
    );
  }
}