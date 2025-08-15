import 'package:flutter/material.dart';
import 'package:flutter_cep/core/theme/app_theme.dart';
import 'package:flutter_cep/ui/home_screen.dart';

void main() {
  runApp(const FlutterCEPApp());
}

class FlutterCEPApp extends StatelessWidget {
  const FlutterCEPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta de Cep',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    );
  }
}
