import 'dart:math';
import '../models/bible_model.dart';
import '../models/plano_leitura_model.dart';

class PlanoLeituraService {

  List<PlanoDia> gerarPlano(Bible bible) {

    /// 🔥 SEED FIXA (resolve o bug)
    final Random random = Random(42);

    List<PlanoDia> plano = [];

    Set<String> leiturasUsadas = {};

    for (int dia = 1; dia <= 365; dia++) {

      List<Map<String, dynamic>> leiturasDia = [];

      while (leiturasDia.length < 3) {

        final book = bible.books[random.nextInt(bible.books.length)];

        final capitulo =
            random.nextInt(book.chapters.length) + 1;

        String chave = "${book.name}-$capitulo";

        if (!leiturasUsadas.contains(chave)) {

          leiturasUsadas.add(chave);

          leiturasDia.add({
            "livro": book.name,
            "capitulo": capitulo,
            "versiculos": book.chapters[capitulo - 1]
          });

        }

      }

      plano.add(
        PlanoDia(
          dia: dia,
          leituras: leiturasDia,
        ),
      );
    }

    return plano;
  }
}