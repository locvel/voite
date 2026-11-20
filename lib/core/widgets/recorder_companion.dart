import 'package:flutter/material.dart';

enum CompanionMood {
  listening,
  curious,
  thinking,
  writing,
  celebrating,
  guarding,
}

/// Compatibility wrapper for existing recording widgets, now using only the
/// locked Voite cat artwork from the v2 asset pack.
class RecorderCompanion extends StatelessWidget {
  const RecorderCompanion({
    required this.mood,
    required this.semanticLabel,
    this.width = 112,
    this.height = 126,
    this.onTap,
    super.key,
  });

  final CompanionMood mood;
  final String semanticLabel;
  final double width;
  final double height;
  final VoidCallback? onTap;

  String get _asset => switch (mood) {
    CompanionMood.celebrating => 'assets/images/voite-cat-celebrating.png',
    CompanionMood.thinking ||
    CompanionMood.writing => 'assets/images/voite-cat-thinking.png',
    CompanionMood.listening ||
    CompanionMood.curious ||
    CompanionMood.guarding => 'assets/images/voite-cat-listening.png',
  };

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      _asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel,
      gaplessPlayback: true,
    );
    if (onTap == null) return image;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(onTap: onTap, child: image),
    );
  }
}
