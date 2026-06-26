import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/drink_detail_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/ai_chat/presentation/ai_chat_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/library/presentation/list_detail_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/data/profile_model.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../shell/app_shell.dart';

// Aba "Perfil" dentro do shell — redireciona para o perfil do usuário logado
class MyProfileTab extends ConsumerWidget {
  const MyProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return const SizedBox.shrink();
    return ProfileScreen(userId: uid);
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (_, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final loc = state.matchedLocation;

      if (!isAuth && loc != '/login') return '/login';
      if (isAuth && loc == '/login') return '/';

      if (isAuth && loc != '/onboarding') {
        try {
          final needed = await ref.read(onboardingNeededProvider.future);
          if (needed) return '/onboarding';
        } catch (_) {}
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/drink/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => DrinkDetailScreen(
          drinkId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/list/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => ListDetailScreen(
          listId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => EditProfileScreen(
          profile: state.extra as UserProfile,
        ),
      ),
      GoRoute(
        path: '/profile/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (ctx, state) => ProfileScreen(
          userId: state.pathParameters['id']!,
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, _, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/',        builder: (ctx, state) => const HomeScreen()),
          GoRoute(path: '/explore', builder: (ctx, state) => const ExploreScreen()),
          GoRoute(path: '/ai',      builder: (ctx, state) => const AiChatScreen()),
          GoRoute(path: '/library', builder: (ctx, state) => const LibraryScreen()),
          GoRoute(path: '/me',      builder: (ctx, state) => const MyProfileTab()),
        ],
      ),
    ],
  );
});
