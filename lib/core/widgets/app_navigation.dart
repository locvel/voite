import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/recording/recorder_controller.dart';
import '../theme/app_theme.dart';

class AppNavigationBar extends ConsumerWidget {
  const AppNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recorder = ref.watch(recorderControllerProvider);
    final isRecording = recorder.isRecording;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeLabel = isDark
        ? AppTheme.darkAccentText
        : AppTheme.lightAccentText;
    final barFill = isDark
        ? const Color(0xFF1C1C20).withValues(alpha: 0.62)
        : Colors.white.withValues(alpha: 0.68);
    final hairline = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFF1D1912).withValues(alpha: 0.10);
    final barShadow = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : const Color(0xFF1D1912).withValues(alpha: 0.18);

    final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 2.0);

    // Apple Liquid Glass material properties
    final liquidGlassBlur = 40.0; // Higher blur for true frosted glass
    final materialOpacity = isDark ? 0.72 : 0.78; // More opacity for depth
    final vibrancyLayer = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.55);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 64 * scale,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SizedBox(
              height: 64 * scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: liquidGlassBlur,
                          sigmaY: liquidGlassBlur,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: barFill.withValues(alpha: materialOpacity),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: hairline, width: 0.5),
                            boxShadow: [
                              // Deep shadow for elevation
                              BoxShadow(
                                color: barShadow,
                                blurRadius: 32,
                                spreadRadius: -4,
                                offset: const Offset(0, 12),
                              ),
                              // Subtle inner glow for depth
                              BoxShadow(
                                color: vibrancyLayer,
                                blurRadius: 0,
                                offset: const Offset(0, -0.5),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _tab(
                                context,
                                index: 0,
                                label: 'Home',
                                icon: Icons.home_outlined,
                                selectedIcon: Icons.home_rounded,
                                activeLabel: activeLabel,
                                surface: barFill,
                                inactive: scheme.onSurfaceVariant,
                                route: '/',
                              ),
                              _assetTab(
                                context,
                                index: 1,
                                label: 'Library',
                                asset: 'assets/images/voite-icon-library.png',
                                activeLabel: activeLabel,
                                surface: barFill,
                                inactive: scheme.onSurfaceVariant,
                                route: '/library',
                              ),
                              _tab(
                                context,
                                index: 2,
                                label: 'Record',
                                icon: isRecording
                                    ? Icons.stop_circle
                                    : Icons.mic_rounded,
                                selectedIcon: isRecording
                                    ? Icons.stop_circle
                                    : Icons.mic_rounded,
                                activeLabel: activeLabel,
                                surface: barFill,
                                inactive: scheme.onSurfaceVariant,
                                route: '/record',
                              ),
                              _assetTab(
                                context,
                                index: 3,
                                label: 'Prompt',
                                asset: 'assets/images/voite-icon-idea.png',
                                activeLabel: activeLabel,
                                surface: barFill,
                                inactive: scheme.onSurfaceVariant,
                                route: '/daily-prompt',
                              ),
                              _tab(
                                context,
                                index: 4,
                                label: 'Settings',
                                icon: Icons.settings_outlined,
                                selectedIcon: Icons.settings_rounded,
                                activeLabel: activeLabel,
                                surface: barFill,
                                inactive: scheme.onSurfaceVariant,
                                route: '/settings',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
    required Color activeLabel,
    required Color surface,
    required Color inactive,
    required String route,
  }) {
    final selected = selectedIndex == index;
    return Expanded(
      child: _TabTapTarget(
        selected: selected,
        activeLabel: activeLabel,
        inactive: inactive,
        surface: surface,
        label: label,
        onTap: () => _go(context, index, route),
        child: Icon(
          selected ? selectedIcon : icon,
          size: 24,
          color: selected ? activeLabel : inactive,
        ),
      ),
    );
  }

  Widget _assetTab(
    BuildContext context, {
    required int index,
    required String label,
    required String asset,
    required Color activeLabel,
    required Color surface,
    required Color inactive,
    required String route,
  }) {
    final selected = selectedIndex == index;
    return Expanded(
      child: _TabTapTarget(
        selected: selected,
        activeLabel: activeLabel,
        inactive: inactive,
        surface: surface,
        label: label,
        onTap: () => _go(context, index, route),
        child: Image.asset(
          asset,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    );
  }

  void _go(BuildContext context, int index, String route) {
    if (selectedIndex == index) return;
    HapticFeedback.selectionClick();
    onDestinationSelected(index);
  }
}

class _TabTapTarget extends StatelessWidget {
  const _TabTapTarget({
    required this.selected,
    required this.activeLabel,
    required this.inactive,
    required this.surface,
    required this.label,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final Color activeLabel;
  final Color inactive;
  final Color surface;
  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Center(
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.orange.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  height: 1,
                  color: selected ? activeLabel : inactive,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
