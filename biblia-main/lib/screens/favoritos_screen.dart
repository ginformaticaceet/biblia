// lib/screens/favoritos_screen.dart

import 'package:flutter/material.dart';
import '../models/favorito_model.dart';
import '../services/favoritos_service.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {

  final FavoritosService service = FavoritosService();

  List<Favorito> favoritos = [];

  @override
  void initState() {
    super.initState();
    carregarFavoritos();
  }

  /// 🔥 carrega favoritos
  void carregarFavoritos() async {

    final lista = await service.getFavoritos();

    setState(() {
      favoritos = lista;
    });
  }

  /// 🔥 remove favorito
  void removerFavorito(Favorito favorito) async {

    await service.removerFavorito(favorito);

    carregarFavoritos();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.favorite),
            SizedBox(width: 8),
            Text("Versículos Favoritos"),
          ],
        ),
      ),

      body: favoritos.isEmpty
          ? const Center(
              child: Text(
                "Nenhum favorito ainda",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(

              padding: const EdgeInsets.all(12),

              itemCount: favoritos.length,

              itemBuilder: (context, index) {

                final f = favoritos[index];

                return Padding(

                  padding: const EdgeInsets.symmetric(vertical: 4),

                  /// 🔥 CARD PADRÃO
                  child: Material(

                    color: Colors.red.withOpacity(0.08),

                    borderRadius: BorderRadius.circular(8), // ✅ PADRÃO

                    child: InkWell(

                      borderRadius: BorderRadius.circular(8),

                      onTap: () {
                        // 👉 depois podemos abrir direto no versículo
                      },

                      child: Padding(

                        padding: const EdgeInsets.all(12),

                        child: Row(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            /// 🔢 número do versículo
                            Container(

                              width: 32,
                              height: 32,

                              alignment: Alignment.center,

                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),

                              child: Text(
                                "${f.versiculo}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            /// 📖 TEXTO
                            Expanded(

                              child: Column(

                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  /// referência
                                  Text(
                                    "${f.livro} ${f.capitulo}:${f.versiculo}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  /// versículo
                                  Text(
                                    f.texto,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// ❤️ botão remover
                            IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                removerFavorito(f);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}