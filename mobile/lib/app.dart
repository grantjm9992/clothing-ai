import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/wardrobe/screens/wardrobe_screen.dart';
import 'features/outfit/screens/fit_check_screen.dart';

// Auth Screen
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.checkroom, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text('Clothing AI', style: AppTheme.h1, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Your personal AI stylist',
                style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Get Started'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AI-powered outfit feedback and wardrobe intelligence',
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('What would you like to do?', style: AppTheme.h2),
          const SizedBox(height: 8),
          Text(
            'Choose an option below to get started',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          _ActionCard(
            title: 'Fit Check',
            subtitle: 'Get AI feedback on your outfit',
            description: 'Take a photo and receive instant styling advice',
            icon: Icons.camera_alt,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            onTap: () => context.push('/fit-check'),
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: 'My Wardrobe',
            subtitle: 'Manage your clothing items',
            description: 'Build your digital wardrobe for better recommendations',
            icon: Icons.checkroom,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
            onTap: () => context.push('/wardrobe'),
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: 'Outfit Builder',
            subtitle: 'Get AI outfit suggestions',
            description: 'Generate complete outfits from your wardrobe',
            icon: Icons.auto_awesome,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            onTap: () => context.push('/outfit-builder'),
          ),
          const SizedBox(height: 32),
          Card(
            color: AppTheme.accent.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, size: 48, color: AppTheme.accent),
                  const SizedBox(height: 12),
                  Text('Upgrade to Premium', style: AppTheme.h3),
                  const SizedBox(height: 8),
                  Text(
                    'Unlimited outfit checks, advanced recommendations, and more',
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.h3),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          Text('User Name', style: AppTheme.h2, textAlign: TextAlign.center),
          Text('user@example.com', style: AppTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Outfit History'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Saved Outfits'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Style Preferences'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

// Router
final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/wardrobe', builder: (_, __) => const WardrobeScreen()),
    GoRoute(path: '/fit-check', builder: (_, __) => const FitCheckScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(
      path: '/outfit-builder',
      builder: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Outfit Builder')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 80, color: AppTheme.accent),
                const SizedBox(height: 24),
                Text('AI Outfit Builder', style: AppTheme.h2, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Get complete outfit suggestions from your wardrobe based on the occasion',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Create Outfit'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
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
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
