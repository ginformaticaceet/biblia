// lib/widgets/titulo_tela.dart

import 'package:flutter/material.dart';

class TituloTela extends StatelessWidget {

  final String titulo;
  final IconData icone;

  const TituloTela({
    super.key,
    required this.titulo,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icone,
            size: 18,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          titulo,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

      ],
    );
  }
}