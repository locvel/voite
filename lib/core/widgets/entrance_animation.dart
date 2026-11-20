import 'package:flutter/material.dart';

/// A short, calm entrance for newly revealed content.
///
/// The transition is skipped when the device requests reduced motion. Delays
/// let callers create a small stagger without introducing another animation
/// dependency.
class EntranceAnimation extends StatefulWidget {
  const EntranceAnimation({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _started = true;
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.035),
        end: Offset.zero,
      ).animate(_opacity),
      child: widget.child,
    ),
  );
}
