import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'shell.dart';

class TechnikalcApp extends StatelessWidget {
  const TechnikalcApp({super.key});

  ThemeData _theme(Brightness b) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0B57D0),
        brightness: b,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teknik Hesap Makinesi',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const AppShell(),
    );
  }
}
