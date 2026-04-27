// lib/widgets/item_lista_padrao.dart

import 'package:flutter/material.dart';

class ItemListaPadrao extends StatelessWidget {

  final String titulo;
  final String? subtitulo;
  final IconData icone;
  final Color cor;
  final VoidCallback onTap;

  const ItemListaPadrao({
    super.key,
    required this.titulo,
    this.subtitulo,
    required this.icone,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

      child: Material(

        color: cor.withOpacity(0.08),

        borderRadius: BorderRadius.circular(8),

        child: InkWell(

          borderRadius: BorderRadius.circular(8),

          onTap: onTap,

          child: Padding(

            padding: const EdgeInsets.all(12),

            child: Row(

              children: [

                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icone, color: Colors.white, size: 18),
                ),

                const SizedBox(width: 10),

                Expanded(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (subtitulo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitulo!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Icon(Icons.arrow_forward_ios),

              ],
            ),
          ),
        ),
      ),
    );
  }
}