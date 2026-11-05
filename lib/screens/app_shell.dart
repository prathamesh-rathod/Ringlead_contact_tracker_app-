import 'package:flutter/material.dart';
import '../services/notes_repository.dart';
import '../theme.dart';
import 'calls_screen.dart';
import 'home_screen.dart';
import 'leads_screen.dart';
import 'profile_screen.dart';
import 'recordings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _callsKey = GlobalKey<CallsScreenState>();

  @override
  void initState() {
    super.initState();
    // Load the signed-in business's saved call notes once the app is open.
    NotesRepository.instance.load();
  }

  late final _screens = [
    const HomeScreen(),
    CallsScreen(key: _callsKey),
    const LeadsScreen(),
    const RecordingsScreen(),
    const ProfileScreen(),
  ];

  static const _items = [
    (icon: Icons.space_dashboard_outlined, activeIcon: Icons.space_dashboard_rounded, label: 'Home'),
    (icon: Icons.call_outlined, activeIcon: Icons.call_rounded, label: 'Calls'),
    (icon: Icons.flag_outlined, activeIcon: Icons.flag_rounded, label: 'Leads'),
    (icon: Icons.graphic_eq_outlined, activeIcon: Icons.graphic_eq_rounded, label: 'Audio'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  void goToTab(int index) => setState(() => _index = index);

  void goToCallsFiltered(String filter) {
    setState(() => _index = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _callsKey.currentState?.setFilterByValue(filter));
  }

  @override
  Widget build(BuildContext context) {
    return TabNavigator(
      goToTab: goToTab,
      goToCallsFiltered: goToCallsFiltered,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(bottom: false, child: IndexedStack(index: _index, children: _screens)),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.line)),
            boxShadow: AppShadows.nav,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
              child: Row(
                children: List.generate(_items.length, (i) {
                  final item = _items[i];
                  return Expanded(
                    child: _NavItem(
                      icon: item.icon,
                      activeIcon: item.activeIcon,
                      label: item.label,
                      active: i == _index,
                      onTap: () => goToTab(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.blue : AppColors.inkFaint;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: AppColors.blueSoft,
      highlightColor: AppColors.blueSoft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: active ? AppColors.blueSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
              child: Icon(active ? activeIcon : icon, size: 21, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabNavigator extends InheritedWidget {
  const TabNavigator({super.key, required this.goToTab, required this.goToCallsFiltered, required super.child});

  final ValueChanged<int> goToTab;
  final ValueChanged<String> goToCallsFiltered;

  static TabNavigator? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabNavigator>();
  }

  @override
  bool updateShouldNotify(TabNavigator oldWidget) => goToTab != oldWidget.goToTab;
}
