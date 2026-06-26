import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (path: '/',        icon: Icons.home_outlined,      label: 'Home'),
    (path: '/explore', icon: Icons.explore_outlined,   label: 'Explorar'),
    (path: '/ai',      icon: Icons.smart_toy_outlined, label: 'Guru IA'),
    (path: '/library', icon: Icons.menu_book_outlined, label: 'Biblioteca'),
    (path: '/me',      icon: Icons.person_outlined,    label: 'Perfil'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => t.path == location);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}
