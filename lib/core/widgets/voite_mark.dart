import 'package:flutter/material.dart';

/// Voite's transparent v3 logo.
class VoiteMark extends StatelessWidget {
  const VoiteMark({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/logo/voite-logo-glassy-v.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
    semanticLabel: 'Voite logo',
    gaplessPlayback: true,
  );
}
