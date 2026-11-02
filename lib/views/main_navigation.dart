import 'package:flutter/material.dart';
import '../core/localization/app_localizations.dart';
import 'products/product_list_view.dart';
import 'favourites/favourites_view.dart';
import 'settings/settings_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProductListView(),
    const FavouritesView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: l10n.translate('products'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: l10n.translate('favourites'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.translate('settings'),
          ),
        ],
      ),
    );
  }
}
