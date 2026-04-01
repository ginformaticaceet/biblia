// lib/widgets/botao_versao.dart

import 'package:flutter/material.dart';
import '../controllers/bible_controller.dart';

class BotaoVersao extends StatefulWidget {

  final VoidCallback onTap;

  const BotaoVersao({
    super.key,
    required this.onTap,
  });

  @override
  State<BotaoVersao> createState() => _BotaoVersaoState();
}

class _BotaoVersaoState extends State<BotaoVersao> {

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<String>(

      valueListenable: BibleController.versao,

      builder: (context, versao, _) {

        return AnimatedScale(

          scale: _pressed ? 0.96 : 1.0,

          duration: const Duration(milliseconds: 120),

          child: Material(

            color: Colors.transparent,

            child: InkWell(

              borderRadius: BorderRadius.circular(8), // ✅ PADRÃO

              onTap: widget.onTap,

              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),

              child: Container(

                margin: const EdgeInsets.only(right: 12),

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(

                  color: Theme.of(context).cardColor,

                  borderRadius: BorderRadius.circular(8),

                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.25),
                  ),
                ),

                child: Row(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    const Icon(Icons.swap_horiz, size: 16),

                    const SizedBox(width: 6),

                    Text(
                      versao.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}