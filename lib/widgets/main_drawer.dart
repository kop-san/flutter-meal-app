import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({
    super.key,
    required this.onSelectScreen,
    required this.onLogout,
  });

  final void Function(String identifier) onSelectScreen;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fastfood,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 18),
                Text('Cooking Up!',
                    style: theme.textTheme.titleLarge!.copyWith(
                      color: theme.colorScheme.primary,
                    )),
              ],
            ),
          ),
          ListTile(
            leading:
                Icon(Icons.restaurant, color: theme.colorScheme.onSurface),
            title: Text(
              'Meals',
              style: theme.textTheme.titleSmall!.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 22,
              ),
            ),
            onTap: () {
              onSelectScreen('meals');
            },
          ),
          ListTile(
            leading:
                Icon(Icons.settings, color: theme.colorScheme.onSurface),
            title: Text(
              'Filters',
              style: theme.textTheme.titleSmall!.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 22,
              ),
            ),
            onTap: () {
              onSelectScreen('filters');
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: theme.colorScheme.onSurface),
            title: Text(
              'Profile',
              style: theme.textTheme.titleSmall!.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 22,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.search, color: theme.colorScheme.onSurface),
            title: Text(
              'Search',
              style: theme.textTheme.titleSmall!.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 22,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/search');
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              thickness: 1,
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Logout',
              style: theme.textTheme.titleSmall!.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            onTap: onLogout,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
