// lib/widgets/campo_busca.dart

import 'package:flutter/material.dart';

class CampoBusca extends StatelessWidget {

  final TextEditingController controller;
  final Function(String) onSearch;

  const CampoBusca({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.all(16),

      child: TextField(

        controller: controller,

        decoration: InputDecoration(

          hintText: "Buscar...",

          prefixIcon: const Icon(Icons.search),

          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => onSearch(controller.text),
          ),

          filled: true,
          fillColor: Colors.grey.withOpacity(0.08),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),

        onSubmitted: onSearch,
      ),
    );
  }
}