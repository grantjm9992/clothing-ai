import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';

// Auth Screen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checkroom, size: 64),
            const SizedBox(height: 24),
            Text('Clothing AI', style: AppTheme.h1, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('Your personal AI stylist', style: AppTheme.bodyMedium),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Clothing AI')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ActionCard(
          title: 'Fit Check',
          subtitle: 'Get AI feedback on your outfit',
          icon: Icons.camera_alt,
          onTap: () => context.push('/fit-check'),
        ),
        const SizedBox(height: 16),
        _ActionCard(
          title: 'My Wardrobe',
          subtitle: 'Manage clothing items',
          icon: Icons.checkroom,
          onTap: () => context.push('/wardrobe'),
        ),
      ],
    ),
  );
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.h3),
                  Text(subtitle, style: AppTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Wardrobe Screen
class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Wardrobe')),
    body: const Center(child: Text('Wardrobe items')),
  );
}

// Router
final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/wardrobe', builder: (_, __) => const WardrobeScreen()),
    GoRoute(path: '/fit-check', builder: (_, __) => const Scaffold(
      appBar: AppBar(title: Text('Fit Check')),
      body: Center(child: Text('Camera screen')),
    )),
  ],
);

// Main App
class ClothingAIApp extends ConsumerWidget {
  const ClothingAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Clothing AI',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
