import 'package:flutter/material.dart';

import 'calcs_page.dart';
import 'home_page.dart';
import 'learn_page.dart';
import 'projects_page.dart';
import 'sims_page.dart';

/// Alt gezinme çubuğu: Ana Sayfa, Hesaplamalar, Öğren, Simülasyonlar, Projeler.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  Widget _page() {
    switch (_index) {
      case 1:
        return const CalcsPage();
      case 2:
        return const LearnPage();
      case 3:
        return const SimsPage();
      case 4:
        return const ProjectsPage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'Hesapla'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Öğren'),
          NavigationDestination(icon: Icon(Icons.science_outlined), selectedIcon: Icon(Icons.science), label: 'Simülasyon'),
          NavigationDestination(icon: Icon(Icons.precision_manufacturing_outlined), selectedIcon: Icon(Icons.precision_manufacturing), label: 'Projeler'),
        ],
      ),
    );
  }
}
