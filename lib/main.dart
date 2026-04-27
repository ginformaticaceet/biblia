// lib/main.dart

import 'package:flutter/material.dart';

import 'controllers/bible_controller.dart';
import 'controllers/controle_fonte_biblia.dart';

import 'screens/biblia_screen.dart';
import 'screens/devocional_screen.dart';
import 'screens/favoritos_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/livros_screen.dart';
import 'screens/pesquisa_screen.dart';
import 'screens/plano_leitura_screen.dart';
import 'screens/versao_screen.dart';
import 'screens/anotacoes_screen.dart';

void main() async {
  // 🔥 garante que o Flutter inicialize corretamente antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 carrega a versão salva da Bíblia
  await BibleController.inicializar();

  // 🔥 carrega o tamanho salvo da fonte
  await ControleFonteBiblia.inicializar();

  // 🔥 inicia o aplicativo
  runApp(const BibliaApp());
}

class BibliaApp extends StatefulWidget {
  const BibliaApp({super.key});

  // 🔥 acesso ao estado global para alternar tema
  static _BibliaAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_BibliaAppState>();
  }

  @override
  State<BibliaApp> createState() => _BibliaAppState();
}

class _BibliaAppState extends State<BibliaApp> {
  // 🔥 controla o tema
  ThemeMode _themeMode = ThemeMode.light;

  /// 🔥 alterna entre claro e escuro
  void alternarTema() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bíblia",
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      home: const InicioScreen(),

      routes: {
        "/inicio": (context) => const InicioScreen(),
        "/biblia": (context) => const BibliaScreen(),
        "/livros": (context) => const LivrosScreen(),
        "/pesquisa": (context) => const PesquisaScreen(),
        "/favoritos": (context) => const FavoritosScreen(),
        "/plano": (context) => const PlanoLeituraScreen(),
        "/versao": (context) => const VersaoScreen(),
        "/devocional": (context) => const DevocionalScreen(),
        "/anotacoes": (context) => const AnotacoesScreen(),
      },
    );
  }
}