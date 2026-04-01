// lib/widgets/card_item.dart

import 'package:flutter/material.dart';

class CardItem extends StatelessWidget {

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  const CardItem({
    super.key,
    required this.child,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),

      child: Material(

        color: color ?? Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(8), // ✅ PADRÃO

        child: InkWell(

          borderRadius: BorderRadius.circular(8),

          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ),
      ),
    );
  }
}