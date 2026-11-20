import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/widgets/app_route_observer.dart';
import 'core/widgets/app_navigation.dart';
import 'features/onboarding/app_start_screen.dart';
import 'features/home/home_screen.dart';
import 'features/library/library_screen.dart';
import 'features/library/recording_detail_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/privacy_policy_screen.dart';
import 'features/prompt/daily_prompt_screen.dart';
import 'features/recording/record_screen.dart';
import 'features/diary/diary_screen.dart';
import 'features/crew/meet_the_crew_screen.dart';
import 'features/settings/about_screen.dart';

class VoiceRecorderApp extends ConsumerWidget {
  const VoiceRecorderApp({super.key});

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: [appRouteObserver],
    redirect: (context, state) {
      // Don't redirect if already on start/welcome screens
      if (state.matchedLocation == '/start' ||
          state.matchedLocation == '/welcome') {
        return null;
      }
      // Otherwise, let /start screen handle the onboarding check
      return null;
    },
    routes: [
      GoRoute(
        path: '/start',
        pageBuilder: (context, state) =>
            _transitionPage(state: state, child: const AppStartScreen()),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => _transitionPage(
          state: state,
          child: OnboardingScreen(
            onComplete: () async {
              await markOnboardingComplete();
              if (context.mounted) context.go('/record');
            },
          ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: const LibraryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/record',
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: const RecordScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/daily-prompt',
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: const DailyPromptScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: const SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/recording/:id',
        pageBuilder: (context, state) => _transitionPage(
          state: state,
          child: RecordingDetailScreen(
            recordingId: state.pathParameters['id']!,
            initialPositionMillis: state.extra as int?,
          ),
        ),
      ),
      GoRoute(
        path: '/diary',
        pageBuilder: (context, state) => _transitionPage(
          state: state,
          child: DiaryScreen(
            initialRecordingId: state.extra as String?,
            exportOnOpen: state.uri.queryParameters['export'] == '1',
          ),
        ),
      ),
      GoRoute(
        path: '/crew',
        pageBuilder: (context, state) =>
            _transitionPage(state: state, child: const MeetTheCrewScreen()),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) =>
            _transitionPage(state: state, child: const AboutScreen()),
      ),
      GoRoute(
        path: '/privacy',
        pageBuilder: (context, state) =>
            _transitionPage(state: state, child: const PrivacyPolicyScreen()),
      ),
    ],
    initialLocation: '/start',
  );

  static CustomTransitionPage<void> _transitionPage({
    required GoRouterState state,
    required Widget child,
  }) => CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 210),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    return MaterialApp.router(
      title: AppConstants.displayName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
