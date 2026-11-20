import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/asset_video.dart';

const _welcomeCompletedKey = 'welcome_completed_v4';

/// Persists that onboarding has been completed so it does not show again.
Future<void> markOnboardingComplete() async {
  final dir = await getApplicationSupportDirectory();
  await File(p.join(dir.path, _welcomeCompletedKey))
      .writeAsString('done', flush: true);
}

class AppStartScreen extends ConsumerStatefulWidget {
  const AppStartScreen({super.key});
  @override
  ConsumerState<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends ConsumerState<AppStartScreen> {
  bool? _completed;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCompletion());
  }

  Future<void> _loadCompletion() async {
    var done = false;
    try {
      final dir = await getApplicationSupportDirectory();
      done = await File(p.join(dir.path, _welcomeCompletedKey)).exists();
    } catch (_) {
      done = false;
    }
    if (mounted) setState(() => _completed = done);
  }

  Future<void> _finishOnboarding() async {
    try {
      await markOnboardingComplete();
    } catch (_) {
      // Even if the marker cannot be written, let the person into the app.
    }
    if (!mounted) return;
    setState(() => _completed = true);
    context.go('/record');
  }

  @override
  Widget build(BuildContext context) {
    final completed = _completed;
    if (completed == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Use WidgetsBinding to navigate after build completes
    if (completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          context.go('/');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return OnboardingScreen(onComplete: _finishOnboarding);
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    required this.onComplete,
    this.initialPage = 0,
    super.key,
  });
  final Future<void> Function() onComplete;
  final int initialPage;
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _controller;
  late int _page;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage.clamp(0, 3);
    _controller = PageController(initialPage: _page);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final asset in [
      'voite-scene-welcome.png',
      'voite-scene-firstrecording.png',
      'voite-scene-goal.png',
      'voite-scene-freeoffline.png',
    ]) {
      unawaited(
        precacheImage(
          AssetImage('assets/images/$asset'),
          context,
        ).catchError((_) {}),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_saving) return;
    HapticFeedback.selectionClick();
    if (_page < 3) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onComplete();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setup could not be saved. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayStyle = _page >= 2
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _controller,
          itemCount: 4,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) => setState(() => _page = page),
          itemBuilder: (context, index) => _OnboardingScene(
            page: index,
            active: index == _page,
            onNext: _next,
            saving: _saving,
            onBack: index == 0
                ? null
                : () => _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingScene extends StatelessWidget {
  const _OnboardingScene({
    required this.page,
    required this.active,
    required this.onNext,
    required this.saving,
    required this.onBack,
  });
  final int page;
  final bool active;
  final VoidCallback onNext;
  final bool saving;
  final VoidCallback? onBack;

  static const _scenes = [
    'voite-scene-welcome.png',
    'voite-scene-firstrecording.png',
    'voite-scene-goal.png',
    'voite-scene-freeoffline.png',
  ];
  static const _titles = [
    'Keep the thought.',
    'One tap when you’re ready.',
    'A little every day.',
    'Free. Offline. Yours.',
  ];
  static const _copy = [
    'A voice recorder that stays yours.',
    'Your audio stays on this device.',
    'Ten minutes a day is enough to fill your daily goal.',
    'No account or ads. Your voice stays here; model downloads use the internet.',
  ];

  @override
  Widget build(BuildContext context) {
    final foreground = page >= 2 ? Colors.white : AppTheme.ink;
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _SceneMotion(
            active: active,
            child: page == 0
                ? AssetVideo(
                    asset: 'assets/videos/voite-video-welcome.mp4',
                    fallbackAsset: 'assets/images/${_scenes[0]}',
                    semanticLabel: 'Voite welcome scene with the cat and orange sound waves',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.18, 0.5),
                    autoplay: active,
                    loop: true,
                  )
                : Image.asset(
                    'assets/images/${_scenes[page]}',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    semanticLabel: 'Voite onboarding scene ${page + 1} of 4',
                  ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x40000000),
                  Color(0xB3000000),
                ],
                stops: [0.34, 0.56, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (onBack != null)
                        IconButton(
                          onPressed: onBack,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: foreground,
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                      const Spacer(),
                      Text(
                        '${page + 1} / 4',
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _titles[page],
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.06,
                            letterSpacing: -0.6,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _copy[page],
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: Colors.white, height: 1.4),
                    ),
                  ),
                  if (page == 1)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recording other people? Make sure everyone you’re recording knows.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: i == page ? 22 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: i == page ? AppTheme.orange : Colors.white54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: saving ? null : onNext,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              page == 0
                                  ? 'Get started'
                                  : page == 3
                                  ? 'Start recording'
                                  : 'Continue',
                            ),
                    ),
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

/// Adds a slow, continuous camera move so illustrated scenes feel alive.
/// The animation is skipped when the system asks for reduced motion.
class _SceneMotion extends StatefulWidget {
  const _SceneMotion({required this.active, required this.child});
  final bool active;
  final Widget child;

  @override
  State<_SceneMotion> createState() => _SceneMotionState();
}

class _SceneMotionState extends State<_SceneMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 14000),
  );
  bool _animating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _SceneMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final shouldAnimate = widget.active && !reduceMotion;
    if (shouldAnimate == _animating) return;
    _animating = shouldAnimate;
    if (shouldAnimate) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_animating) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.scale(
          scale: 1.02 + 0.055 * t,
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}
