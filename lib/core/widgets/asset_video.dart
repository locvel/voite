import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'app_route_observer.dart';

/// Plays a bundled video once, muted, while keeping its still visible as the
/// loading and failure state.
class AssetVideo extends StatefulWidget {
  const AssetVideo({
    required this.asset,
    required this.fallbackAsset,
    required this.semanticLabel,
    required this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.autoplay = true,
    this.loop = false,
    this.respectReduceMotion = true,
    this.onCompleted,
    super.key,
  });

  final String asset;
  final String fallbackAsset;
  final String semanticLabel;
  final double width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final bool autoplay;
  final bool loop;
  final bool respectReduceMotion;
  final VoidCallback? onCompleted;

  @override
  State<AssetVideo> createState() => _AssetVideoState();
}

class _AssetVideoState extends State<AssetVideo>
    with WidgetsBindingObserver, RouteAware {
  VideoPlayerController? _controller;
  ModalRoute<dynamic>? _route;
  bool _routeActive = true;
  bool _started = false;
  bool _initialized = false;
  bool _failed = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      if (_route != null) appRouteObserver.unsubscribe(this);
      _route = route;
      if (route != null) appRouteObserver.subscribe(this, route);
    }
    _startIfAllowed();
  }

  @override
  void didUpdateWidget(covariant AssetVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset ||
        oldWidget.fallbackAsset != widget.fallbackAsset) {
      unawaited(_resetController());
      return;
    }
    if (oldWidget.autoplay && !widget.autoplay && _controller != null) {
      unawaited(_controller!.pause());
    }
    if (oldWidget.loop != widget.loop && _controller != null) {
      unawaited(_controller!.setLooping(widget.loop));
    }
    _startIfAllowed();
  }

  void _startIfAllowed() {
    if (!_routeActive ||
        !widget.autoplay ||
        _started ||
        _failed ||
        (widget.respectReduceMotion &&
            MediaQuery.disableAnimationsOf(context))) {
      return;
    }
    _started = true;
    unawaited(_loadAndPlay());
  }

  @override
  void didPush() {
    _routeActive = true;
    _startIfAllowed();
  }

  @override
  void didPushNext() {
    _routeActive = false;
    final controller = _controller;
    if (controller != null) unawaited(controller.pause());
  }

  @override
  void didPopNext() {
    _routeActive = true;
    final controller = _controller;
    if (controller != null && _initialized && !_completed && widget.autoplay) {
      unawaited(controller.play());
    } else {
      _startIfAllowed();
    }
  }

  @override
  void didPop() {
    _routeActive = false;
    final controller = _controller;
    if (controller != null) unawaited(controller.pause());
  }

  Future<void> _loadAndPlay() async {
    final controller = VideoPlayerController.asset(widget.asset);
    _controller = controller;
    controller.addListener(_onVideoChanged);
    try {
      await controller.initialize();
      if (!mounted || !identical(controller, _controller)) return;
      final reduceMotion =
          widget.respectReduceMotion && MediaQuery.disableAnimationsOf(context);
      if (!widget.autoplay || reduceMotion) {
        await controller.pause();
        return;
      }
      await controller.setLooping(widget.loop);
      await controller.setVolume(0.0);
      if (!mounted || !identical(controller, _controller)) return;
      if (!widget.autoplay || reduceMotion) {
        await controller.pause();
        return;
      }
      setState(() => _initialized = true);
      await controller.play();
    } catch (_) {
      _fail(controller);
    }
  }

  void _onVideoChanged() {
    final controller = _controller;
    if (controller == null) return;
    final value = controller.value;
    if (value.hasError) {
      _fail(controller);
      return;
    }
    if (widget.loop) return;
    if (!_initialized || _completed || value.duration <= Duration.zero) return;
    if (!value.isPlaying && value.position >= value.duration) {
      _finishAndDispose(controller);
    }
  }

  void _fail(VideoPlayerController controller) {
    if (!mounted || !identical(controller, _controller) || _failed) return;
    _failed = true;
    _finishAndDispose(controller);
  }

  void _finishAndDispose(VideoPlayerController controller) {
    if (_completed || !identical(controller, _controller)) return;
    _completed = true;
    controller.removeListener(_onVideoChanged);
    _controller = null;
    if (mounted) {
      setState(() {
        _initialized = false;
      });
    }
    unawaited(_disposeThenNotify(controller));
  }

  Future<void> _disposeThenNotify(VideoPlayerController controller) async {
    try {
      await controller.dispose();
    } catch (_) {
      // Keep the one-at-a-time animation sequence moving if native disposal
      // reports an error after the clip has already finished.
    }
    if (mounted) widget.onCompleted?.call();
  }

  Future<void> _resetController() async {
    final oldController = _controller;
    oldController?.removeListener(_onVideoChanged);
    _controller = null;
    _started = false;
    _initialized = false;
    _failed = false;
    _completed = false;
    await oldController?.dispose();
    if (mounted) {
      setState(() {});
      _startIfAllowed();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !_initialized) return;
    if (state == AppLifecycleState.resumed) {
      if (!_completed && widget.autoplay) unawaited(controller.play());
    } else {
      unawaited(controller.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouteObserver.unsubscribe(this);
    final controller = _controller;
    controller?.removeListener(_onVideoChanged);
    if (controller != null) unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final controller = _controller;
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.fallbackAsset,
              fit: widget.fit,
              alignment: widget.alignment,
              semanticLabel: widget.semanticLabel,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
            ),
            if (_initialized && !_failed && controller != null)
              Positioned.fill(
                child: ClipRect(
                  child: FittedBox(
                    fit: widget.fit,
                    alignment: widget.alignment,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
    if (widget.height != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: content,
      );
    }
    return SizedBox(
      width: widget.width,
      child: AspectRatio(aspectRatio: 2 / 3, child: content),
    );
  }
}
